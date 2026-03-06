import {
  PrismaClient,
  sportsbook_events_event_type,
  sportsbook_events_status,
  sportsbook_teams_type,
} from '@prisma/client';

type LeagueInput = {
  externalId: string;
  sportId: string;
  countryId: string | null;
  name: string;
  season: string;
  displayOrder: number;
};

type TeamInput = {
  externalId: string;
  sportId: string;
  countryId: string | null;
  name: string;
  shortName: string;
};

type EventInput = {
  externalId: string;
  sportId: string;
  leagueId: string;
  homeTeamId: string;
  awayTeamId: string;
  name: string;
  startTime: Date;
};

type MarketInput = {
  eventId: string;
  marketTypeId: string;
  name: string;
  line?: number;
};

type SelectionInput = {
  marketId: string;
  name: string;
  odds: number;
};

export type SportsbookSeedResult = {
  seeded: true;
  footballEventId: string;
  basketballEventId: string;
  footballMarketId: string;
  basketballMarketId: string;
  totals: {
    events: number;
    markets: number;
    selections: number;
  };
};

async function ensureLeague(prisma: PrismaClient, input: LeagueInput) {
  const existing = await prisma.sportsbook_leagues.findFirst({
    where: { external_id: input.externalId },
    select: { id: true },
  });

  if (existing) {
    return prisma.sportsbook_leagues.update({
      where: { id: existing.id },
      data: {
        sport_id: input.sportId,
        country_id: input.countryId,
        name: input.name,
        season: input.season,
        display_order: input.displayOrder,
        status: 'ACTIVE',
      },
    });
  }

  return prisma.sportsbook_leagues.create({
    data: {
      sport_id: input.sportId,
      country_id: input.countryId,
      name: input.name,
      season: input.season,
      external_id: input.externalId,
      display_order: input.displayOrder,
      status: 'ACTIVE',
    },
  });
}

async function ensureTeam(prisma: PrismaClient, input: TeamInput) {
  const existing = await prisma.sportsbook_teams.findFirst({
    where: { external_id: input.externalId },
    select: { id: true },
  });

  if (existing) {
    return prisma.sportsbook_teams.update({
      where: { id: existing.id },
      data: {
        sport_id: input.sportId,
        country_id: input.countryId,
        type: sportsbook_teams_type.TEAM,
        name: input.name,
        short_name: input.shortName,
        status: 'ACTIVE',
      },
    });
  }

  return prisma.sportsbook_teams.create({
    data: {
      sport_id: input.sportId,
      country_id: input.countryId,
      type: sportsbook_teams_type.TEAM,
      name: input.name,
      short_name: input.shortName,
      external_id: input.externalId,
      status: 'ACTIVE',
    },
  });
}

async function ensureEvent(prisma: PrismaClient, input: EventInput) {
  const existing = await prisma.sportsbook_events.findFirst({
    where: { external_id: input.externalId },
    select: { id: true },
  });

  if (existing) {
    return prisma.sportsbook_events.update({
      where: { id: existing.id },
      data: {
        sport_id: input.sportId,
        league_id: input.leagueId,
        home_team_id: input.homeTeamId,
        away_team_id: input.awayTeamId,
        name: input.name,
        event_type: sportsbook_events_event_type.HEAD_TO_HEAD,
        start_time: input.startTime,
        status: sportsbook_events_status.SCHEDULED,
        result_confirmed: false,
      },
    });
  }

  return prisma.sportsbook_events.create({
    data: {
      sport_id: input.sportId,
      league_id: input.leagueId,
      home_team_id: input.homeTeamId,
      away_team_id: input.awayTeamId,
      name: input.name,
      event_type: sportsbook_events_event_type.HEAD_TO_HEAD,
      start_time: input.startTime,
      status: sportsbook_events_status.SCHEDULED,
      external_id: input.externalId,
      result_confirmed: false,
    },
  });
}

async function ensureMarket(prisma: PrismaClient, input: MarketInput) {
  const existing = await prisma.sportsbook_markets.findFirst({
    where: {
      event_id: input.eventId,
      market_type_id: input.marketTypeId,
      line: input.line ?? null,
    },
    select: { id: true },
  });

  if (existing) {
    return prisma.sportsbook_markets.update({
      where: { id: existing.id },
      data: {
        name: input.name,
        line: input.line ?? null,
        status: 'OPEN',
      },
    });
  }

  return prisma.sportsbook_markets.create({
    data: {
      event_id: input.eventId,
      market_type_id: input.marketTypeId,
      name: input.name,
      line: input.line ?? null,
      status: 'OPEN',
    },
  });
}

async function ensureSelection(prisma: PrismaClient, input: SelectionInput) {
  const existing = await prisma.sportsbook_selections.findFirst({
    where: {
      market_id: input.marketId,
      name: input.name,
    },
    select: { id: true },
  });

  if (existing) {
    return prisma.sportsbook_selections.update({
      where: { id: existing.id },
      data: {
        odds: input.odds,
        status: 'OPEN',
        result: 'PENDING',
      },
    });
  }

  return prisma.sportsbook_selections.create({
    data: {
      market_id: input.marketId,
      name: input.name,
      odds: input.odds,
      status: 'OPEN',
      result: 'PENDING',
    },
  });
}

