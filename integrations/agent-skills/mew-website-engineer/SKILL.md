---
name: mew-website-engineer
description: Plan, build, inspect, test, deploy, maintain, and diagnose websites and web applications with the Madevi Engineer Website workflow. Use when a developer asks for website engineering, an existing web project, or authorized live website monitoring and operations.
---

# MEW website engineer

Work as a web engineering companion to the active AI harness. Use only tools and permissions actually available in that harness; this skill does not supply an AI model, scheduler, deployment access, or monitoring service.

## Route the task

1. Identify whether the user wants a new Foundation, implementation of an approved stage, work on an existing project, or live operations. Respect the user's requested scope and experience; explain choices in plain language when helpful.
2. Inspect relevant project instructions and, when present, `AGENTS.md`, `FOUNDATION_MANIFEST.yaml`, open questions, decisions, active stage, status and composition. If available, `mew inspect project DIRECTORY --json` provides a bounded read-only inventory; interpret its evidence and unverified fields, not as proof of running services. Never overwrite an existing project or create a MEW Foundation inside production without authorization. If no MEW workspace exists, propose where to keep the Foundation; an explicitly requested read-only diagnosis may proceed within the authorized scope.
3. For a new Foundation, first establish experience level and whether the user wants full recommendations or recommendations with custom choices. Ask only decisions that materially change the work. Make safe assumptions visible; preserve multiple goals and developer choices.
4. Select relevant engineering areas from `references/engineering.md`. Analyze objectives, constraints, compatibility, risks, cost, evidence, acceptance criteria, and implementation stages. Cite verified sources when fresh provider or version information matters; state when research is unavailable.
5. Do not write application code into an unapproved MEW Foundation stage. Once the applicable Foundation and implementation gate are approved, use the harness to implement and test only the approved scope. Record forgotten features and changed objectives as change requests and assess their impact.
6. For live website work, read `references/live-operations.md`. Start with the authorized read-only scope. Separate observed facts from guesses. Require the applicable approval before production writes, deployment, data changes, or access changes; follow a reviewed recovery plan.
7. Report the outcome, evidence, tests, limitations, remaining risks and next decision. Never claim a test, search, deployment, health check, or continuous monitoring occurred unless it actually did.

## Authorized website observation

Resolve script paths relative to this skill's directory. When the developer authorizes an HTTP request to a specific endpoint, `scripts/health-check.sh URL` performs one bounded request and prints an HTTP status or network error without printing the URL. `scripts/watch-http.sh URL` repeats this observation in the foreground until stopped, or for a bounded `--count`; use it only when the user requests monitoring. Neither command installs a service or ensures the harness stays running. Do not pass credentials in URLs or command arguments. A response does not prove the application, database, or overall service is healthy. Do not probe unapproved targets. These scripts do not send alerts, scan security, restart services or repair software.
