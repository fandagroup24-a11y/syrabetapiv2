import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma, sportsbook_events_status } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ListEventsQueryDto } from './dto/list-events-query.dto';
import { ListLeaguesQueryDto } from './dto/list-leagues-query.dto';
import { ListMarketsQueryDto } from './dto/list-markets-query.dto';
import { ListSelectionsQueryDto } from './dto/list-selections-query.dto';
import { ListSportsQueryDto } from './dto/list-sports-query.dto';

const SPORT_SELECT = {
  id: true,
  code: true,
  name: true,
  status: true,
  created_at: true,
  _count: {
    select: {
      sportsbook_leagues: true,
      sportsbook_events: true,
    },
  },
} satisfies Prisma.sportsbook_sportsSelect;

const LEAGUE_SELECT = {
  id: true,
  sport_id: true,
  country_id: true,
  name: true,
  season: true,
  external_id: true,
  logo_url: true,
  display_order: true,
  status: true,
  created_at: true,
  sportsbook_sports: {
    select: {
      id: true,
      code: true,
      name: true,
      status: true,
    },
  },
  sportsbook_countries: {
    select: {
      id: true,
      code: true,
      name: true,
    },
  },
  _count: {
    select: {
      sportsbook_events: true,
    },
  },
} satisfies Prisma.sportsbook_leaguesSelect;

const EVENT_LIST_SELECT = {
  id: true,
  sport_id: true,
  league_id: true,
  home_team_id: true,
  away_team_id: true,
  name: true,
  event_type: true,
  start_time: true,
  status: true,
  live_clock: true,
  score_json: true,
  result_confirmed: true,
  external_id: true,
  created_at: true,
  updated_at: true,
  sportsbook_sports: {
    select: {
      id: true,
      code: true,
      name: true,
    },
  },
  sportsbook_leagues: {
    select: {
      id: true,
      name: true,
      season: true,
      status: true,
    },
  },
  sportsbook_teams_sportsbook_events_home_team_idTosportsbook_teams: {
    select: {
      id: true,
      name: true,
      short_name: true,
      logo_url: true,
    },
  },
  sportsbook_teams_sportsbook_events_away_team_idTosportsbook_teams: {
    select: {
      id: true,
      name: true,
      short_name: true,
      logo_url: true,
    },
  },
  _count: {
    select: {
      sportsbook_markets: true,
    },
  },
} satisfies Prisma.sportsbook_eventsSelect;

const EVENT_DETAILS_SELECT = {
  ...EVENT_LIST_SELECT,
  sportsbook_event_participants: {
    select: {
      id: true,
      role: true,
      display_order: true,
      draw_number: true,
      result_position: true,
      result_status: true,
      sportsbook_teams: {
        select: {
          id: true,
          name: true,
          short_name: true,
          logo_url: true,
          type: true,
        },
      },
    },
    orderBy: {
      display_order: 'asc',
    },
  },
} satisfies Prisma.sportsbook_eventsSelect;

const MARKET_BASE_SELECT = {
  id: true,
  event_id: true,
  market_type_id: true,
  name: true,
  line: true,
  margin: true,
  status: true,
  spec_json: true,
  result_json: true,
  settled_at: true,
  created_at: true,
  updated_at: true,
  sportsbook_market_types: {
    select: {
      id: true,
      code: true,
      name: true,
      has_line: true,
      status: true,
    },
  },
  _count: {
    select: {
      sportsbook_selections: true,
    },
  },
} satisfies Prisma.sportsbook_marketsSelect;

const MARKET_WITH_SELECTIONS_SELECT = {
  ...MARKET_BASE_SELECT,
  sportsbook_selections: {
    select: {
      id: true,
      name: true,
      odds: true,
      status: true,
      result: true,
      settled_at: true,
      updated_at: true,
    },
    orderBy: {
      name: 'asc',
    },
  },
} satisfies Prisma.sportsbook_marketsSelect;

const SELECTION_SELECT = {
  id: true,
  market_id: true,
  name: true,
  odds: true,
  result: true,
  settled_at: true,
  status: true,
  created_at: true,
  updated_at: true,
  sportsbook_markets: {
    select: {
      id: true,
      event_id: true,
      name: true,
      status: true,
      sportsbook_events: {
        select: {
          id: true,
          name: true,
          start_time: true,
          status: true,
        },
      },
    },
  },
} satisfies Prisma.sportsbook_selectionsSelect;

@Injectable()
export class SportsbookService {
  constructor(private readonly prisma: PrismaService) {}

