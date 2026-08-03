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

**Bootstrap wait:** Inactive pool members clone from base Ubuntu; cloud-init + Docker often needs several minutes before `:80/health` is 200. `hosts=N healthy<M` during `scale-inactive` is usually still booting, not stuck.

**Dual-tag orphans:** A droplet with both `-pool-blue` and `-pool-green` that is not a member of any remaining autoscale pool is destroyed on teardown (`autoscale-delete.sh`) and again when ensuring the inactive pool. Live dual-tagged hosts (still pool members) are never destroyed; the stale idle tag is stripped instead. Health waits count only autoscale pool members, so orphans cannot satisfy readiness.

## URLs

- https://www.sailingplans.com/
- https://www.sailingplans.com/health
- https://www.sailingplans.com/api/health
