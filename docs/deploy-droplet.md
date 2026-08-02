# Deploy Development Droplet

Development environment on a DigitalOcean Droplet.

- **Infrastructure** (Droplet, firewall, tags): Terraform — see [`infra/terraform/README.md`](../infra/terraform/README.md)
- **Application** (API / web / proxy containers): GitHub Actions below

Components deploy independently.

| Job | Deploys | Triggers on push when… |
| --- | --- | --- |
| `build-api` → `deploy-api` | API container | `apps/api/**`, `packages/**`, lockfile |
| `build-web` → `deploy-web` | Web container | `apps/web/**`, lockfile |
| `deploy-proxy` | Caddy + compose sync | `deploy/Caddyfile`, `deploy/docker-compose.yml` |

Manual: Actions → **Deploy Development** → choose `all` / `api` / `web` / `proxy`.

## One-time Droplet setup

1. Ubuntu 24.04 Droplet with SSH key (current: `sailing-plans` in `nyc1`).
2. Bootstrap Docker:

```bash
# copy and run deploy/bootstrap.sh as root, or:
curl -fsSL https://raw.githubusercontent.com/levisbakalinsky/sailing-plans/main/deploy/bootstrap.sh | bash
```

3. Ensure `/opt/sailing-plans` has `docker-compose.yml`, `Caddyfile`, and `.env`.
4. Set `DATABASE_URL` in `.env` to the Terraform output `database_url_private` (managed Postgres). Do not run Postgres on the Droplet.

## GitHub configuration

Environment: **`development`** (not production).

| Secret | Value |
| --- | --- |
| `DROPLET_HOST` | Droplet public IP |
| `DROPLET_USER` | `root` (or deploy user in `docker` group) |
| `DROPLET_SSH_KEY` | Private key for that user |

Images: `ghcr.io/<owner>/sailing-plans-api:dev` and `-web:dev` (plus sha tags).

## URLs

- Web: `http://<droplet-ip>/`
- API health: `http://<droplet-ip>/health`
- API prefix: `http://<droplet-ip>/api/health`
