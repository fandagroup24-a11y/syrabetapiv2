import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { SportsbookController } from './sportsbook.controller';
import { SportsbookService } from './sportsbook.service';

@Module({
  imports: [AuthModule],
  controllers: [SportsbookController],
  providers: [SportsbookService],
})
export class SportsbookModule {}
