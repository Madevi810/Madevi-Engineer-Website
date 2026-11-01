# Compatibility Rules

| Decision | Must be checked against |
| --- | --- |
| Frontend rendering | Host runtime, SEO needs, browser/device target |
| Backend/API | Runtime support, deployment model, team skill |
| Database | Data relationships, transaction need, backup, regional/data policy |
| Authentication | User roles, session model, email/OAuth, privacy |
| Storage | File size, media delivery, retention, cost |
| Payment | Geography, products, refunds, security, test/live transition |
| AI feature | Data handling, API budget, fallback, user disclosure |
| Automation | Runner, permissions, budget, logs, rollback |

Unknown compatibility is never treated as compatible. Mark it UNVERIFIED and require a proof of concept before an implementation gate is approved.
