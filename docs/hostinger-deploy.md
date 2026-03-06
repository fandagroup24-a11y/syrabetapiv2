# Hostinger Deployment (Node.js 20.x)

## Required build settings

Use these values in Hostinger Node app settings:

- Install command: `npm ci`
- Build command: `npm run build`
- Start command: `npm run start`
- Node version: `20.x`

`npm run start` now runs `node dist/src/main.js`.

## Required environment variables

Set these in Hostinger environment variables:

- `HOST=0.0.0.0`
- `PORT=3000` (or keep Hostinger provided port)
- `DATABASE_URL=postgresql://...` (Supabase runtime URL)
- `SUPABASE_DIRECT_URL=postgresql://...` (direct URL for Prisma tooling)
- `JWT_ACCESS_SECRET=...`
- `JWT_ACCESS_EXPIRES_IN_SEC=900`
- `JWT_REFRESH_EXPIRES_IN_DAYS=30`
- `ADMIN_API_KEY=...`

## Health checks

After deployment:

- `GET /api/health`
- `GET /docs`

If `/api/health` is OK, database connectivity and Prisma initialization are valid.

## Common deployment failure fixed

If you see:

- `Invalid prisma.$queryRaw() invocation`
- `the URL must start with the protocol mysql://`

this means Prisma datasource/provider and `DATABASE_URL` protocol were mismatched.

The project is now aligned for Supabase PostgreSQL (`provider = "postgresql"`).