export async function seedSportsbook(prisma: PrismaClient) {
  const football = await prisma.sportsbook_sports.upsert({
    where: { code: 'football' },
    update: { name: 'Football', status: 'ACTIVE' },
    create: { code: 'football', name: 'Football', status: 'ACTIVE' },
  });

  const basketball = await prisma.sportsbook_sports.upsert({
    where: { code: 'basketball' },
    update: { name: 'Basketball', status: 'ACTIVE' },
    create: { code: 'basketball', name: 'Basketball', status: 'ACTIVE' },
  });

  const france = await prisma.sportsbook_countries.findUnique({
    where: { code: 'FR' },
    select: { id: true },
  });
  const ivoryCoast = await prisma.sportsbook_countries.findUnique({
    where: { code: 'CI' },
    select: { id: true },
  });

  const footballLeague = await ensureLeague(prisma, {
    externalId: 'seed:league:football:l1',
    sportId: football.id,
    countryId: france?.id ?? null,
    name: 'Ligue Seed Football',
    season: '2026',
    displayOrder: 1,
  });
  const basketballLeague = await ensureLeague(prisma, {
    externalId: 'seed:league:basketball:l1',
    sportId: basketball.id,
    countryId: ivoryCoast?.id ?? null,
    name: 'Ligue Seed Basketball',
    season: '2026',
    displayOrder: 1,
  });

  const arsenal = await ensureTeam(prisma, {
    externalId: 'seed:team:football:arsenal',
    sportId: football.id,
    countryId: france?.id ?? null,
    name: 'Arsenal',
    shortName: 'ARS',
  });
  const chelsea = await ensureTeam(prisma, {
    externalId: 'seed:team:football:chelsea',
    sportId: football.id,
    countryId: france?.id ?? null,
    name: 'Chelsea',
    shortName: 'CHE',
  });

  const lakers = await ensureTeam(prisma, {
    externalId: 'seed:team:basketball:lakers',
    sportId: basketball.id,
    countryId: ivoryCoast?.id ?? null,
    name: 'Lakers',
    shortName: 'LAL',
  });
  const celtics = await ensureTeam(prisma, {
    externalId: 'seed:team:basketball:celtics',
    sportId: basketball.id,
    countryId: ivoryCoast?.id ?? null,
    name: 'Celtics',
    shortName: 'BOS',
  });

  const now = Date.now();
  const footballEvent = await ensureEvent(prisma, {
    externalId: 'seed:event:football:arsenal-chelsea',
    sportId: football.id,
    leagueId: footballLeague.id,
    homeTeamId: arsenal.id,
    awayTeamId: chelsea.id,
    name: 'Arsenal vs Chelsea',
    startTime: new Date(now + 24 * 60 * 60 * 1000),
  });
  const basketballEvent = await ensureEvent(prisma, {
    externalId: 'seed:event:basketball:lakers-celtics',
    sportId: basketball.id,
    leagueId: basketballLeague.id,
    homeTeamId: lakers.id,
    awayTeamId: celtics.id,
    name: 'Lakers vs Celtics',
    startTime: new Date(now + 48 * 60 * 60 * 1000),
  });

  const footballMatchResultType =
    await prisma.sportsbook_market_types.findUnique({
      where: {
        sport_id_code: {
          sport_id: football.id,
          code: '1X2',
        },
      },
      select: { id: true },
    });
  if (!footballMatchResultType) {
    throw new Error('Missing market type 1X2 for football');
  }

  const basketballMoneyLineType =
    await prisma.sportsbook_market_types.findUnique({
      where: {
        sport_id_code: {
          sport_id: basketball.id,
          code: 'MONEY_LINE',
        },
      },
      select: { id: true },
    });
  if (!basketballMoneyLineType) {
    throw new Error('Missing market type MONEY_LINE for basketball');
  }

  const footballMarket = await ensureMarket(prisma, {
    eventId: footballEvent.id,
    marketTypeId: footballMatchResultType.id,
    name: 'Résultat du match',
  });
  await Promise.all([
    ensureSelection(prisma, {
      marketId: footballMarket.id,
      name: 'Domicile',
      odds: 2.1,
    }),
    ensureSelection(prisma, {
      marketId: footballMarket.id,
      name: 'Nul',
      odds: 3.25,
    }),
    ensureSelection(prisma, {
      marketId: footballMarket.id,
      name: 'Extérieur',
      odds: 3.1,
    }),
  ]);

  const basketballMarket = await ensureMarket(prisma, {
    eventId: basketballEvent.id,
    marketTypeId: basketballMoneyLineType.id,
    name: 'Vainqueur du match',
  });
  await Promise.all([
    ensureSelection(prisma, {
      marketId: basketballMarket.id,
      name: 'Domicile',
      odds: 1.85,
    }),
    ensureSelection(prisma, {
      marketId: basketballMarket.id,
      name: 'Extérieur',
      odds: 1.95,
    }),
  ]);

  const [eventsCount, marketsCount, selectionsCount] = await Promise.all([
    prisma.sportsbook_events.count(),
    prisma.sportsbook_markets.count(),
    prisma.sportsbook_selections.count(),
  ]);

  return {
    seeded: true,
    footballEventId: footballEvent.id,
    basketballEventId: basketballEvent.id,
    footballMarketId: footballMarket.id,
    basketballMarketId: basketballMarket.id,
    totals: {
      events: eventsCount,
      markets: marketsCount,
      selections: selectionsCount,
    },
  } satisfies SportsbookSeedResult;
}
