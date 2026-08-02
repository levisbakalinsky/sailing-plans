# Infrastructure (Terraform)

Corporate-style Infrastructure-as-Code for Sailing Plans on DigitalOcean.

## Layout

```
infra/terraform/
  modules/
    app_host/          # Reusable Droplet + cloud firewall
    postgres/          # Managed Postgres + DB firewall
  environments/
    dev/               # Development root module (this env)
    staging/           # Scaffold only (not applied)
    # prod/            # Add when needed (copy from dev; stricter SSH CIDRs)
```

**Ownership split**

| Concern | Tool |
| --- | --- |
| Droplet, managed Postgres, firewalls, VPC, tags | Terraform |
| Container image build + `docker compose` deploy | GitHub Actions (`Deploy Development`) |

## Prerequisites

- Terraform `>= 1.5`
- `DIGITALOCEAN_TOKEN` in the environment (1Password / CI secret)
- Existing DO SSH key named `sailing-plans-do-deploy` (or override `ssh_key_name`)

## Dev workflow

```bash
cd infra/terraform/environments/dev
export DIGITALOCEAN_TOKEN=...   # never commit
terraform init
terraform fmt -recursive ../..
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### First-time import

`imports.tf` imports the existing Droplet `589387493`. After the first successful apply:

1. Delete `imports.tf`
2. Commit the removal
3. Prefer remote state (see below)

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

Required GitHub Environment **`development`** secrets:

| Secret | Purpose |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | Provider auth |
| `DROPLET_HOST` / `DROPLET_USER` / `DROPLET_SSH_KEY` | App deploy workflows |
| `SPACES_ACCESS_KEY_ID` / `SPACES_SECRET_ACCESS_KEY` | Spaces remote state |

Note: DigitalOcean firewalls allow **max 5 tags**; the module slices accordingly.

### SSH lockdown

Do **not** CIDR-restrict port 22 while deploys use GitHub-hosted runners over SSH. Options later: self-hosted runner on the Droplet, Tailscale/VPN allowlist, or replace SSH deploy with an in-VPC agent.

## Managed Postgres (dev)

- Cluster: `sailing-plans-pg-dev` (`db-s-1vcpu-1gb`, Postgres 16, same VPC as Droplet)
- App DB/user: `sailing_plans` / `sailing`
- Trusted sources: Droplet ID (private network). Optionally set `db_allowed_ip_addresses` for laptop migrates.
- Droplet `DATABASE_URL`: `terraform output -raw database_url_private`
- After first create, grant app ownership (Postgres 15+): run `deploy/db-grant-app-user.sql` as `doadmin` on `sailing_plans` (from the Droplet over the private host), then `docker compose exec api npx prisma migrate deploy`

## Tagging standard

All resources receive:

- `sailing-plans` (project)
- `dev` / `staging` / `prod` (environment)
- `managed-by:terraform`
- `role:app-host` or `role:postgres`
- `owner:*`
- `cost-center:*`

## Adding staging / prod

1. Copy `environments/dev` → `environments/staging` (or `prod`)
2. Change `terraform.tfvars` (`environment`, `droplet_name`, size, SSH CIDRs)
3. Use a **separate** state key / workspace
4. Never share state files across environments
