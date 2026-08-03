# Infrastructure (Terraform)

Corporate-style Infrastructure-as-Code for Sailing Plans on DigitalOcean + Cloudflare.

## Layout

```
infra/terraform/
  modules/
    app_pool/          # Droplet Autoscale Pool + Load Balancer + firewall
    cloudflare_dns/    # Apex/www DNS + SSL settings → Load Balancer
    app_host/          # Legacy single Droplet (staging scaffold only)
    postgres/          # Managed Postgres + DB firewall
    valkey/            # Managed Valkey (Redis-compatible) + firewall
  environments/
    dev/               # Development root module (applied)
    staging/           # Scaffold only (not applied)
```

**Ownership split**

| Concern | Tool |
| --- | --- |
| LB, firewalls, tags, Postgres, Valkey, pool *definitions* | Terraform |
| Day-to-day idle pool create/delete + LB cutovers | GitHub Actions (Ship / Ops) |
| Cloudflare DNS (apex/www → LB) + SSL mode | Terraform (`cloudflare_dns`) |
| `.net`/`.org` → `.com` 301 redirects | Cloudflare Single Redirects (dashboard) + Caddyfile backup |
| DB migrations | `Migrate DB (Development)` (before ship when schema changes) |
| App ship + release history | `Ship (Development)` / `Release history (Development)` |
| New pool member bootstrap | cloud-init (`app_pool` user-data) |

Green pool: apply does **not** recreate a missing green pool unless it is live, already present, or `ensure_green_pool=true`. Ship creates the idle color when shipping.

Developers: [`docs/shipping.md`](../../docs/shipping.md). Ops detail: [`docs/deploy-ops.md`](../../docs/deploy-ops.md).

## Prerequisites

- Terraform `>= 1.5`
- `DIGITALOCEAN_TOKEN` in the environment
- `CLOUDFLARE_API_TOKEN` (Zone DNS Edit + Zone Settings Edit on sailingplans zones)
- Existing DO SSH key named `sailing-plans-do-deploy` (or override `ssh_key_name`)
- Optional: `TF_VAR_ghcr_pull_token` / `GHCR_PULL_TOKEN` for GHCR login on Droplet boot (packages are public; token is a bootstrap fallback)

## Dev workflow

```bash
cd infra/terraform/environments/dev
export DIGITALOCEAN_TOKEN=...
export CLOUDFLARE_API_TOKEN=...
export TF_VAR_ghcr_pull_token=...   # optional if GHCR packages are public
terraform init -backend-config=backend.hcl
terraform fmt -recursive ../..
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

## Remote state

- Bucket: `sailing-plans-tfstate` (nyc3)
- Key: `env/dev/terraform.tfstate`
- Config: `environments/dev/backend.hcl`

## CI

Workflow: `.github/workflows/terraform-dev.yml`

| Secret | Purpose |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | Provider auth + deploy host discovery |
| `CLOUDFLARE_API_TOKEN` | DNS + SSL settings |
| `DROPLET_USER` / `DROPLET_SSH_KEY` | SSH to pool members |
| `LOADBALANCER_IP` | Public health checks after deploy |
| `GHCR_PULL_TOKEN` | Optional `TF_VAR_ghcr_pull_token` for user-data pulls |
| `SPACES_ACCESS_KEY_ID` / `SPACES_SECRET_ACCESS_KEY` | Spaces remote state |

## Cloudflare (dev)

Public hostnames (proxied) point at the DO Load Balancer:

- https://www.sailingplans.com (apex `sailingplans.com` 301 → www)
- https://sailingplans.net / https://www.sailingplans.net → **301** → `www.sailingplans.com`
- https://sailingplans.org / https://www.sailingplans.org → **301** → `www.sailingplans.com`

Terraform manages:

- A records (apex + www)
- Zone SSL = **flexible**, Always Use HTTPS = **on**, min TLS 1.2

Single Redirect rules (edge 301s) are configured in the Cloudflare dashboard (API tokens on this account cannot manage the dynamic-redirect ruleset). The deploy `Caddyfile` also redirects alternate TLDs as defense in depth.

## Blue/green autoscale (dev)

| Setting | Default |
| --- | --- |
| Active color min / max | 2 / 4 |
| Idle color | Deleted by Ship after successful cutover (fix-forward; no rollback pool) |
| Size | `s-2vcpu-4gb` |
| CPU target | 0.7 |
| Cooldown | 10 minutes |
| LB | `lb-small`, HTTP `:80` → `:80`, health `/health`; tag flipped by CI |
| Shared tag | `sailing-plans-app-dev-pool` (DB/Valkey/firewall) |
| Color tags | `…-pool-blue`, `…-pool-green` |

**Ownership split:** Terraform defines blue (+ optional green) + LB. Ship creates/deletes the idle color around cutovers. Apply does not recreate a missing green pool unless it is live, already present, or `ensure_green_pool=true`.

Do **not** use Terraform’s optional `bootstrap_lb_blue` after green (or any non-blue color) is live.

## Managed Postgres (dev)

- Cluster: `sailing-plans-pg-dev` (Postgres 18, same VPC)
- Trusted sources: pool Droplet **tag**
- `DATABASE_URL` injected via cloud-init from `database_url_private`

## Managed Valkey (dev)

- Cluster: `sailing-plans-valkey-dev` (Valkey 8, `db-s-1vcpu-1gb`, same VPC)
- Trusted sources: pool Droplet **tag**
- `REDIS_URL` injected via cloud-init from `redis_url_private` (~$15/mo)
