# Data Lifecycle and Fallback Plan

Every project must classify data and define its lifecycle before production use.

| Data class | Owner | Collection purpose | Retention | Backup | Delete/export | Access | Fallback |
| --- | --- | --- | --- | --- | --- | --- | --- |
| | | | | | | | |

## Service failure plan

| Dependency | Failure signal | User impact | Safe fallback | Recovery | Rollback owner |
| --- | --- | --- | --- | --- | --- |
| Database | | | | | |
| Authentication | | | | | |
| Payment | | | | | |
| Search/API/AI | | | | | |
| Media/CDN | | | | | |

Do not claim a fallback exists until it is testable within the selected project mode.
