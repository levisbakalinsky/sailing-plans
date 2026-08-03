# Deploy ops (platform / on-call)

Developer day-to-day: [shipping.md](./shipping.md).

This page is the blue/green + release-ledger machinery.

## Workflows

| Concern | Workflow |
| --- | --- |
| PR checks | **CI** |
| Infra (LB, pools bootstrap, Postgres, Valkey, DNS) | **Terraform (Development)** |
| DB migrations | **Migrate DB (Development)** |
| Ship a build | **Ship (Development)** |
| Activate any past build | **Rollback / Releases (Development)** → `activate` |
| Pool / LB ops | **Ops (Development)** |

Concurrency: migrate, ship, release, and ops share `deploy-dev-pool` so they do not race.

## Ship internals

1. Resolve LB active color (blue/green)
2. Ensure inactive pool exists (recreate if a prior teardown deleted it)
3. Build/push images and deploy onto the inactive color
4. Health-check `/health`
5. Flip LB tag (unless `skip_cutover`)
6. Register `YYYYMMDDTHHMMSSZ-<sha12>` in the release ledger

Failed component builds **block** cutover.

### Advanced Ship inputs

| Input | Default | Meaning |
| --- | --- | --- |
| `finalize` | false | After cutover, delete the old color (~2 droplets). Prefer **Ops → teardown-idle** when you want to save cost later. |
| `skip_cutover` | false | Stage onto inactive only; flip later via Release `activate` or another ship. |

## Release ledger

**Rollback / Releases (Development)**

| Action | Purpose |
| --- | --- |
| `list` | History (`*` = current) |
| `activate` | Deploy images for an **id** or **git sha** + cut over |
| `status` | LB color + current + recent + host `release.json` |
| `seed-live` | One-shot bootstrap of the ledger from what’s running |

Ledger: `s3://sailing-plans-tfstate/releases/dev/ledger.json` (last 50).

`finalize` on activate deletes the newly-idle color after a successful flip.

## Ops

**Ops (Development)**

| Action | Purpose |
| --- | --- |
| `status` | Pools + droplets |
| `set-lb-tag` | Emergency LB tag flip |
| `set-min` | Change pool `min_instances` |
| `teardown-idle` | Delete idle color (~2 droplets) |
| `destroy-orphans` | Scrub leftover idle-tagged droplets |

## Terraform notes

- Bootstraps tags, LB, firewall, DB, Valkey, and both color pool definitions.
- CI/ops may delete the idle pool; a later **apply can recreate it**. Prefer Ops for pool lifecycle.
- `bootstrap_lb_blue` is first-time only and refused if another color is already live.

## GitHub `development` env

**Secrets:** `DIGITALOCEAN_TOKEN`, `DROPLET_USER`, `DROPLET_SSH_KEY`, `LOADBALANCER_IP`, `SPACES_ACCESS_KEY_ID`, `SPACES_SECRET_ACCESS_KEY`, optional `GHCR_PULL_TOKEN`, `CLOUDFLARE_API_TOKEN` (TF)

**Variables:** `LOADBALANCER_ID`, `AUTOSCALE_POOL_ID_BLUE`, `AUTOSCALE_POOL_ID_GREEN`, `POOL_TAG`, `BLUE_TAG`, `GREEN_TAG`, `BASELINE_MIN`, optional `ACTIVE_COLOR_TAG`

Pool IDs in vars can go stale after delete/recreate; scripts resolve by **pool name** when possible.

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health
