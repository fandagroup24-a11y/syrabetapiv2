import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  Prisma,
  auth_users_status,
  betting_bet_legs_status,
  betting_bets_status,
  betting_bets_type,
  sportsbook_events_status,
  wallet_ledger_entries_direction,
  wallet_ledger_entries_type,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { parseRiskLimits } from '../risk/default-risk-limits';
import { ListBetsQueryDto } from './dto/list-bets-query.dto';
import { PlaceBetDto } from './dto/place-bet.dto';

const BET_LEG_SELECT = {
  id: true,
  event_id: true,
  market_id: true,
  selection_id: true,
  odds_locked: true,
  status: true,
  created_at: true,
  sportsbook_events: {
    select: {
      id: true,
      name: true,
      start_time: true,
      status: true,
    },
  },
  sportsbook_markets: {
    select: {
      id: true,
      name: true,
      status: true,
    },
  },
  sportsbook_selections: {
    select: {
      id: true,
      name: true,
      odds: true,
      status: true,
      result: true,
    },
  },
} satisfies Prisma.betting_bet_legsSelect;

const BET_SELECT = {
  id: true,
  user_id: true,
  betslip_id: true,
  type: true,
  stake: true,
  total_odds: true,
  potential_payout: true,
  actual_payout: true,
  currency: true,
  status: true,
  placed_at: true,
  settled_at: true,
  meta_json: true,
  created_at: true,
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
  betting_bet_legs: {
    select: BET_LEG_SELECT,
    orderBy: {
      created_at: 'asc',
    },
  },
} satisfies Prisma.betting_betsSelect;

const WALLET_SELECT = {
  id: true,
  user_id: true,
  currency: true,
  balance_available: true,
  balance_locked: true,
  balance_bonus: true,
  updated_at: true,
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
} satisfies Prisma.wallet_ledger_entriesSelect;

const ACTIVE_RISK_LIMITS_SELECT = {
  id: true,
  value_json: true,
} satisfies Prisma.admin_risk_limitsSelect;

@Injectable()
export class BettingService {
  constructor(private readonly prisma: PrismaService) {}

