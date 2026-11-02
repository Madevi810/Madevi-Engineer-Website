# UWF Tool Runtime

Tools convert an approved agent decision into a traceable local action. A tool contract defines what it may do; the contract does not grant access by itself.

## Safety classes

| Mode | Meaning |
| --- | --- |
| `local_read` | Inspect the workspace without changing application files |
| `foundation_write` | Create Foundation records, reports, logs, or dry-runs only |
| `external_read` | Requires a declared external adapter and approved research scope |
| `external_write` | Disabled unless explicit developer approval and policy exist |

All `uwf tool run` commands default to dry-run and create a Job record plus Action Journal entry. No tool runner writes application code, secrets, dependencies, cloud resources, or public content.
