# Web engineering reference

Select only the topics relevant to the request; state unknowns instead of presenting a checklist as completed work.

- Product and planning: audiences, goals, mixed modules, priorities, acceptance criteria, budget, release stages and scope changes.
- UX/UI: optional creative brief, page hierarchy, mobile and desktop layouts, accessibility, motion, performance, and image or HTML simulation when tools permit.
- Architecture and stack: frontend, backend, API, identity, data, hosting, compatibility, operating cost, skills required, alternatives and migration path. Check version-specific facts against current primary sources where available.
- Implementation: existing conventions, frontend and backend changes, tests, dependency and license review, application history and traceability. Do not invent completed implementation.
- Data: schema and access boundaries, migration impact, retention, backups and tested restoration; never assume that an application rollback reverses database writes.
- Quality: feature, API, integration and failure tests; accessibility, responsiveness, performance, security, SEO and observability as relevant.
- Deployment and operations: environment boundaries, DNS/TLS, configuration, least privilege, staged deployment, health checks, rollback and incident communication.
- Content: taxonomy, research scope, provenance, rights, freshness, deduplication, pilot batches, capacity and explicit publishing permission.
- Migration and changes: preserve prior Foundation, analyze affected decisions and data, record requested features, and obtain approval for the new implementation scope.

## Decision prompts

Use these internally; ask the developer only what changes the decision.

| Area | Evidence and questions to resolve | Output |
| --- | --- | --- |
| Discovery | Who uses the site, why, what must it do now, what can wait, and what budget or time limits apply? | Goals, users, MVP, priorities and measurable outcomes |
| Mixed modules | How do articles, commerce, games, media or other modules share identity, navigation, data and releases? | Module boundaries, dependencies and phased roadmap |
| UX/UI | What visual direction is supplied? What must work on mobile, keyboard and assistive technology? | Flows, hierarchy, responsive states, design choices and review criteria |
| Technology | Which runtime, data, hosting and third-party combinations fit the use case and skills? | Alternatives, compatibility evidence, operational costs and exit path |
| Application | Which existing conventions, dependencies, APIs and tests constrain the work? | Minimal implementation plan, changed files, tests and traceability |
| Data and identity | Who can access or modify which data? What must be backed up, migrated, retained or deleted? | Roles, data model, migration and restoration plan |
| Quality and security | What can fail, expose data, block users, or regress on another device? | Threats, acceptance tests, accessibility and performance checks |
| Deployment and cloud | What is local, staging or production? How are credentials, DNS, TLS, backup and rollback managed? | Environment map, deployment sequence and recovery plan |
| Live operations | Which service and metrics are authorized? Who receives alerts and approves changes? | Inventory, baseline, health checks, escalation and audit plan |
| Content | What sources and rights apply; what taxonomy, scale, freshness and review process are needed? | Research plan, content map, batch and quality controls |
| Change and migration | What existing decision or data is affected by a forgotten feature or online upgrade? | Change request, impact analysis, preserved snapshot and approval |

For beginners, present a small recommended option and explain why; offer alternatives and a custom choice. For experienced developers, include relevant trade-offs and evidence. Do not force real identity, payments, hosting, a domain or production data into a local prototype.

For current MEW workspaces, use their `Foundation/`, `agent/`, `policies/`, `tools/` and `templates/` as the detailed source of project-specific decisions. If those files are absent, explain what is available and do not assume they exist.
