import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AdminRiskModule } from './admin-risk/admin-risk.module';
import { BettingModule } from './betting/betting.module';
import { DevSeedModule } from './dev-seed/dev-seed.module';
import { HealthModule } from './health/health.module';
import { AppController } from './app.controller';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { SportsbookModule } from './sportsbook/sportsbook.module';
import { UsersModule } from './users/users.module';
import { WalletTransactionsModule } from './wallet-transactions/wallet-transactions.module';
import { WalletsModule } from './wallets/wallets.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AdminRiskModule,
    DevSeedModule,
    HealthModule,
    AuthModule,
    SportsbookModule,
    BettingModule,
    UsersModule,
    WalletsModule,
    WalletTransactionsModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
