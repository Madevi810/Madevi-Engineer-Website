# Permission Policy

Permissions are evaluated per tool action, not per agent name.

| Permission class | Default | Approval |
| --- | --- | --- |
| `workspace_read` | allowed | none |
| `foundation_write` | allowed for plans/logs/dry-runs | none |
| `application_write` | blocked before implementation gate | implementation approval |
| `repository_read` / `public_web_read` | unavailable until runtime declares it | research scope |
| `repository_write` / `provider_write` / `content_publish` | blocked | explicit developer approval and policy |
| `sensitive_data` | blocked | specific lawful scope and approval |

No permission is inherited simply because another tool has it.
