# Deploy ops (platform / on-call)

Developer day-to-day: [shipping.md](./shipping.md).

Development has **no runtime rollback**. Blue/green is only for zero-downtime ship; the old color is deleted after a successful cutover.

## Workflows

| Concern | Workflow |
| --- | --- |
| PR checks | **CI** |
| Infra (LB, pools bootstrap, Postgres, Valkey, DNS) | **Terraform (Development)** |
| DB migrations | **Migrate DB (Development)** |
| Ship a build | **Ship (Development)** |
| What shipped | **Release history (Development)** |
| Pool / LB ops | **Ops (Development)** |

Concurrency: migrate, ship, release history, ops, and Terraform **apply** share `deploy-dev-pool`.

## Ship internals

1. Wait for **CI** on the same commit (push / auto-ship)
2. If the push also contains migrations, Ship defers; Migrate runs first and re-triggers Ship
3. Resolve LB active color (blue/green)
4. Ensure inactive pool exists (Ship recreates it if needed)
5. Build/push images and deploy onto the inactive color
6. Health-check fleet `/health`
7. Flip LB tag; on failure, **flip back** automatically
8. Register release in the ledger
9. Delete the previous color pool

Failed component builds **block** cutover. Sibling deploys do not run if a selected build failed.

## Release history

| Action | Purpose |
| --- | --- |
| `list` | History (`*` = current) |
| `status` | LB color + current + recent + host `release.json` |
| `seed-live` | One-shot bootstrap only when ledger has no current |

Ledger: `s3://sailing-plans-tfstate/releases/dev/ledger.json` (last 50).

## Ops

| Action | Purpose |
| --- | --- |
| `status` | Pools + droplets |
| `set-lb-tag` | Emergency LB tag flip |
| `set-min` | Change pool `min_instances` (≥ 1) |
| `teardown-idle` | Delete idle color if one was left around |
| `destroy-orphans` | Scrub leftover idle-tagged droplets **after** teardown-idle (refuses if idle pool still exists) |

## Terraform notes

- Bootstraps tags, LB, firewall, DB, Valkey, blue pool, and optionally green.
- Apply uses the same concurrency group as Ship so it cannot race cutover.
- By default apply does **not** recreate a missing green pool (`ensure_green_pool=false` unless green is live or already present). Ship creates the idle color when needed.
- `bootstrap_lb_blue` is first-time only and refused if another color is already live.

## GitHub `development` env

**Secrets:** `DIGITALOCEAN_TOKEN`, `DROPLET_USER`, `DROPLET_SSH_KEY`, `LOADBALANCER_IP`, `SPACES_ACCESS_KEY_ID`, `SPACES_SECRET_ACCESS_KEY`, optional `GHCR_PULL_TOKEN`, `CLOUDFLARE_API_TOKEN` (TF)

**Variables:** `LOADBALANCER_ID`, `AUTOSCALE_POOL_ID_BLUE`, `AUTOSCALE_POOL_ID_GREEN`, `POOL_TAG`, `BLUE_TAG`, `GREEN_TAG`, `BASELINE_MIN`, optional `ACTIVE_COLOR_TAG`

Pool IDs in vars can go stale; scripts resolve by **pool name**.

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health
