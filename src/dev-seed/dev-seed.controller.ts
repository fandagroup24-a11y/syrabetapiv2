import { Controller, Post, UseGuards } from '@nestjs/common';
import {
  ApiHeader,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AdminApiKeyGuard } from '../common/guards/admin-api-key.guard';
import { DevSeedService } from './dev-seed.service';

@ApiTags('Dev Seed')
@ApiHeader({
  name: 'x-admin-key',
  required: true,
  description: 'Admin API key',
})
@ApiUnauthorizedResponse({ description: 'Invalid admin API key' })
@UseGuards(AdminApiKeyGuard)
@Controller('dev/seed')
export class DevSeedController {
  constructor(private readonly devSeedService: DevSeedService) {}

  @Post('sportsbook')
  @ApiOperation({ summary: 'Seed sportsbook demo data' })
  @ApiOkResponse({
    description: 'Seed summary (created/updated entities and totals)',
  })
  async seedSportsbook() {
    return this.devSeedService.seedSportsbook();
  }
}
