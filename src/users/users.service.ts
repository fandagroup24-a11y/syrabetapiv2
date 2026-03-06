import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ListUsersQueryDto } from './dto/list-users-query.dto';

const USER_LIST_SELECT = {
  id: true,
  email: true,
  phone: true,
  username: true,
  display_name: true,
  country: true,
  currency: true,
  locale: true,
  status: true,
  is_test: true,
  phone_verified: true,
  email_verified: true,
  created_at: true,
  updated_at: true,
  wallet_wallets: {
    select: {
      id: true,
      currency: true,
      balance_available: true,
      balance_locked: true,
      balance_bonus: true,
      updated_at: true,
    },
  },
} satisfies Prisma.auth_usersSelect;

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async listUsers(query: ListUsersQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const normalizedSearch = query.search?.trim();

    const where: Prisma.auth_usersWhereInput = {};

    if (query.userId) {
      where.id = query.userId;
    }

    if (query.status) {
      where.status = query.status;
    }

    if (normalizedSearch) {
      where.OR = [
        { email: { contains: normalizedSearch } },
        { phone: { contains: normalizedSearch } },
        { username: { contains: normalizedSearch } },
        { display_name: { contains: normalizedSearch } },
      ];
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.auth_users.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        select: USER_LIST_SELECT,
      }),
      this.prisma.auth_users.count({ where }),
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

  async getUserById(id: string) {
    const user = await this.prisma.auth_users.findUnique({
      where: { id },
      select: USER_LIST_SELECT,
    });

    if (!user) {
      throw new NotFoundException(`User not found: ${id}`);
    }

    return user;
  }
}
