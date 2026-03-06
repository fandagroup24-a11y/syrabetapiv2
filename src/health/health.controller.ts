import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiServiceUnavailableResponse,
  ApiTags,
} from '@nestjs/swagger';
import { PrismaService } from '../prisma/prisma.service';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @ApiOperation({ summary: 'Check API and MariaDB health' })
  @ApiOkResponse({
    description: 'Service and database are healthy',
    schema: {
      example: {
        status: 'ok',
        database: 'up',
        timestamp: '2026-03-05T01:20:00.000Z',
      },
    },
  })
  @ApiServiceUnavailableResponse({
    description: 'Database is unavailable',
    schema: {
      example: {
        statusCode: 503,
        message: {
          status: 'degraded',
          database: 'down',
          timestamp: '2026-03-05T01:20:00.000Z',
          error: 'Connection refused',
        },
        error: 'Service Unavailable',
      },
    },
  })
  async getHealth() {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return {
        status: 'ok',
        database: 'up',
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      throw new ServiceUnavailableException({
        status: 'degraded',
        database: 'down',
        timestamp: new Date().toISOString(),
        error:
          error instanceof Error ? error.message : 'Unknown database error',
      });
    }
  }
}
