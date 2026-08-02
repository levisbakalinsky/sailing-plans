# AGENTS.md

## Cursor Cloud specific instructions

This is a pnpm + Turborepo monorepo (`sailing-plans`). Standard commands live in the root `README.md` and `package.json` scripts; prefer those. Notes below are the non-obvious bits.

### Services

- `apps/api` (`@sailing-plans/api`) — Hono REST API, the only runnable/testable service today. Run with `pnpm dev:api` (root) which uses `tsx watch` (hot reload). Listens on `http://localhost:3001`; health check is `GET /health`. Verify with `curl -s http://localhost:3001/health`.
- `apps/web` and `apps/mobile` are scaffold placeholders — their `dev`/`build`/`test`/`typecheck`/`lint` scripts just `echo`. There is nothing to run there yet.
- `packages/api-contract` is a build-time dependency (OpenAPI + generated TS types), not a runtime service. Turbo's `build`/`test`/`typecheck` tasks depend on `^build`, so it is built first automatically.

### Non-obvious caveats

- The API runtime does NOT require PostgreSQL or Clerk. `DATABASE_URL` is `.optional()` in `apps/api/src/env.ts`, `@prisma/client` is not imported anywhere in source, and Clerk keys are unused. So the API boots and all checks pass with no database and no auth provider.
- `apps/api/.env` is gitignored and does not exist on a fresh checkout. It is only needed for the Prisma DB scripts (`db:migrate`, `db:push`, `db:studio`) that connect to a real database. Create it with `cp apps/api/.env.example apps/api/.env` when doing DB work.
- `prisma generate` (run via the startup update script as `pnpm --filter @sailing-plans/api db:generate`) does NOT need a database connection or a populated `DATABASE_URL`; it only reads `apps/api/prisma/schema.prisma`.
- Root `pnpm lint` currently only runs `echo` placeholders — there is no real linter configured in any package yet.
