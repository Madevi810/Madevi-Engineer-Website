# Material Catalog Model

Create a material record before treating a technology, service, pattern, or reference as recommended.

```text
ID:
Name:
Group and subcategory:
Use case / problem solved:
Developer level: beginner | intermediate | professional
Project mode fit: local prototype | online prototype | beta | production
Compatibility:
Conflicts and constraints:
Operational cost and skill cost:
Security, privacy, and rights notes:
Lifecycle: candidate | recommended | review_due | deprecated | blocked
Evidence cards:
Alternatives:
Exit or migration path:
Decision status:
```

## Mandatory evaluation areas

The agent must evaluate only the material groups relevant to the project, but must not omit them without recording `not applicable` and a reason.

| Area | Minimum decision topics |
| --- | --- |
| Frontend | rendering model, interaction/state, form, responsive, accessibility, SEO, localization |
| Backend/API | boundaries, API contract, validation, error handling, jobs, realtime, integration failure behavior |
| Data | ownership, schema, taxonomy, search, backup, retention, deletion, portability |
| Identity | roles, authorization, session, account recovery, consent, abuse prevention |
| Media/content | CMS model, asset license, storage, CDN, moderation, versioning, attribution |
| Quality | acceptance criteria, test layers, performance budget, accessibility review, release evidence |
| Security/privacy | threat model, secret handling, rate limits, audit, dependency risk, privacy notices |
| Operations | local experience, deployment, observability, alerts, backup/restore, budget, rollback |

Do not encode volatile package versions as permanent truth. Evidence Cards hold time-sensitive verification.
