# Staging environment

Scaffolded from `dev`. **Not applied yet** — creating it provisions another Droplet (~$24/mo).

```bash
export DIGITALOCEAN_TOKEN=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```
