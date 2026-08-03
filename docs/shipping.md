# Shipping (for developers)

Development is **fix-forward only**. If a ship is bad, revert or fix in git and ship again.

## Everyday loop

1. Open a PR → wait for **CI**
2. Merge to `main`
3. **Ship** runs automatically (after CI)
4. Check https://www.sailingplans.com/health

## Schema changes

1. Merge migrations → **Migrate DB** runs automatically
2. If the same commit also has app code, Migrate triggers **Ship** when done

## Manual runs (optional)

| Workflow | When |
| --- | --- |
| **Ship** | Re-deploy current `main` (no options — just Run) |
| **Migrate DB** | Re-run migrations (no options — just Run) |

## Ignore these

| Workflow | Who |
| --- | --- |
| **Ops** | Platform / on-call |
| **Terraform** | Infra changes only |

Details: [deploy-ops.md](./deploy-ops.md).
