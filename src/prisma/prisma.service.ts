import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '@prisma/client';
import type { PoolConfig } from 'pg';

const parseBooleanEnv = (value: string | undefined, fallback: boolean) => {
  if (value === undefined) {
    return fallback;
  }

  return ['1', 'true', 'yes', 'on'].includes(value.toLowerCase());
};

const normalizeConnectionString = (value: string) => {
  const url = new URL(value);
  // Keep SSL behavior under explicit env flags to avoid pg connection-string overrides.
  url.searchParams.delete('ssl');
  url.searchParams.delete('sslmode');
  url.searchParams.delete('sslcert');
  url.searchParams.delete('sslkey');
  url.searchParams.delete('sslrootcert');

  return url.toString();
};

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleDestroy {
  constructor() {
    const connectionString = process.env.DATABASE_URL;
    if (!connectionString) {
      throw new Error('DATABASE_URL is not set');
    }

    const sslEnabled = parseBooleanEnv(process.env.DATABASE_SSL_ENABLED, true);
    const rejectUnauthorized = parseBooleanEnv(
      process.env.DATABASE_SSL_REJECT_UNAUTHORIZED,
      false,
    );
    const poolConfig: PoolConfig = {
      connectionString: normalizeConnectionString(connectionString),
      ssl: sslEnabled ? { rejectUnauthorized } : false,
    };

    super({
      adapter: new PrismaPg(poolConfig),
    });
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
