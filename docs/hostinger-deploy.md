# Hostinger Deployment (Node.js 24.x)

## Required build settings

Use these values in Hostinger Node app settings:

- Install command: `npm ci`
- Build command: `npm run build`
- Start command: `npm run start`
- Node version: `24.x`

`npm run start` now runs `node dist/src/main.js`.

## Required environment variables

Set these in Hostinger environment variables:

- `HOST=0.0.0.0`
- `PORT=3000` (or keep Hostinger provided port)
- `DATABASE_URL=postgresql://postgres.[PROJECT-REF]:[URL_ENCODED_PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1`
- `DATABASE_SSL_ENABLED=true`
- `DATABASE_SSL_REJECT_UNAUTHORIZED=false`
- `SUPABASE_DIRECT_URL=postgresql://postgres:[URL_ENCODED_PASSWORD]@db.[PROJECT-REF].supabase.co:5432/postgres?sslmode=require` (optional, only for Prisma tooling like `db pull`)
- `JWT_ACCESS_SECRET=...`
- `JWT_ACCESS_EXPIRES_IN_SEC=900`
- `JWT_REFRESH_EXPIRES_IN_DAYS=30`
- `ADMIN_API_KEY=...`

## Health checks

After deployment:

- `GET /api/health`
- `GET /docs`

If `/api/health` is OK, database connectivity and Prisma initialization are valid.

Notes:
- Use the exact pooler host from Supabase dashboard (`aws-0-[REGION].pooler.supabase.com`), not `[PROJECT-REF].pooler.supabase.com`.
- URL-encode password special characters (example: `@` becomes `%40`).
- If you get `self-signed certificate in certificate chain`, keep `DATABASE_SSL_ENABLED=true` and set `DATABASE_SSL_REJECT_UNAUTHORIZED=false`.

## Common deployment failure fixed

If you see:

- `Invalid prisma.$queryRaw() invocation`
- `the URL must start with the protocol mysql://`

this means Prisma datasource/provider and `DATABASE_URL` protocol were mismatched.

The project is now aligned for Supabase PostgreSQL (`provider = "postgresql"`).
