import { Controller, Get, Param, Query } from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { ListWalletsQueryDto } from './dto/list-wallets-query.dto';
import { WalletsService } from './wallets.service';

@ApiTags('Wallets')
@Controller('wallets')
export class WalletsController {
  constructor(private readonly walletsService: WalletsService) {}

  @Get()
  @ApiOperation({ summary: 'List wallets with pagination and filters' })
  @ApiOkResponse({ description: 'Paginated list of wallets' })
  @ApiBadRequestResponse({ description: 'Invalid query parameters' })
  async listWallets(@Query() query: ListWalletsQueryDto) {
    return this.walletsService.listWallets(query);
  }

  @Get('user/:userId')
  @ApiOperation({ summary: 'Get all wallets for a user' })
  @ApiParam({ name: 'userId', format: 'uuid' })
  @ApiOkResponse({ description: 'List of wallets for one user' })
  async getWalletsByUserId(@Param('userId') userId: string) {
    return this.walletsService.getWalletsByUserId(userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a wallet by id' })
  @ApiParam({ name: 'id', format: 'uuid' })
  @ApiOkResponse({ description: 'Wallet details' })
  async getWalletById(@Param('id') id: string) {
    return this.walletsService.getWalletById(id);
  }
}
