# MEW 2.0.1 evaluation and remaining work

This patch addresses defects reproduced against v2.0.0. A passing regression suite does not establish that every MEW workflow is complete or production-ready.

## Fixed in this patch

| Finding | Change | Regression evidence |
| --- | --- | --- |
| Automation kill changed unrelated project and agent modes | Update only the automation section | Verify all three unrelated modes survive |
| Incomplete composition or reference passed an implementation gate | Check required document fields, material row, selected mode, and active-reference fields | Block empty composition, missing reference, and invalid project mode |
| Failed project activation left the gate approved | Check target before activation and restore prior manifest on ordinary activation failure | Exercise existing target and a deliberately missing implementation template |
| Online upgrade did not preserve the full previous Foundation | Snapshot the Foundation, excluding prior archives, and the manifest; preserve existing mode and reopen the gate | Check snapshot contents and blocked gate after an approved prototype |
| Job IDs could collide within a second | Generate unique job filenames | Run the same dry-run twice |
| Tool dry-runs implied an inspection had happened | Explicitly state when no inspection or detection ran | Check dry-run output |
| A stable update could select an older patch | Compare target with the installed version and refuse downgrade | Simulate older and newer patch tags |

## Limits and follow-up priorities

1. The gate performs structural checks only. It cannot judge the quality, correctness, or security of human or AI decisions. A developer and capable AI must review relevant risks and unresolved questions.
2. Stage-level implementation permissions and dependency tracking need a dedicated model; the current gate is workspace-wide.
3. Stack profiles and material categories are introductory. Compatibility advice is not an automated version-aware solver, and costs require current provider research.
4. Role instructions and local dry-run contracts do not provide an AI model, web search, a scheduler, or publishing integration. Future adapters require separate design, permissions, testing, and honest capability detection.
5. A kill switch updates the local policy state. It cannot terminate an independently running external process; an actual runner needs its own tested stop mechanism.
6. Migration keeps the original mode until the developer selects a new one. Data migration, deployment, and online security review remain manual or agent-assisted work.
7. Regression tests cover selected CLI paths, not model behavior, every OS, network failures, process interruption, or production workloads.

Prioritize reproducible safety and data-integrity regressions before expanding automation. Add measurable acceptance tests for each new integration instead of implying that a contract is an implementation.