  async placeBet(userId: string, dto: PlaceBetDto) {
    const uniqueSelectionIds = [...new Set(dto.selectionIds)];
    const currency = dto.currency?.trim().toUpperCase() || 'XOF';
    const stake = new Prisma.Decimal(dto.stake);

    if (uniqueSelectionIds.length !== dto.selectionIds.length) {
      throw new BadRequestException('Duplicate selection ids are not allowed');
    }

    if (
      dto.type === betting_bets_type.SINGLE &&
      uniqueSelectionIds.length !== 1
    ) {
      throw new BadRequestException('SINGLE bet requires exactly 1 selection');
    }

    if (dto.type === betting_bets_type.ACCA && uniqueSelectionIds.length < 2) {
      throw new BadRequestException('ACCA bet requires at least 2 selections');
    }

    if (dto.type === betting_bets_type.SYSTEM) {
      throw new BadRequestException('SYSTEM bet type is not implemented yet');
    }

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.auth_users.findUnique({
        where: { id: userId },
        select: {
          id: true,
          status: true,
        },
      });

      if (!user) {
        throw new NotFoundException(`User not found: ${userId}`);
      }

      if (user.status !== auth_users_status.ACTIVE) {
        throw new ForbiddenException('User account is not active');
      }

      const now = new Date();
      const riskLimits = await this.getActiveRiskLimits(tx);

      if (stake.lessThan(riskLimits.minStake)) {
        throw new BadRequestException(
          `Stake below minimum allowed (${riskLimits.minStake.toString()})`,
        );
      }

      if (stake.greaterThan(riskLimits.maxStake)) {
        throw new BadRequestException(
          `Stake above maximum allowed (${riskLimits.maxStake.toString()})`,
        );
      }

      if (riskLimits.cooldownPlaceBetSec > 0) {
        const lastBet = await tx.betting_bets.findFirst({
          where: {
            user_id: userId,
            placed_at: { not: null },
            status: { not: betting_bets_status.DRAFT },
          },
          orderBy: [{ placed_at: 'desc' }],
          select: {
            placed_at: true,
          },
        });

        if (lastBet?.placed_at) {
          const elapsedMs = now.getTime() - lastBet.placed_at.getTime();
          const cooldownMs = riskLimits.cooldownPlaceBetSec * 1000;
          if (elapsedMs < cooldownMs) {
            const waitSec = Math.ceil((cooldownMs - elapsedMs) / 1000);
            throw new BadRequestException(
              `Please wait ${waitSec}s before placing another bet`,
            );
          }
        }
      }

      const wallet = await tx.wallet_wallets.findUnique({
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

      if (!wallet) {
        throw new NotFoundException(
          `Wallet not found for user ${userId} and currency ${currency}`,
        );
      }

      if (wallet.balance_available.lessThan(stake)) {
        throw new BadRequestException('Insufficient balance');
      }

      const selections = await tx.sportsbook_selections.findMany({
        where: {
          id: { in: uniqueSelectionIds },
          status: 'OPEN',
        },
        select: {
          id: true,
          odds: true,
          market_id: true,
          sportsbook_markets: {
            select: {
              id: true,
              event_id: true,
              status: true,
              sportsbook_events: {
                select: {
                  id: true,
                  status: true,
                  start_time: true,
                },
              },
            },
          },
        },
      });

      if (selections.length !== uniqueSelectionIds.length) {
        throw new BadRequestException(
          'One or more selections are invalid or not open',
        );
      }

      const seenEventIds = new Set<string>();
      let totalOdds = new Prisma.Decimal(1);

      for (const selection of selections) {
        if (selection.sportsbook_markets.status !== 'OPEN') {
          throw new BadRequestException(
            `Market is not open for selection ${selection.id}`,
          );
        }

        const event = selection.sportsbook_markets.sportsbook_events;
        if (
          event.status === sportsbook_events_status.FINISHED ||
          event.status === sportsbook_events_status.CANCELLED ||
          event.status === sportsbook_events_status.POSTPONED
        ) {
          throw new BadRequestException(
            `Event is not open for betting for selection ${selection.id}`,
          );
        }

        if (
          event.status === sportsbook_events_status.SCHEDULED &&
          event.start_time <= now
        ) {
          throw new BadRequestException(
            `Event already started for selection ${selection.id}`,
          );
        }

        if (dto.type === betting_bets_type.ACCA) {
          if (seenEventIds.has(event.id)) {
            throw new BadRequestException(
              'ACCA bet cannot contain multiple selections from the same event',
            );
          }
          seenEventIds.add(event.id);
        }

        totalOdds = totalOdds.mul(selection.odds);
      }

      totalOdds = totalOdds.toDecimalPlaces(4);
      const potentialPayout = stake.mul(totalOdds).toDecimalPlaces(2);

      if (potentialPayout.greaterThan(riskLimits.maxPayout)) {
        throw new BadRequestException(
          `Potential payout exceeds allowed maximum (${riskLimits.maxPayout.toString()})`,
        );
      }

      const nextBalance = wallet.balance_available.minus(stake);

      const bet = await tx.betting_bets.create({
        data: {
          user_id: userId,
          type: dto.type,
          stake,
          total_odds: totalOdds,
          potential_payout: potentialPayout,
          actual_payout: new Prisma.Decimal(0),
          currency,
          status: betting_bets_status.PLACED,
          placed_at: now,
        },
        select: {
          id: true,
        },
      });

      await tx.betting_bet_legs.createMany({
        data: selections.map((selection) => ({
          bet_id: bet.id,
          event_id: selection.sportsbook_markets.event_id,
          market_id: selection.market_id,
          selection_id: selection.id,
          odds_locked: selection.odds,
          status: betting_bet_legs_status.PENDING,
        })),
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
          type: wallet_ledger_entries_type.BET_STAKE,
          direction: wallet_ledger_entries_direction.DEBIT,
          amount: stake,
          balance_after: nextBalance,
          currency,
          reference_type: 'BET',
          reference_id: bet.id,
          description: `Stake for ${dto.type} bet`,
        },
        select: LEDGER_SELECT,
      });

      const placedBet = await tx.betting_bets.findUnique({
        where: { id: bet.id },
        select: BET_SELECT,
      });

      if (!placedBet) {
        throw new NotFoundException(`Placed bet not found: ${bet.id}`);
      }

      return {
        bet: placedBet,
        wallet: updatedWallet,
        ledger,
      };
    });
  }

  private async getActiveRiskLimits(tx: Prisma.TransactionClient) {
    const row = await tx.admin_risk_limits.findFirst({
      where: {
        scope: 'GLOBAL',
        scope_key: null,
        name: 'DEFAULT_LIMITS',
        status: 'ACTIVE',
      },
      orderBy: [{ updated_at: 'desc' }],
      select: ACTIVE_RISK_LIMITS_SELECT,
    });

    const parsed = parseRiskLimits(row?.value_json);
    return {
      minStake: new Prisma.Decimal(parsed.minStake),
      maxStake: new Prisma.Decimal(parsed.maxStake),
      maxPayout: new Prisma.Decimal(parsed.maxPayout),
      cooldownPlaceBetSec: parsed.cooldownPlaceBetSec,
    };
  }

  async listBets(userId: string, query: ListBetsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;

    const where: Prisma.betting_betsWhereInput = {
      user_id: userId,
    };

    if (query.status) {
      where.status = query.status;
    }

    if (query.type) {
      where.type = query.type;
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.betting_bets.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ created_at: 'desc' }],
        select: BET_SELECT,
      }),
      this.prisma.betting_bets.count({ where }),
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

  async getBetById(userId: string, betId: string) {
    const bet = await this.prisma.betting_bets.findUnique({
      where: { id: betId },
      select: BET_SELECT,
    });

    if (!bet) {
      throw new NotFoundException(`Bet not found: ${betId}`);
    }

    if (bet.user_id !== userId) {
      throw new ForbiddenException('You are not allowed to access this bet');
    }

    return bet;
  }
}