  async listSports(query: ListSportsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const status = query.status?.trim().toUpperCase();
    const search = query.search?.trim();

    const where: Prisma.sportsbook_sportsWhereInput = {};

    if (status) {
      where.status = status;
    }

    if (search) {
      where.OR = [
        { code: { contains: search } },
        { name: { contains: search } },
      ];
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.sportsbook_sports.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ status: 'asc' }, { name: 'asc' }],
        select: SPORT_SELECT,
      }),
      this.prisma.sportsbook_sports.count({ where }),
    ]);

    return this.toPaginated(data, page, limit, total);
  }

  async listLeagues(query: ListLeaguesQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const status = query.status?.trim().toUpperCase();
    const search = query.search?.trim();

    const where: Prisma.sportsbook_leaguesWhereInput = {};

    if (query.sportId) {
      where.sport_id = query.sportId;
    }

    if (query.countryId) {
      where.country_id = query.countryId;
    }

    if (status) {
      where.status = status;
    }

    if (search) {
      where.name = { contains: search };
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.sportsbook_leagues.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ display_order: 'asc' }, { name: 'asc' }],
        select: LEAGUE_SELECT,
      }),
      this.prisma.sportsbook_leagues.count({ where }),
    ]);

    return this.toPaginated(data, page, limit, total);
  }

  async listEvents(query: ListEventsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const search = query.search?.trim();
    const live = this.parseBoolean(query.live);

    const where: Prisma.sportsbook_eventsWhereInput = {};

    if (query.sportId) {
      where.sport_id = query.sportId;
    }

    if (query.leagueId) {
      where.league_id = query.leagueId;
    }

    if (query.status) {
      where.status = query.status;
    }

    if (live === true) {
      where.status = sportsbook_events_status.LIVE;
    } else if (live === false) {
      where.NOT = { status: sportsbook_events_status.LIVE };
    }

    if (query.dateFrom || query.dateTo) {
      where.start_time = {
        gte: query.dateFrom ? new Date(query.dateFrom) : undefined,
        lte: query.dateTo ? new Date(query.dateTo) : undefined,
      };
    }

    if (search) {
      where.name = { contains: search };
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.sportsbook_events.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ start_time: 'asc' }, { created_at: 'desc' }],
        select: EVENT_LIST_SELECT,
      }),
      this.prisma.sportsbook_events.count({ where }),
    ]);

    return this.toPaginated(data, page, limit, total);
  }

  async getEventById(eventId: string) {
    const event = await this.prisma.sportsbook_events.findUnique({
      where: { id: eventId },
      select: EVENT_DETAILS_SELECT,
    });

    if (!event) {
      throw new NotFoundException(`Event not found: ${eventId}`);
    }

    return event;
  }

  async listMarketsByEventId(eventId: string, query: ListMarketsQueryDto) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const includeSelections =
      this.parseBoolean(query.includeSelections) === true;
    const status = query.status?.trim().toUpperCase();

    const eventExists = await this.prisma.sportsbook_events.findUnique({
      where: { id: eventId },
      select: { id: true },
    });

    if (!eventExists) {
      throw new NotFoundException(`Event not found: ${eventId}`);
    }

    const where: Prisma.sportsbook_marketsWhereInput = {
      event_id: eventId,
    };

    if (status) {
      where.status = status;
    }

    if (query.marketTypeId) {
      where.market_type_id = query.marketTypeId;
    }

    const select = includeSelections
      ? MARKET_WITH_SELECTIONS_SELECT
      : MARKET_BASE_SELECT;

    const [data, total] = await this.prisma.$transaction([
      this.prisma.sportsbook_markets.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ status: 'asc' }, { created_at: 'asc' }],
        select,
      }),
      this.prisma.sportsbook_markets.count({ where }),
    ]);

    return this.toPaginated(data, page, limit, total);
  }

  async getMarketById(marketId: string) {
    const market = await this.prisma.sportsbook_markets.findUnique({
      where: { id: marketId },
      select: {
        ...MARKET_WITH_SELECTIONS_SELECT,
        sportsbook_events: {
          select: {
            id: true,
            name: true,
            start_time: true,
            status: true,
            sport_id: true,
            league_id: true,
          },
        },
      },
    });

    if (!market) {
      throw new NotFoundException(`Market not found: ${marketId}`);
    }

    return market;
  }

  async listSelectionsByMarketId(
    marketId: string,
    query: ListSelectionsQueryDto,
  ) {
    const page = query.page;
    const limit = query.limit;
    const skip = (page - 1) * limit;
    const status = query.status?.trim().toUpperCase();

    const marketExists = await this.prisma.sportsbook_markets.findUnique({
      where: { id: marketId },
      select: { id: true },
    });

    if (!marketExists) {
      throw new NotFoundException(`Market not found: ${marketId}`);
    }

    const where: Prisma.sportsbook_selectionsWhereInput = {
      market_id: marketId,
    };

    if (status) {
      where.status = status;
    }

    if (query.result) {
      where.result = query.result;
    }

    const [data, total] = await this.prisma.$transaction([
      this.prisma.sportsbook_selections.findMany({
        where,
        skip,
        take: limit,
        orderBy: [{ status: 'asc' }, { name: 'asc' }],
        select: SELECTION_SELECT,
      }),
      this.prisma.sportsbook_selections.count({ where }),
    ]);

    return this.toPaginated(data, page, limit, total);
  }

  private toPaginated<T>(
    data: T[],
    page: number,
    limit: number,
    total: number,
  ) {
    return {
      data,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  private parseBoolean(value?: string) {
    if (!value) {
      return undefined;
    }
    const normalized = value.trim().toLowerCase();
    if (normalized === 'true') {
      return true;
    }
    if (normalized === 'false') {
      return false;
    }
    return undefined;
  }
}
