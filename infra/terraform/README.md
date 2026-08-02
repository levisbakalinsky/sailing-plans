# Infrastructure (Terraform)

Corporate-style Infrastructure-as-Code for Sailing Plans on DigitalOcean.

## Layout

```
infra/terraform/
  modules/
    app_host/          # Reusable Droplet + cloud firewall
  environments/
    dev/               # Development root module (this env)
    # staging/         # Add when needed (copy from dev)
    # prod/            # Add when needed (copy from dev; stricter SSH CIDRs)
```

**Ownership split**

| Concern | Tool |
| --- | --- |
| Droplet, firewall, VPC attachment, tags | Terraform |
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

## Remote state (required for teams)

Local state is fine for a single operator bootstrap. For shared use:

1. Create a Spaces bucket (e.g. `sailing-plans-tfstate`)
2. Uncomment `backend "s3" {}` in `environments/dev/versions.tf`
3. Copy `backend.hcl.example` → `backend.hcl` and fill in
4. `terraform init -backend-config=backend.hcl -migrate-state`

## CI

Workflow: `.github/workflows/terraform-dev.yml`

| Stage | When |
| --- | --- |
| `fmt` + `validate` | Every PR/push touching Terraform |
| `plan` | Only when repo variable `TF_REMOTE_STATE_ENABLED=true` (after Spaces backend) |

**Do not** run `plan`/`apply` in CI against empty local state — that diverges from the real environment. Until Spaces remote state is wired, run plan/apply on a trusted operator machine (or enable the gated `plan` job after backend setup).

Required GitHub Environment **`development`** secrets:

| Secret | Purpose |
| --- | --- |
| `DIGITALOCEAN_TOKEN` | Provider auth |
| `DROPLET_HOST` / `DROPLET_USER` / `DROPLET_SSH_KEY` | App deploy workflows |
| `SPACES_ACCESS_KEY_ID` / `SPACES_SECRET_ACCESS_KEY` | Remote state (when enabled) |

Note: DigitalOcean firewalls allow **max 5 tags**; the module slices accordingly.

## Tagging standard

All resources receive:

- `sailing-plans` (project)
- `dev` / `staging` / `prod` (environment)
- `managed-by:terraform`
- `role:app-host`
- `owner:*`
- `cost-center:*`

## Adding staging / prod

1. Copy `environments/dev` → `environments/staging` (or `prod`)
2. Change `terraform.tfvars` (`environment`, `droplet_name`, size, SSH CIDRs)
3. Use a **separate** state key / workspace
4. Never share state files across environments
