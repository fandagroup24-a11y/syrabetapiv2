import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  Prisma,
  auth_users_status,
  wallet_ledger_entries_direction,
  wallet_ledger_entries_type,
  wallet_payments_status,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ApproveWithdrawalDto } from './dto/approve-withdrawal.dto';
import { CreateDepositDto } from './dto/create-deposit.dto';
import { CreateWithdrawalDto } from './dto/create-withdrawal.dto';
import { ListLedgerQueryDto } from './dto/list-ledger-query.dto';
import { ListPaymentsQueryDto } from './dto/list-payments-query.dto';
import { ListWithdrawalsQueryDto } from './dto/list-withdrawals-query.dto';
import { RejectWithdrawalDto } from './dto/reject-withdrawal.dto';
import { ReverseLedgerEntryDto } from './dto/reverse-ledger-entry.dto';

const USER_BASIC_SELECT = {
  id: true,
  email: true,
  phone: true,
  username: true,
  display_name: true,
  status: true,
} satisfies Prisma.auth_usersSelect;

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
    select: USER_BASIC_SELECT,
  },
} satisfies Prisma.wallet_walletsSelect;

const WALLET_BALANCE_SELECT = {
  id: true,
  user_id: true,
  currency: true,
  balance_available: true,
} satisfies Prisma.wallet_walletsSelect;

const LEDGER_SELECT = {
  id: true,
  wallet_id: true,
  type: true,
  direction: true,
  amount: true,
  balance_after: true,
  currency: true,
  reference_type: true,
  reference_id: true,
  description: true,
  created_at: true,
  wallet_wallets: {
    select: {
      id: true,
      user_id: true,
      currency: true,
      auth_users: {
        select: USER_BASIC_SELECT,
      },
    },
  },
} satisfies Prisma.wallet_ledger_entriesSelect;

const PAYMENT_SELECT = {
  id: true,
  user_id: true,
  provider: true,
  method: true,
  amount: true,
  currency: true,
  status: true,
  provider_ref: true,
  meta_json: true,
  created_at: true,
  updated_at: true,
  auth_users: {
    select: USER_BASIC_SELECT,
  },
} satisfies Prisma.wallet_paymentsSelect;

const WITHDRAWAL_SELECT = {
  id: true,
  user_id: true,
  provider: true,
  method: true,
  amount: true,
  currency: true,
  status: true,
  provider_ref: true,
  reason: true,
  meta_json: true,
  requested_at: true,
  updated_at: true,
  auth_users: {
    select: USER_BASIC_SELECT,
  },
} satisfies Prisma.wallet_withdrawalsSelect;

@Injectable()
export class WalletTransactionsService {
  constructor(private readonly prisma: PrismaService) {}

