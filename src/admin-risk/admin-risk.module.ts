import { Module } from '@nestjs/common';
import { AdminApiKeyGuard } from '../common/guards/admin-api-key.guard';
import { AdminRiskController } from './admin-risk.controller';
import { AdminRiskService } from './admin-risk.service';

@Module({
  controllers: [AdminRiskController],
  providers: [AdminRiskService, AdminApiKeyGuard],
  exports: [AdminRiskService],
})
export class AdminRiskModule {}
