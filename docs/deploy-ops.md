# Deploy ops (platform / on-call)

Developers: [shipping.md](./shipping.md).

## Workflows (5)

| Workflow | Purpose |
| --- | --- |
| **CI** | typecheck / test / build |
| **Ship** | Blue/green deploy, then delete old color |
| **Migrate DB** | Prisma migrate (before ship when schema changes) |
| **Terraform** | Infra plan; optional Apply |
| **Ops** | status / releases / teardown-idle / emergency LB tag |

## Terraform

- Triggers only on `infra/terraform/**`
- Manual run: one option — **Apply** (default off = plan only)
- Green pool is managed only if it already exists or is live (Ship creates idle color)

## Ops actions

| Action | Purpose |
| --- | --- |
| `status` | Pools, droplets, current release |
| `releases` | Full release ledger |
| `teardown-idle` | Delete leftover idle pool |
| `set-lb-tag` | Emergency LB flip (paste full tag from status) |

## Ship internals

1. Wait for CI  
2. Defer if migrations are in the same push (Migrate re-triggers Ship)  
3. Deploy to inactive color → healthcheck → flip LB (auto flip-back on failure)  
4. Record release → delete previous color  

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health
