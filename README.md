# Sailing Plans

Multi-platform product monorepo: API, web, and mobile.

## Stack

| Layer | Choice |
| --- | --- |
| Backend | Hono + Prisma + PostgreSQL |
| Auth | Clerk |
| Web | Next.js |
| Mobile | Expo (iOS + Android) |
| CDN | Cloudflare |
| Host | DigitalOcean |
| Repo | pnpm + Turborepo |

Architecture ADR lives in Linear: **ADR-001**.

## Repo layout

```
apps/
  api/             # Hono REST API
  web/             # Next.js web app
  mobile/          # Expo iOS + Android
packages/
  api-contract/    # OpenAPI source of truth + generated types
  typescript-config/
```

## Prerequisites

- Node.js 22+
- pnpm 11+
- PostgreSQL (local or DigitalOcean Managed)

## Setup

```bash
pnpm install
cp apps/api/.env.example apps/api/.env
# Edit DATABASE_URL in apps/api/.env
pnpm --filter @sailing-plans/api db:generate
pnpm dev:api
```

Health check: `GET http://localhost:3001/health`

## Scripts

| Command | Description |
| --- | --- |
| `pnpm dev:api` | Run API in watch mode |
| `pnpm build` | Build all packages |
| `pnpm typecheck` | Typecheck all packages |
| `pnpm test` | Run tests |

## Linear

Team: **Sailing Plans** (`SP`)  
Foundation issue: [SP-1](https://linear.app/bakalinsky/issue/SP-1)
