import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('Meta')
@Controller()
export class AppController {
  @Get()
  @ApiOperation({ summary: 'Get basic API information' })
  @ApiOkResponse({
    description: 'Basic API metadata',
    schema: {
      example: {
        name: 'syrabet-backend-api',
        version: '1.0.0',
        docs: '/docs',
        health: '/api/health',
      },
    },
  })
  getInfo() {
    return {
      name: 'syrabet-backend-api',
      version: '1.0.0',
      docs: '/docs',
      health: '/api/health',
    };
  }
}
