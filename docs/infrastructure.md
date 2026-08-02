# Infrastructure (DigitalOcean)

Aligned with **ADR-001** (Linear): Hono API on DigitalOcean App Platform, PostgreSQL managed database, Clerk auth, Cloudflare CDN later.

## Resources

| Resource | Name | Notes |
| --- | --- | --- |
| App Platform app | `sailing-plans-api` | Serves `apps/api` (Hono) |
| Managed PostgreSQL (dev) | `sailing-plans-db` | App-attached DBaaS, smallest practical MVP size |
| Region | `nyc` | New York / closest available |

App Spec (source of truth in repo): [`infra/digitalocean/app.yaml`](../infra/digitalocean/app.yaml)

## Connection / environment variables

The API reads configuration from the environment (see [`apps/api/.env.example`](../apps/api/.env.example)).

| Variable | Required | Source | Notes |
| --- | --- | --- | --- |
| `DATABASE_URL` | Yes (runtime DB) | DO App Platform bind `${sailing-plans-db.DATABASE_URL}` | Prisma datasource URL |
| `PORT` | No (default `3001` locally) | App Spec sets `8080` | App Platform injects `PORT` when `http_port` is set |
| `NODE_ENV` | No | App Spec `production` | |
| `CLERK_SECRET_KEY` | Yes (when auth lands) | Clerk dashboard → DO secret | Placeholder `sk_test_replace_me` until wired |
| `CLERK_PUBLISHABLE_KEY` | Yes (clients / later API) | Clerk dashboard → DO secret | Placeholder `pk_test_replace_me` until wired |
| Cloudflare vars | Later | Cloudflare + DO | CDN / edge in front of App Platform; not required for API boot |

### Local development

```bash
cp apps/api/.env.example apps/api/.env
# Point DATABASE_URL at local Postgres or the DO connection string (trusted sources only)
pnpm --filter @sailing-plans/api db:generate
pnpm dev:api
```

### DigitalOcean dashboard

After the app is created:

1. Confirm `DATABASE_URL` is bound from the `sailing-plans-db` component (secret).
2. Replace Clerk placeholder secrets with real test/prod keys.
3. Note the live app URL from App Platform → Settings / Overview.
4. Leave Cloudflare for a follow-up (proxy / DNS once a custom domain exists).

## Apply / update the App Spec

```bash
# Create (first time)
doctl apps create --spec infra/digitalocean/app.yaml

# Update an existing app
doctl apps update <APP_ID> --spec infra/digitalocean/app.yaml
```

Do **not** delete existing DigitalOcean resources unless explicitly requested.

## Sizing (MVP)

- App service: `basic-xxs` (1 instance) — smallest practical App Platform size.
- Database: App Platform **dev** managed PostgreSQL (`production: false`) — smallest practical managed Postgres for MVP.
