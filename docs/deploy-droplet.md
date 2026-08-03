# Deploy Development (Blue/Green + Release Management)

Development uses blue/green pools for **how** traffic moves, and a durable **release ledger** for **which** build is live.

- **Infrastructure**: Terraform
- **Migrations**: **Migrate Development**
- **Ship a build**: **Deploy Development** (registers a release)
- **Pick any past build**: **Release Development** → `activate`

## Release ledger

Stored in Spaces: `s3://sailing-plans-tfstate/releases/dev/ledger.json`

Each deploy creates a release like:

```text
20260803T052130Z-a1b2c3d4e5f6
```

Fields: `id`, `git_sha`, `api_image`, `web_image`, `message`, `live`, `created_at`.

Keep the last **50** releases.

## Day-to-day

### Ship

1. (If schema changed) **Migrate Development**
2. **Deploy Development**
   - Optional `release_message`
   - `skip_cutover=true` → stage on idle color (`live=false`) without flipping LB
   - Default keeps previous color up so you can switch again quickly

### List history

**Release Development** → action `list` (or `status`)

### Activate any release (rollback / forward / jump)

**Release Development** → action `activate` → set `release` to:

- full id: `20260803T052130Z-a1b2c3d4e5f6`
- or git sha prefix: `a1b2c3d4e5f6`

That rebuilds the idle color with those exact images, health-checks, flips the LB, and marks the ledger current.

You can activate the same older release **multiple times**; history is not a single “previous” pointer.

### Tear down idle capacity

**Release Development** → `teardown-idle` (or deploy/activate with `finalize=true`) when you want ~2 droplets and don’t need an instant flip.

## Flows

| Goal | Steps |
| --- | --- |
| Normal ship | Deploy Development |
| Stage then promote | Deploy (`skip_cutover`) → Release `activate` with that release id |
| Roll back to build N | Release `list` → `activate` + that id/sha |
| Jump forward again | `activate` a newer id from the list |
| Save cost | `teardown-idle` after you’re happy |

## Blue/green (mechanism only)

| Step | What happens |
| --- | --- |
| Resolve colors | LB tag = active; other = inactive |
| Ensure inactive | Recreate pool if missing; scale to 2 |
| Deploy / activate | Put target images on inactive |
| Health | `/health` 200 on baseline hosts |
| Cutover | Flip LB tag |
| Ledger | Append / set-current |

## GitHub env (`development`)

Secrets: `DIGITALOCEAN_TOKEN`, `DROPLET_*`, `LOADBALANCER_IP`, `SPACES_*`  
Vars: `LOADBALANCER_ID`, pool ids, color tags, `BASELINE_MIN`
