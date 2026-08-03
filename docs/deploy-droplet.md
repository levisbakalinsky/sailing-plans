# Development deploy & release management

Blue/green pools move traffic; a Spaces **release ledger** records which builds exist.

| Concern | Workflow |
| --- | --- |
| Infra (LB, pools bootstrap, Postgres, Valkey, DNS) | **Terraform Development** |
| DB migrations | **Migrate Development** (before app deploy when schema changes) |
| Ship a build | **Deploy Development** |
| Activate any past build | **Release Development** → `activate` |
| Pool / LB ops | **Ops Development** |

Concurrency: migrate, deploy, release, and ops share `deploy-dev-pool` so they do not race.

## Ship a release

1. Schema change → **Migrate Development**
2. **Deploy Development** (optional `release_message`, `skip_cutover`)
3. Registers `YYYYMMDDTHHMMSSZ-<sha12>` in the ledger and flips LB (unless `skip_cutover`)

Default: previous color stays up so you can switch again quickly.

## Activate / roll back / jump versions

**Release Development**

| Action | Purpose |
| --- | --- |
| `list` | History (`*` = current) |
| `activate` | Set `release` to an **id** or **git sha** → deploy those images + cut over |
| `status` | LB color + current + recent + host `release.json` |
| `seed-live` | Bootstrap ledger from what’s running (one-shot) |

Ledger: `s3://sailing-plans-tfstate/releases/dev/ledger.json` (last 50).

## Ops

**Ops Development**

| Action | Purpose |
| --- | --- |
| `status` | Pools + droplets |
| `set-lb-tag` | Emergency LB tag flip |
| `set-min` | Change pool min_instances |
| `teardown-idle` | Delete idle color (~2 droplets) |
| `destroy-orphans` | Scrub leftover idle-tagged droplets |

## Blue/green mechanism

1. Resolve LB active color  
2. Ensure inactive pool (recreate if missing)  
3. Deploy/activate images on inactive  
4. Health-check `/health`  
5. Flip LB tag  
6. Update ledger / host state  

Failed component builds **block** cutover (no flip on a half-deployed color).

## Terraform notes

- TF bootstraps tags, LB, firewall, DB, Valkey, and both color pool definitions.
- CI may delete the idle pool; a later **apply can recreate it**. Prefer Ops/Release for pool lifecycle.
- `bootstrap_lb_blue` is opt-in and refused if another color is already live.

## GitHub `development` env

**Secrets:** `DIGITALOCEAN_TOKEN`, `DROPLET_USER`, `DROPLET_SSH_KEY`, `LOADBALANCER_IP`, `SPACES_ACCESS_KEY_ID`, `SPACES_SECRET_ACCESS_KEY`, optional `GHCR_PULL_TOKEN`, `CLOUDFLARE_API_TOKEN` (TF)

**Variables:** `LOADBALANCER_ID`, `AUTOSCALE_POOL_ID_BLUE`, `AUTOSCALE_POOL_ID_GREEN`, `POOL_TAG`, `BLUE_TAG`, `GREEN_TAG`, `BASELINE_MIN`, optional `ACTIVE_COLOR_TAG`

Pool IDs in vars can go stale after delete/recreate; scripts resolve by **pool name** when possible.

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health
