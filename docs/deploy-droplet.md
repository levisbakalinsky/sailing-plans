# Deploy Development (Blue/Green)

Development runs on DigitalOcean **Droplet Autoscale Pools** (blue + green) behind one **Load Balancer**.

- **Infrastructure**: Terraform — see [`infra/terraform/README.md`](../infra/terraform/README.md)
- **Migrations**: **Migrate Development** (run before deploy when schema changes)
- **Application**: **Deploy Development** (blue/green)
- **Rollback / forward**: **Release Development**

## Order of operations

1. Schema change → **Migrate Development**
2. App change → **Deploy Development**
3. Undo / redo traffic → **Release Development** (`rollback` / `forward`)

## Blue/green flow

| Step | What happens |
| --- | --- |
| Resolve colors | Read LB tag (blue or green); other color is inactive |
| Scale inactive | Recreate inactive pool if missing; scale to baseline (2) |
| Deploy | Push images / proxy config only to inactive color |
| Health-check | Inactive hosts must return `/health` 200 |
| Cutover | Point LB at inactive color |
| Record | Write `/opt/sailing-plans/release.json` (active + previous image pins) |
| Finalize | Optional — delete old color (default **off** so rollback stays instant) |

## Rollback and forward

Use Actions → **Release Development**:

| Action | Behavior |
| --- | --- |
| `status` | Show LB active color + release.json + idle hosts |
| `rollback` | Flip LB to the other color if healthy; otherwise rebuild previous images from `release.json` |
| `forward` | Flip LB to the idle color (use after deploy with `skip_cutover`, or to undo a rollback while idle still exists) |
| `teardown-idle` | Delete the idle color pool (~2 droplets). Disables instant flip until the next deploy |

**Recommended default:** leave `finalize=false` on deploy so both colors stay up after cutover. You can flip back and forth with Release Development. When you’re happy, run `teardown-idle` to cut cost.

**Staged promote:** Deploy with `skip_cutover=true` → verify idle color → Release Development → `forward`.

## Topology

| Resource | Tag |
| --- | --- |
| Shared (DB/Valkey/firewall) | `sailing-plans-app-dev-pool` |
| Blue / green | `…-pool-blue` / `…-pool-green` |
| Baseline / max | **2 / 4** per color |

## GitHub configuration

Environment: **`development`**.

| Secret | Purpose |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | Autoscale / LB / droplet APIs |
| `DROPLET_USER` / `DROPLET_SSH_KEY` | SSH deploy |
| `LOADBALANCER_IP` | Post-cutover health checks |

| Variable | Purpose |
| --- | --- |
| `LOADBALANCER_ID` | LB UUID for tag flip |
| `AUTOSCALE_POOL_ID_BLUE` / `AUTOSCALE_POOL_ID_GREEN` | Pool UUIDs (refreshed when pools are recreated) |
| `BLUE_TAG` / `GREEN_TAG` / `POOL_TAG` | Color + shared tags |
| `BASELINE_MIN` | Default `2` |

## Manual runs

- **Migrate Development**
- **Deploy Development** — `skip_cutover` / `finalize`
- **Release Development** — `rollback` / `forward` / `teardown-idle` / `status`

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health
