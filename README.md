# Syrabet Backend API

Backend stack:
- NestJS
- Prisma ORM
- MariaDB
- Swagger (`/docs`)

## 1) Install

Requirements:
- Node.js `24+`

```bash
npm install
```

## 2) Database connection

Default local config (`.env`):
- `PORT=3000`
- `DATABASE_URL=mysql://root:root@127.0.0.1:8889/syrabet`
- `JWT_ACCESS_SECRET=change-me-access-secret`
- `JWT_ACCESS_EXPIRES_IN_SEC=900`
- `JWT_REFRESH_EXPIRES_IN_DAYS=30`
- `ADMIN_API_KEY=change-me-admin-key`

If needed, use `.env.example` as a template.

## 3) Prisma sync with DB

```bash
npm run prisma:pull
npm run prisma:generate
```

Current status:
- Introspection completed from `syrabet`
- `62` models detected in `prisma/schema.prisma`

Notes:
- Prisma introspection does not model triggers and views as first-class Prisma models.
- SQL schema remains source of truth for triggers, views and check constraints.

## 4) Run API

```bash
npm run start:dev
```

Endpoints:
- API root: `http://localhost:3000/api`
- Health: `http://localhost:3000/api/health`
- Swagger: `http://localhost:3000/docs`

## 5) Seed sportsbook test data

```bash
npm run seed:sportsbook
```

This creates or updates a minimal multisport dataset (football + basketball):
- leagues
- teams
- future events
- open markets
- open selections

## Implemented modules

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/auth/me`
- `GET /api/sportsbook/sports`
- `GET /api/sportsbook/leagues`
- `GET /api/sportsbook/events`
- `GET /api/sportsbook/events/:eventId`
- `GET /api/sportsbook/events/:eventId/markets`
- `GET /api/sportsbook/markets/:marketId`
- `GET /api/sportsbook/markets/:marketId/selections`
- `POST /api/betting/bets/place`
- `GET /api/betting/bets`
- `GET /api/betting/bets/:betId`
- `GET /api/admin/risk-limits/default`
- `PUT /api/admin/risk-limits/default`
- `POST /api/dev/seed/sportsbook`
- `GET /api/users`
- `GET /api/users/:id`
- `GET /api/wallets`
- `GET /api/wallets/:id`
- `GET /api/wallets/user/:userId`
- `POST /api/wallet-transactions/deposit`
- `POST /api/wallet-transactions/withdraw`
- `POST /api/wallet-transactions/withdrawals/:withdrawalId/approve`
- `POST /api/wallet-transactions/withdrawals/:withdrawalId/reject`
- `POST /api/wallet-transactions/ledger/:ledgerEntryId/reverse`
- `GET /api/wallet-transactions/ledger`
- `GET /api/wallet-transactions/payments`
- `GET /api/wallet-transactions/withdrawals`

Auth notes:
- `sportsbook/*` and `betting/*` now require `Authorization: Bearer <accessToken>`.
- `POST /api/betting/bets/place` now uses the authenticated user from token (no `userId` in request body).
- `POST /api/betting/bets/place` enforces global default risk limits from `admin_risk_limits` (`min_stake`, `max_stake`, `max_payout`, `cooldown_place_bet_sec`).
- `admin/risk-limits/*` and `dev/seed/*` require `x-admin-key: <ADMIN_API_KEY>`.

## Optional: local Docker MariaDB

If Docker is available on your machine, you can still use:

```bash
npm run db:up
```

Dump location:
- `docker/mariadb/init/001_syrabet.sql`
# syrabetapi
