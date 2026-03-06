import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import type { Request } from 'express';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { AccessTokenPayload } from '../auth/types/access-token-payload.type';
import { BettingService } from './betting.service';
import { ListBetsQueryDto } from './dto/list-bets-query.dto';
import { PlaceBetDto } from './dto/place-bet.dto';

type AuthenticatedRequest = Request & {
  auth?: AccessTokenPayload;
};

@ApiTags('Betting')
@ApiBearerAuth()
@ApiUnauthorizedResponse({ description: 'Invalid or expired access token' })
@UseGuards(AccessTokenGuard)
@Controller('betting/bets')
export class BettingController {
  constructor(private readonly bettingService: BettingService) {}

  @Post('place')
  @ApiOperation({ summary: 'Place a bet (single or acca)' })
  @ApiCreatedResponse({
    description: 'Bet placed, wallet debited and ledger entry created',
  })
  @ApiBody({ type: PlaceBetDto })
  async placeBet(@Req() req: AuthenticatedRequest, @Body() dto: PlaceBetDto) {
    if (!req.auth) {
      throw new UnauthorizedException('Missing authentication payload');
    }
    return this.bettingService.placeBet(req.auth.sub, dto);
  }

  @Get()
  @ApiOperation({ summary: 'List bets' })
  @ApiOkResponse({ description: 'Paginated bets list' })
  async listBets(
    @Req() req: AuthenticatedRequest,
    @Query() query: ListBetsQueryDto,
  ) {
    if (!req.auth) {
      throw new UnauthorizedException('Missing authentication payload');
    }
    return this.bettingService.listBets(req.auth.sub, query);
  }

  @Get(':betId')
  @ApiOperation({ summary: 'Get bet details by id' })
  @ApiParam({ name: 'betId', format: 'uuid' })
  @ApiOkResponse({ description: 'Bet details with legs' })
  async getBetById(
    @Req() req: AuthenticatedRequest,
    @Param('betId') betId: string,
  ) {
    if (!req.auth) {
      throw new UnauthorizedException('Missing authentication payload');
    }
    return this.bettingService.getBetById(req.auth.sub, betId);
  }
}
