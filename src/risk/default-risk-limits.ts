import { Prisma } from '@prisma/client';

export const DEFAULT_RISK_LIMITS = {
  minStake: 200,
  maxStake: 500000,
  maxPayout: 5000000,
  cooldownPlaceBetSec: 3,
} as const;

export type RiskLimits = {
  minStake: number;
  maxStake: number;
  maxPayout: number;
  cooldownPlaceBetSec: number;
};

function toFiniteNumber(value: unknown, fallback: number) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === 'string') {
    const parsed = Number(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }
  return fallback;
}

function asRecord(value: Prisma.JsonValue | null | undefined) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

export function parseRiskLimits(value: Prisma.JsonValue | null | undefined) {
  const record = asRecord(value);
  return {
    minStake: toFiniteNumber(record?.min_stake, DEFAULT_RISK_LIMITS.minStake),
    maxStake: toFiniteNumber(record?.max_stake, DEFAULT_RISK_LIMITS.maxStake),
    maxPayout: toFiniteNumber(
      record?.max_payout,
      DEFAULT_RISK_LIMITS.maxPayout,
    ),
    cooldownPlaceBetSec: Math.max(
      0,
      Math.floor(
        toFiniteNumber(
          record?.cooldown_place_bet_sec,
          DEFAULT_RISK_LIMITS.cooldownPlaceBetSec,
        ),
      ),
    ),
  } satisfies RiskLimits;
}

export function toRiskLimitsJson(limits: RiskLimits): Prisma.InputJsonValue {
  return {
    min_stake: limits.minStake,
    max_stake: limits.maxStake,
    max_payout: limits.maxPayout,
    cooldown_place_bet_sec: limits.cooldownPlaceBetSec,
  };
}