  async createDeposit(dto: CreateDepositDto) {
    const currency = this.normalizeCurrency(dto.currency) ?? 'XOF';
    const amount = new Prisma.Decimal(dto.amount);

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.auth_users.findUnique({
        where: { id: dto.userId },
        select: {
          id: true,
          status: true,
        },
      });

      if (!user) {
        throw new NotFoundException(`User not found: ${dto.userId}`);
      }

      if (user.status !== auth_users_status.ACTIVE) {
        throw new ForbiddenException('User account is not active');
      }

      const wallet = await this.getOrCreateWallet(tx, dto.userId, currency);
      const nextBalance = wallet.balance_available.plus(amount);

      try {
        const payment = await tx.wallet_payments.create({
          data: {
            user_id: dto.userId,
            provider: dto.provider.trim(),
            method: dto.method?.trim() || 'deposit',
            amount,
            currency,
            status: wallet_payments_status.SUCCESS,
            provider_ref: dto.providerRef?.trim() || null,
          },
          select: PAYMENT_SELECT,
        });

        const updatedWallet = await tx.wallet_wallets.update({
          where: { id: wallet.id },
          data: {
            balance_available: nextBalance,
          },
          select: WALLET_SELECT,
        });

        const ledger = await tx.wallet_ledger_entries.create({
          data: {
            wallet_id: wallet.id,
            type: wallet_ledger_entries_type.DEPOSIT,
            direction: wallet_ledger_entries_direction.CREDIT,
            amount,
            balance_after: nextBalance,
            currency,
            reference_type: 'WALLET_PAYMENT',
            reference_id: payment.id,
            description: dto.description?.trim() || null,
          },
          select: LEDGER_SELECT,
        });

        return {
          wallet: updatedWallet,
          payment,
          ledger,
        };
      } catch (error) {
        if (
          error instanceof Prisma.PrismaClientKnownRequestError &&
          error.code === 'P2002'
        ) {
          throw new ConflictException(
            'Payment provider reference already exists for this provider',
          );
        }
        throw error;
      }
    });
  }

  async createWithdrawal(dto: CreateWithdrawalDto) {
    const currency = this.normalizeCurrency(dto.currency) ?? 'XOF';
    const amount = new Prisma.Decimal(dto.amount);

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.auth_users.findUnique({
        where: { id: dto.userId },
        select: {
          id: true,
          status: true,
        },
      });

      if (!user) {
        throw new NotFoundException(`User not found: ${dto.userId}`);
      }

      if (user.status !== auth_users_status.ACTIVE) {
        throw new ForbiddenException('User account is not active');
      }

      const wallet = await tx.wallet_wallets.findUnique({
        where: {
          user_id_currency: {
            user_id: dto.userId,
            currency,
          },
        },
        select: {
          id: true,
          balance_available: true,
        },
      });

      if (!wallet) {
        throw new NotFoundException(
          `Wallet not found for user ${dto.userId} and currency ${currency}`,
        );
      }

      if (wallet.balance_available.lessThan(amount)) {
        throw new BadRequestException('Insufficient balance');
      }

      const withdrawal = await tx.wallet_withdrawals.create({
        data: {
          user_id: dto.userId,
          provider: dto.provider.trim(),
          method: dto.method?.trim() || null,
          amount,
          currency,
          status: 'REQUESTED',
          provider_ref: dto.providerRef?.trim() || null,
          reason: dto.reason?.trim() || null,
        },
        select: WITHDRAWAL_SELECT,
      });

      return {
        wallet: await tx.wallet_wallets.findUnique({
          where: { id: wallet.id },
          select: WALLET_SELECT,
        }),
        withdrawal,
      };
    });
  }

  async approveWithdrawal(withdrawalId: string, dto: ApproveWithdrawalDto) {
    return this.prisma.$transaction(async (tx) => {
      const withdrawal = await tx.wallet_withdrawals.findUnique({
        where: { id: withdrawalId },
        select: {
          id: true,
          user_id: true,
          amount: true,
          currency: true,
          status: true,
          reason: true,
        },
      });

      if (!withdrawal) {
        throw new NotFoundException(`Withdrawal not found: ${withdrawalId}`);
      }

      if (withdrawal.status !== 'REQUESTED') {
        throw new ConflictException(
          `Withdrawal cannot be approved from status ${withdrawal.status}`,
        );
      }

      const wallet = await tx.wallet_wallets.findUnique({
        where: {
          user_id_currency: {
            user_id: withdrawal.user_id,
            currency: withdrawal.currency,
          },
        },
        select: WALLET_BALANCE_SELECT,
      });

      if (!wallet) {
        throw new NotFoundException(
          `Wallet not found for user ${withdrawal.user_id} and currency ${withdrawal.currency}`,
        );
      }

      if (wallet.balance_available.lessThan(withdrawal.amount)) {
        throw new BadRequestException(
          'Insufficient balance at approval time for this withdrawal',
        );
      }

      const nextBalance = wallet.balance_available.minus(withdrawal.amount);
      const note = dto.note?.trim() || null;

      const updatedWithdrawal = await tx.wallet_withdrawals.update({
        where: { id: withdrawal.id },
        data: {
          status: 'SUCCESS',
          provider_ref: dto.providerRef?.trim() || undefined,
          reason: note ? this.mergeReason(withdrawal.reason, note) : undefined,
        },
        select: WITHDRAWAL_SELECT,
      });

      const updatedWallet = await tx.wallet_wallets.update({
        where: { id: wallet.id },
        data: {
          balance_available: nextBalance,
        },
        select: WALLET_SELECT,
      });

      const ledger = await tx.wallet_ledger_entries.create({
        data: {
          wallet_id: wallet.id,
          type: wallet_ledger_entries_type.WITHDRAW,
          direction: wallet_ledger_entries_direction.DEBIT,
          amount: withdrawal.amount,
          balance_after: nextBalance,
          currency: withdrawal.currency,
          reference_type: 'WALLET_WITHDRAWAL',
          reference_id: withdrawal.id,
          description: note,
        },
        select: LEDGER_SELECT,
      });

      return {
        wallet: updatedWallet,
        withdrawal: updatedWithdrawal,
        ledger,
      };
    });
  }

  async rejectWithdrawal(withdrawalId: string, dto: RejectWithdrawalDto) {
    const reason = dto.reason.trim();

    const withdrawal = await this.prisma.wallet_withdrawals.findUnique({
      where: { id: withdrawalId },
      select: {
        id: true,
        status: true,
        reason: true,
      },
    });

    if (!withdrawal) {
      throw new NotFoundException(`Withdrawal not found: ${withdrawalId}`);
    }

    if (withdrawal.status !== 'REQUESTED') {
      throw new ConflictException(
        `Withdrawal cannot be rejected from status ${withdrawal.status}`,
      );
    }

    return this.prisma.wallet_withdrawals.update({
      where: { id: withdrawal.id },
      data: {
        status: 'REJECTED',
        reason: this.mergeReason(withdrawal.reason, reason),
      },
      select: WITHDRAWAL_SELECT,
    });
  }

  async reverseLedgerEntry(ledgerEntryId: string, dto: ReverseLedgerEntryDto) {
    const reason = dto.reason?.trim() || null;

    return this.prisma.$transaction(async (tx) => {
      const originalEntry = await tx.wallet_ledger_entries.findUnique({
        where: { id: ledgerEntryId },
        select: {
          id: true,
          wallet_id: true,
          type: true,
          direction: true,
          amount: true,
          currency: true,
          reference_type: true,
          reference_id: true,
          description: true,
        },
      });

      if (!originalEntry) {
        throw new NotFoundException(`Ledger entry not found: ${ledgerEntryId}`);
      }

      if (originalEntry.reference_type === 'LEDGER_REVERSAL') {
        throw new BadRequestException(
          'Reversing a reversal entry is not allowed',
        );
      }

      const existingReversal = await tx.wallet_ledger_entries.findFirst({
        where: {
          reference_type: 'LEDGER_REVERSAL',
          reference_id: originalEntry.id,
        },
        select: {
          id: true,
        },
      });

      if (existingReversal) {
        throw new ConflictException(
          `Ledger entry already reversed by ${existingReversal.id}`,
        );
      }

      const wallet = await tx.wallet_wallets.findUnique({
        where: { id: originalEntry.wallet_id },
        select: WALLET_BALANCE_SELECT,
      });

      if (!wallet) {
        throw new NotFoundException(
          `Wallet not found for ledger entry ${originalEntry.id}`,
        );
      }

      const reversalDirection =
        originalEntry.direction === wallet_ledger_entries_direction.DEBIT
          ? wallet_ledger_entries_direction.CREDIT
          : wallet_ledger_entries_direction.DEBIT;

      const reversalType =
        reversalDirection === wallet_ledger_entries_direction.CREDIT
          ? wallet_ledger_entries_type.REFUND
          : wallet_ledger_entries_type.ADJUSTMENT;

      let nextBalance: Prisma.Decimal;
      if (reversalDirection === wallet_ledger_entries_direction.CREDIT) {
        nextBalance = wallet.balance_available.plus(originalEntry.amount);
      } else {
        if (wallet.balance_available.lessThan(originalEntry.amount)) {
          throw new BadRequestException(
            'Insufficient balance to reverse this credit transaction',
          );
        }
        nextBalance = wallet.balance_available.minus(originalEntry.amount);
      }

      const updatedWallet = await tx.wallet_wallets.update({
        where: { id: wallet.id },
        data: {
          balance_available: nextBalance,
        },
        select: WALLET_SELECT,
      });

      const reversalEntry = await tx.wallet_ledger_entries.create({
        data: {
          wallet_id: wallet.id,
          type: reversalType,
          direction: reversalDirection,
          amount: originalEntry.amount,
          balance_after: nextBalance,
          currency: originalEntry.currency,
          reference_type: 'LEDGER_REVERSAL',
          reference_id: originalEntry.id,
          description:
            reason ||
            `Reversal of ledger ${originalEntry.id}${originalEntry.description ? `: ${originalEntry.description}` : ''}`,
        },
        select: LEDGER_SELECT,
      });

      await this.syncReferenceStatusOnReversal(tx, originalEntry);

      return {
        wallet: updatedWallet,
        reversedEntry: reversalEntry,
        originalEntryId: originalEntry.id,
      };
    });
  }

  async listLedger(query: ListLedgerQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const currency = this.normalizeCurrency(query.currency);

    const where: Prisma.wallet_ledger_entriesWhereInput = {};
    if (query.walletId) {
      where.wallet_id = query.walletId;
    }
    if (query.userId) {
      where.wallet_wallets = {
        user_id: query.userId,
      };
    }
    if (query.type) {
      where.type = query.type;
    }
    if (query.direction) {
      where.direction = query.direction;
    }
    if (currency) {
      where.currency = currency;
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.wallet_ledger_entries.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        select: LEDGER_SELECT,
      }),
      this.prisma.wallet_ledger_entries.count({ where }),
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

  async listPayments(query: ListPaymentsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const currency = this.normalizeCurrency(query.currency);

    const where: Prisma.wallet_paymentsWhereInput = {};
    if (query.userId) {
      where.user_id = query.userId;
    }
    if (query.status) {
      where.status = query.status;
    }
    if (currency) {
      where.currency = currency;
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.wallet_payments.findMany({
        where,
        skip,
        take: limit,
        orderBy: { created_at: 'desc' },
        select: PAYMENT_SELECT,
      }),
      this.prisma.wallet_payments.count({ where }),
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

  async listWithdrawals(query: ListWithdrawalsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const currency = this.normalizeCurrency(query.currency);

    const where: Prisma.wallet_withdrawalsWhereInput = {};
    if (query.userId) {
      where.user_id = query.userId;
    }
    if (query.status) {
      where.status = query.status.trim().toUpperCase();
    }
    if (currency) {
      where.currency = currency;
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.wallet_withdrawals.findMany({
        where,
        skip,
        take: limit,
        orderBy: { requested_at: 'desc' },
        select: WITHDRAWAL_SELECT,
      }),
      this.prisma.wallet_withdrawals.count({ where }),
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

  private async getOrCreateWallet(
    tx: Prisma.TransactionClient,
    userId: string,
    currency: string,
  ) {
    const existing = await tx.wallet_wallets.findUnique({
      where: {
        user_id_currency: {
          user_id: userId,
          currency,
        },
      },
      select: {
        id: true,
        balance_available: true,
      },
    });

    if (existing) {
      return existing;
    }

    return tx.wallet_wallets.create({
      data: {
        user_id: userId,
        currency,
      },
      select: {
        id: true,
        balance_available: true,
      },
    });
  }

  private normalizeCurrency(currency?: string) {
    const normalized = currency?.trim().toUpperCase();
    return normalized || undefined;
  }

  private mergeReason(existing: string | null, incoming: string) {
    return existing ? `${existing}\n${incoming}` : incoming;
  }

  private async syncReferenceStatusOnReversal(
    tx: Prisma.TransactionClient,
    entry: {
      reference_type: string | null;
      reference_id: string | null;
    },
  ) {
    if (!entry.reference_type || !entry.reference_id) {
      return;
    }

    if (entry.reference_type === 'WALLET_PAYMENT') {
      await tx.wallet_payments.updateMany({
        where: {
          id: entry.reference_id,
          status: wallet_payments_status.SUCCESS,
        },
        data: {
          status: wallet_payments_status.REFUNDED,
        },
      });
      return;
    }

    if (entry.reference_type === 'WALLET_WITHDRAWAL') {
      await tx.wallet_withdrawals.updateMany({
        where: {
          id: entry.reference_id,
        },
        data: {
          status: 'REVERSED',
        },
      });
    }
  }
}
