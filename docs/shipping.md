# Shipping (for developers)

You almost never need blue/green, pools, or Terraform. Use this page.

## Everyday loop

1. Open a PR.
2. Wait for **CI** (typecheck, test, build) to go green.
3. Merge to `main`.
4. **Ship (Development)** deploys automatically when app code changes.
5. Check https://www.sailingplans.com/health and https://www.sailingplans.com/api/health

That’s it for normal feature work.

## Database schema changes

Migrations are **not** part of the app deploy.

1. Land the migration files on `main` (or run **Migrate DB (Development)** manually).
2. Wait for migrate to finish.
3. Then ship the app (**Ship (Development)** — automatic on app paths, or run manually).

Order matters: migrate → ship.

## Something broke after deploy

Do **not** rewrite git history on `main`.

1. Actions → **Rollback / Releases (Development)**
2. Action: `list` → copy the previous release id (the `*` line is current)
3. Run again with action `activate` and paste that id

Site flips back to that build. Fix forward in a new PR.

## Manual ship (optional)

Actions → **Ship (Development)** → leave defaults → Run.

| Input | When to touch it |
| --- | --- |
| Component | Leave `all` unless you only changed one piece |
| Note | Optional human label in the release history |
| Advanced toggles | Leave **false** (see [ops guide](./deploy-ops.md)) |

## What you can ignore

| Workflow | Who it’s for |
| --- | --- |
| Ops (Development) | On-call / platform (pool status, cost teardown) |
| Terraform (Development) | Infra changes (LB, DB, DNS, pools) |
| Advanced Ship / Release toggles | Staging without traffic, deleting idle pools |

Details: [deploy-ops.md](./deploy-ops.md).
