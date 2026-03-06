import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import {
  ApiBody,
  ApiHeader,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AdminApiKeyGuard } from '../common/guards/admin-api-key.guard';
import { UpdateDefaultRiskLimitsDto } from './dto/update-default-risk-limits.dto';
import { AdminRiskService } from './admin-risk.service';

@ApiTags('Admin Risk')
@ApiHeader({
  name: 'x-admin-key',
  required: true,
  description: 'Admin API key',
})
@ApiUnauthorizedResponse({ description: 'Invalid admin API key' })
@UseGuards(AdminApiKeyGuard)
@Controller('admin/risk-limits')
export class AdminRiskController {
  constructor(private readonly adminRiskService: AdminRiskService) {}

  @Get('default')
  @ApiOperation({ summary: 'Get global default betting risk limits' })
  @ApiOkResponse({ description: 'Current default risk limits' })
  async getDefaultLimits() {
    return this.adminRiskService.getDefaultLimits();
  }

  @Put('default')
  @ApiOperation({ summary: 'Update global default betting risk limits' })
  @ApiBody({ type: UpdateDefaultRiskLimitsDto })
  @ApiOkResponse({ description: 'Updated default risk limits' })
  async updateDefaultLimits(@Body() dto: UpdateDefaultRiskLimitsDto) {
    return this.adminRiskService.updateDefaultLimits(dto);
  }
}
