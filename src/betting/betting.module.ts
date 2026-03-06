import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { BettingController } from './betting.controller';
import { BettingService } from './betting.service';

@Module({
  imports: [AuthModule],
  controllers: [BettingController],
  providers: [BettingService],
})
export class BettingModule {}
