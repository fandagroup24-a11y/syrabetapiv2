import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ListWalletsQueryDto } from './dto/list-wallets-query.dto';

const WALLET_SELECT = {
  id: true,
  user_id: true,
  currency: true,
  balance_available: true,
  balance_locked: true,
  balance_bonus: true,
  created_at: true,
  updated_at: true,
  auth_users: {
    select: {
      id: true,
      email: true,
      phone: true,
      username: true,
      display_name: true,
      status: true,
    },
  },
  _count: {
    select: {
      wallet_ledger_entries: true,
    },
  },
} satisfies Prisma.wallet_walletsSelect;

@Injectable()
export class WalletsService {
  constructor(private readonly prisma: PrismaService) {}

  async listWallets(query: ListWalletsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const normalizedCurrency = query.currency?.trim().toUpperCase();

    const where: Prisma.wallet_walletsWhereInput = {};

    if (query.userId) {
      where.user_id = query.userId;
    }

    if (normalizedCurrency) {
      where.currency = normalizedCurrency;
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.wallet_wallets.findMany({
        where,
        skip,
        take: limit,
        orderBy: { updated_at: 'desc' },
        select: WALLET_SELECT,
      }),
      this.prisma.wallet_wallets.count({ where }),
    ]);

    return {
      data,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async getWalletById(id: string) {
    const wallet = await this.prisma.wallet_wallets.findUnique({
      where: { id },
      select: WALLET_SELECT,
    });

    if (!wallet) {
      throw new NotFoundException(`Wallet not found: ${id}`);
    }

    return wallet;
  }

  async getWalletsByUserId(userId: string) {
    return this.prisma.wallet_wallets.findMany({
      where: { user_id: userId },
      orderBy: { updated_at: 'desc' },
      select: WALLET_SELECT,
    });
  }
}
