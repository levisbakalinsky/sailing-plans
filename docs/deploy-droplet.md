# Deploy Development (Autoscale Pool)

Development runs on a DigitalOcean **Droplet Autoscale Pool** behind a **Load Balancer**.

- **Infrastructure** (pool, LB, firewalls, managed Postgres): Terraform — see [`infra/terraform/README.md`](../infra/terraform/README.md)
- **Application** (API / web / proxy containers): GitHub Actions below
- **Bootstrap**: cloud-init on each new pool member installs Docker and starts Compose

Components deploy independently to **every** Droplet with the pool tag.

| Job | Deploys | Triggers on push when… |
| --- | --- | --- |
| `build-api` → `deploy-api` | API on all pool hosts + migrate once | `apps/api/**`, `packages/**`, lockfile |
| `build-web` → `deploy-web` | Web on all pool hosts | `apps/web/**`, lockfile |
| `deploy-proxy` | Caddy + compose sync on all hosts | `deploy/Caddyfile`, `deploy/docker-compose.yml`, scripts |

Manual: Actions → **Deploy Development** → choose `all` / `api` / `web` / `proxy`.

## Topology

- Pool tag: `sailing-plans-app-dev-pool` (override with env var `POOL_TAG`)
- Min / max instances: **2 / 4** (CPU target 0.7)
- Public entrypoint: Load Balancer IP (not individual Droplet IPs)
- DB trust: managed Postgres firewall allows the pool **tag**

## GitHub configuration

Environment: **`development`**.

| Secret / var | Value |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | List Droplets by tag during deploy |
| `DROPLET_USER` | `root` (or deploy user in `docker` group) |
| `DROPLET_SSH_KEY` | Private key matching Terraform `ssh_key_name` |
| `LOADBALANCER_IP` | LB public IP (`terraform output -raw loadbalancer_ip`) |
| `DROPLET_HOST` | Optional fallback if `LOADBALANCER_IP` unset |
| `GHCR_PULL_TOKEN` | PAT/`read:packages` token for Droplet boot pulls (`TF_VAR_ghcr_pull_token`) |
| `POOL_TAG` (optional variable) | Defaults to `sailing-plans-app-dev-pool` |

Images: `ghcr.io/<owner>/sailing-plans-api:dev` and `-web:dev` (plus sha tags).

## URLs

Public (Cloudflare → LB):

- https://sailingplans.com/
- https://sailingplans.com/health
- https://sailingplans.com/api/health

`.net` / `.org` (and www) 301-redirect to `https://sailingplans.com`.

Direct LB (ops):

- Web: `http://<loadbalancer-ip>/`
- API health: `http://<loadbalancer-ip>/health`

## Local helpers

```bash
export DIGITALOCEAN_TOKEN=...
export POOL_TAG=sailing-plans-app-dev-pool
./deploy/scripts/pool-hosts.sh          # list public IPs
./deploy/scripts/ssh-pool.sh -- 'uptime'  # run on every member
```
