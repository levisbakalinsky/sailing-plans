# Deploy Development (Blue/Green)

Development runs on DigitalOcean **Droplet Autoscale Pools** (blue + green) behind one **Load Balancer**.

- **Infrastructure** (pools, LB, firewalls, Postgres, Valkey): Terraform — see [`infra/terraform/README.md`](../infra/terraform/README.md)
- **Migrations**: GitHub Actions **Migrate Development** (separate from deploys)
- **Application**: GitHub Actions **Deploy Development** (blue/green cutover)

## Order of operations

1. If schema changed → run **Migrate Development**
2. Run **Deploy Development** (builds images, brings up the inactive color, health-checks, flips LB, scales old color to 0)

Do **not** run migrations inside the app deploy.

## Blue/green flow

| Step | What happens |
| --- | --- |
| Resolve colors | Read LB `droplet_tag` (blue or green); other color is inactive |
| Scale inactive | Set inactive pool `min_instances` to baseline (2); wait for healthy hosts |
| Deploy | Push new images / proxy config **only** to inactive color |
| Health-check | Require baseline hosts on inactive tag returning `/health` 200 |
| Cutover | Point LB at inactive color tag |
| Finalize | Scale previous color `min_instances` → 1 (standby) |

DigitalOcean autoscale pools require `min_instances >= 1`, so the idle color keeps one standby droplet (not zero).

Rollback before cutover: cancel the workflow / leave LB on the active color; scale inactive back to 1.  
Rollback after cutover: flip LB tag back to the previous color (old fleet still up until finalize).

## Topology

| Resource | Tag / ID |
| --- | --- |
| Shared (DB/Valkey/firewall) | `sailing-plans-app-dev-pool` |
| Blue color | `sailing-plans-app-dev-pool-blue` |
| Green color | `sailing-plans-app-dev-pool-green` |
| Baseline / max | **2 / 4** per color |
| Public entry | Load Balancer → active color tag |

## GitHub configuration

Environment: **`development`**.

| Secret | Purpose |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | Autoscale / LB / droplet APIs |
| `DROPLET_USER` / `DROPLET_SSH_KEY` | SSH deploy |
| `LOADBALANCER_IP` | Post-cutover health checks |
| `GHCR_PULL_TOKEN` | Optional Droplet boot pull token |

| Variable | Purpose |
| --- | --- |
| `LOADBALANCER_ID` | LB UUID for tag flip |
| `AUTOSCALE_POOL_ID_BLUE` / `AUTOSCALE_POOL_ID_GREEN` | Pool UUIDs for scale up/down |
| `BLUE_TAG` / `GREEN_TAG` | Color tags (defaults match Terraform) |
| `POOL_TAG` | Shared tag |
| `BASELINE_MIN` | Default `2` |
| `ACTIVE_COLOR_TAG` | Updated after cutover (used by Migrate) |

## Manual runs

- Actions → **Migrate Development** → Run workflow  
- Actions → **Deploy Development** → choose component; optional `skip_cutover` / `finalize`

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health

`.net` / `.org` 301 → `www.sailingplans.com`.

## Local helpers

```bash
export DIGITALOCEAN_TOKEN=...
export POOL_TAG=sailing-plans-app-dev-pool-blue   # or -green
./deploy/scripts/pool-hosts.sh
./deploy/scripts/ssh-pool.sh -- 'uptime'
export LOADBALANCER_ID=...
./deploy/scripts/lb-get-tag.sh
```
