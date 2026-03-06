import { Module } from '@nestjs/common';
import { AdminApiKeyGuard } from '../common/guards/admin-api-key.guard';
import { DevSeedController } from './dev-seed.controller';
import { DevSeedService } from './dev-seed.service';

@Module({
  controllers: [DevSeedController],
  providers: [DevSeedService, AdminApiKeyGuard],
})
export class DevSeedModule {}
