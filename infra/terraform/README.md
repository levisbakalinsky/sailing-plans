# Infrastructure (Terraform)

Corporate-style Infrastructure-as-Code for Sailing Plans on DigitalOcean.

## Layout

```
infra/terraform/
  modules/
    app_pool/          # Droplet Autoscale Pool + Load Balancer + firewall
    cloudflare_dns/    # Apex + www A records → Load Balancer (proxied)
    app_host/          # Legacy single Droplet (staging scaffold only)
    postgres/          # Managed Postgres + DB firewall
  environments/
    dev/               # Development root module (this env)
    staging/           # Scaffold only (not applied)
    # prod/            # Add when needed (copy from dev; stricter SSH CIDRs)
```

**Ownership split**

| Concern | Tool |
| --- | --- |
| Autoscale pool, LB, managed Postgres, firewalls, VPC, tags | Terraform |
| Cloudflare DNS (apex/www → LB) | Terraform (`cloudflare_dns`) |
| Container image build + rolling `docker compose` deploy | GitHub Actions (`Deploy Development`) |
| New pool member bootstrap | cloud-init (`app_pool` user-data) |

## Prerequisites

- Terraform `>= 1.5`
- `DIGITALOCEAN_TOKEN` in the environment (1Password / CI secret)
- Existing DO SSH key named `sailing-plans-do-deploy` (or override `ssh_key_name`)
- Optional: `TF_VAR_ghcr_pull_token` so new Droplets can pull private GHCR images on boot
- `CLOUDFLARE_API_TOKEN` with Zone DNS Edit on the sailingplans zones

## Dev workflow

```bash
cd infra/terraform/environments/dev
export DIGITALOCEAN_TOKEN=...   # never commit
export TF_VAR_ghcr_pull_token=...  # GHCR read token for pool bootstrap
terraform init -backend-config=backend.hcl
terraform fmt -recursive ../..
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

After apply:

1. Set GitHub secret `LOADBALANCER_IP` to `terraform output -raw loadbalancer_ip`
2. Confirm `pool_tag` matches Deploy Development (`sailing-plans-app-dev-pool`)
3. Wait for min instances to pass LB `/health` (cloud-init + compose)

Applying this stack **replaces** the old single `app_host` Droplet with a pool (min 2) + LB.

## Remote state

Dev state lives in DigitalOcean Spaces:

- Bucket: `sailing-plans-tfstate` (nyc3)
- Key: `env/dev/terraform.tfstate`
- Config: `environments/dev/backend.hcl` (committed; no secrets)

```bash
export DIGITALOCEAN_TOKEN=...
export AWS_ACCESS_KEY_ID=...      # Spaces access key
export AWS_SECRET_ACCESS_KEY=...  # Spaces secret key
cd environments/dev
terraform init -backend-config=backend.hcl
terraform plan
```

Staging uses `env/staging/terraform.tfstate` (scaffold only until applied).

## CI

Workflow: `.github/workflows/terraform-dev.yml`

| Stage | When |
| --- | --- |
| `fmt` + `validate` | Every PR/push touching Terraform |
| `plan` | Every PR/push (reads Spaces remote state) |
| `apply` | Manual `workflow_dispatch` with `apply=true` |

Required GitHub Environment **`development`** secrets:

| Secret | Purpose |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | Provider auth + deploy host discovery |
| `DROPLET_USER` / `DROPLET_SSH_KEY` | SSH to pool members |
| `LOADBALANCER_IP` | Public health checks after deploy |
| `GHCR_PULL_TOKEN` | Injected as `TF_VAR_ghcr_pull_token` for user-data pulls |
| `CLOUDFLARE_API_TOKEN` | DNS management for sailingplans.* zones |
| `SPACES_ACCESS_KEY_ID` / `SPACES_SECRET_ACCESS_KEY` | Spaces remote state |

## Cloudflare (dev)

Public hostnames (proxied / orange-cloud) point at the DO Load Balancer:

- https://sailingplans.com / https://www.sailingplans.com
- https://sailingplans.net / https://www.sailingplans.net
- https://sailingplans.org / https://www.sailingplans.org

SSL mode is **Flexible** (Cloudflare HTTPS → origin HTTP on LB `:80`) with **Always Use HTTPS** on. Upgrade to Full (Strict) later with a Cloudflare Origin CA cert on Caddy.

`.net` and `.org` (including `www`) **301 redirect** to `https://sailingplans.com` (path + query preserved) via Cloudflare Single Redirect rules (configured in the Cloudflare dashboard; not yet managed by Terraform API tokens on this account).

### SSH lockdown

Do **not** CIDR-restrict port 22 while deploys use GitHub-hosted runners over SSH. Options later: self-hosted runner, Tailscale/VPN allowlist, or replace SSH deploy with an in-VPC agent.

## Managed Postgres (dev)

- Cluster: `sailing-plans-pg-dev` (`db-s-1vcpu-1gb`, Postgres 18, same VPC as pool)
- App DB/user: `sailing_plans` / `sailing`
- Trusted sources: pool Droplet **tag** (autoscale-safe). Optionally set `db_allowed_ip_addresses` for laptop migrates.
- Pool `DATABASE_URL`: injected via cloud-init from `database_url_private`
- After first create, grant app ownership (Postgres 15+): run `deploy/db-grant-app-user.sql` as `doadmin` on `sailing_plans`, then `prisma migrate deploy` (Deploy Development runs migrate once per API deploy)

## Autoscale pool (dev)

| Setting | Default |
| --- | --- |
| Min / max | 2 / 4 |
| Size | `s-2vcpu-4gb` |
| CPU target | 0.7 |
| Cooldown | 10 minutes |
| LB | `lb-small`, HTTP `:80` → `:80`, health `/health` |
| Pool tag | `sailing-plans-app-dev-pool` |

Cost note: roughly **2× Droplet** + **Load Balancer** vs the previous single host.

## Tagging standard

All resources receive:

- `sailing-plans` (project)
- `dev` / `staging` / `prod` (environment)
- `managed-by:terraform`
- `role:app-host` or `role:postgres`
- pool membership tag (`*-pool`)
- `owner:*`
- `cost-center:*`

## Adding staging / prod

1. Copy `environments/dev` → `environments/staging` (or `prod`)
2. Change `terraform.tfvars` (`environment`, names, size, SSH CIDRs)
3. Use a **separate** state key / workspace
4. Never share state files across environments
