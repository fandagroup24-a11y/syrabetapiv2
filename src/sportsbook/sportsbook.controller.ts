import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { AccessTokenGuard } from '../auth/guards/access-token.guard';
import { ListEventsQueryDto } from './dto/list-events-query.dto';
import { ListLeaguesQueryDto } from './dto/list-leagues-query.dto';
import { ListMarketsQueryDto } from './dto/list-markets-query.dto';
import { ListSelectionsQueryDto } from './dto/list-selections-query.dto';
import { ListSportsQueryDto } from './dto/list-sports-query.dto';
import { SportsbookService } from './sportsbook.service';

@ApiTags('Sportsbook')
@ApiBearerAuth()
@ApiUnauthorizedResponse({ description: 'Invalid or expired access token' })
@UseGuards(AccessTokenGuard)
@Controller('sportsbook')
export class SportsbookController {
  constructor(private readonly sportsbookService: SportsbookService) {}

  @Get('sports')
  @ApiOperation({ summary: 'List sports' })
  @ApiOkResponse({ description: 'Paginated sports list' })
  async listSports(@Query() query: ListSportsQueryDto) {
    return this.sportsbookService.listSports(query);
  }

  @Get('leagues')
  @ApiOperation({ summary: 'List leagues' })
  @ApiOkResponse({ description: 'Paginated leagues list' })
  async listLeagues(@Query() query: ListLeaguesQueryDto) {
    return this.sportsbookService.listLeagues(query);
  }

  @Get('events')
  @ApiOperation({ summary: 'List events' })
  @ApiOkResponse({ description: 'Paginated events list' })
  async listEvents(@Query() query: ListEventsQueryDto) {
    return this.sportsbookService.listEvents(query);
  }

  @Get('events/:eventId')
  @ApiOperation({ summary: 'Get event details by id' })
  @ApiParam({ name: 'eventId', format: 'uuid' })
  @ApiOkResponse({ description: 'Event details' })
  async getEventById(@Param('eventId') eventId: string) {
    return this.sportsbookService.getEventById(eventId);
  }

  @Get('events/:eventId/markets')
  @ApiOperation({ summary: 'List markets for an event' })
  @ApiParam({ name: 'eventId', format: 'uuid' })
  @ApiOkResponse({ description: 'Paginated markets list' })
  async listMarketsByEventId(
    @Param('eventId') eventId: string,
    @Query() query: ListMarketsQueryDto,
  ) {
    return this.sportsbookService.listMarketsByEventId(eventId, query);
  }

  @Get('markets/:marketId')
  @ApiOperation({ summary: 'Get market details by id' })
  @ApiParam({ name: 'marketId', format: 'uuid' })
  @ApiOkResponse({ description: 'Market details' })
  async getMarketById(@Param('marketId') marketId: string) {
    return this.sportsbookService.getMarketById(marketId);
  }

  @Get('markets/:marketId/selections')
  @ApiOperation({ summary: 'List selections for a market' })
  @ApiParam({ name: 'marketId', format: 'uuid' })
  @ApiOkResponse({ description: 'Paginated selections list' })
  async listSelectionsByMarketId(
    @Param('marketId') marketId: string,
    @Query() query: ListSelectionsQueryDto,
  ) {
    return this.sportsbookService.listSelectionsByMarketId(marketId, query);
  }
}
