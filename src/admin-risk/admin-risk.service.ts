import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  parseRiskLimits,
  toRiskLimitsJson,
  type RiskLimits,
} from '../risk/default-risk-limits';
import { UpdateDefaultRiskLimitsDto } from './dto/update-default-risk-limits.dto';

const DEFAULT_LIMITS_SELECT = {
  id: true,
  scope: true,
  scope_key: true,
  name: true,
  value_json: true,
  status: true,
  created_at: true,
  updated_at: true,
} satisfies Prisma.admin_risk_limitsSelect;

@Injectable()
export class AdminRiskService {
  constructor(private readonly prisma: PrismaService) {}

  async getDefaultLimits() {
    const row = await this.getOrCreateDefaultLimitsRow();
    return this.mapLimitsRow(row);
  }

  async updateDefaultLimits(dto: UpdateDefaultRiskLimitsDto) {
    const currentRow = await this.getOrCreateDefaultLimitsRow();
    const current = parseRiskLimits(currentRow.value_json);

    const next: RiskLimits = {
      minStake: dto.minStake ?? current.minStake,
      maxStake: dto.maxStake ?? current.maxStake,
      maxPayout: dto.maxPayout ?? current.maxPayout,
      cooldownPlaceBetSec:
        dto.cooldownPlaceBetSec ?? current.cooldownPlaceBetSec,
    };

    this.validateLimits(next);

    const updated = await this.prisma.admin_risk_limits.update({
      where: { id: currentRow.id },
      data: {
        value_json: toRiskLimitsJson(next),
        status: 'ACTIVE',
      },
      select: DEFAULT_LIMITS_SELECT,
    });

    return this.mapLimitsRow(updated);
  }

  private async getOrCreateDefaultLimitsRow() {
    const existing = await this.prisma.admin_risk_limits.findFirst({
      where: {
        scope: 'GLOBAL',
        scope_key: null,
        name: 'DEFAULT_LIMITS',
      },
      orderBy: [{ updated_at: 'desc' }],
      select: DEFAULT_LIMITS_SELECT,
    });

    if (existing) {
      return existing;
    }

    return this.prisma.admin_risk_limits.create({
      data: {
        scope: 'GLOBAL',
        scope_key: null,
        name: 'DEFAULT_LIMITS',
        value_json: toRiskLimitsJson(parseRiskLimits(null)),
        status: 'ACTIVE',
      },
      select: DEFAULT_LIMITS_SELECT,
    });
  }

  private validateLimits(limits: RiskLimits) {
    if (limits.minStake > limits.maxStake) {
      throw new BadRequestException('minStake cannot be greater than maxStake');
    }
  }

  private mapLimitsRow(
    row: Prisma.admin_risk_limitsGetPayload<{
      select: typeof DEFAULT_LIMITS_SELECT;
    }>,
  ) {
    return {
      id: row.id,
      scope: row.scope,
      scopeKey: row.scope_key,
      name: row.name,
      status: row.status,
      limits: parseRiskLimits(row.value_json),
      createdAt: row.created_at,
      updatedAt: row.updated_at,
    };
  }
}
