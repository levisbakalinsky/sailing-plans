# Shipping (for developers)

You almost never need blue/green, pools, or Terraform. Use this page.

Development is **fix-forward only** — there is no runtime rollback/activate. If a ship is bad, revert or fix in git and ship again.

## Everyday loop

1. Open a PR.
2. Wait for **CI** (typecheck, test, build) to go green.
3. Merge to `main`.
4. **Ship (Development)** deploys automatically when app code changes (after CI succeeds).
5. Check https://www.sailingplans.com/health and https://www.sailingplans.com/api/health

That’s it for normal feature work.

## Database schema changes

Migrations are **not** part of the app deploy.

1. Land migration files on `main` → **Migrate DB (Development)** runs automatically.
2. If the same commit also has app code, Migrate triggers **Ship** when it finishes.
3. If you only need a manual migrate: Actions → **Migrate DB (Development)**.

Order is enforced: migrate before ship when both are in the same push.

## Bad deploy

Do **not** rewrite history on `main` and do **not** look for a rollback workflow.

1. Revert the PR (or push a fix).
2. Merge → CI → Ship again.

## Manual ship (optional)

Actions → **Ship (Development)** → leave defaults → Run.

| Input | When to touch it |
| --- | --- |
| Component | Leave `all` unless you only changed one piece |
| Note | Optional label in release history |

Ship always cuts traffic over and tears down the old color afterward (no idle pool kept for rollback).

## What you can ignore

| Workflow | Who it’s for |
| --- | --- |
| Release history | See what shipped (list/status) |
| Ops (Development) | On-call / platform (pool status, emergencies) |
| Terraform (Development) | Infra changes (LB, DB, DNS, pools) |

Details: [deploy-ops.md](./deploy-ops.md).
