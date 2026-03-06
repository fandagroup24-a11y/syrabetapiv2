Place your SQL dump here to auto-import it on first container startup.

Expected filename:
- `001_syrabet.sql`

Important:
- Auto-import from `/docker-entrypoint-initdb.d` happens only when the MariaDB data volume is empty.
- If the container was already started, run:
  1. `docker compose down -v`
  2. `docker compose up -d`
