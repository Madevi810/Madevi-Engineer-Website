# Environment Plan

| Environment | Purpose | Required now? | Data type | Deployment/runner | Recovery |
| --- | --- | --- | --- | --- | --- |
| Local | Developer work | Yes | Dummy/test | Device tooling | Rebuild from source |
| Prototype | Demo/testing | Optional | Test | Preview/local | Recreate |
| Staging | Pre-production verification | Later | Sanitized/test | Provider selected later | Restore test snapshot |
| Production | Real users | Only when approved | Real data | Approved provider | Backup and rollback plan |

## Provider decision

Developer may defer provider selection. If deferred, list architecture constraints that preserve future portability and identify decisions that cannot be deferred.

## Cost control

Record one-time setup cost, monthly baseline, usage-sensitive cost, hard budget ceiling, and the alert threshold.
