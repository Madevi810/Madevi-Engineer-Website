# Engineering Materials

This is UWF's reusable engineering-material library. It is not a vendor list and it is not a copy of external packages. A material is a selectable engineering option, pattern, control, or operational capability with a known purpose, fit, risk, lifecycle, and evidence trail.

## Required composition workflow

1. Understand the developer's objective and module hierarchy.
2. Inspect the internal Material Catalog and Compatibility Matrix.
3. Select, reject, or defer materials with reasons.
4. Escalate to external evidence only when the internal material is insufficient or requires current verification.
5. Record the result in `Composition-Manifest.md`.
6. Ask for a decision before a material changes an approved scope, cost, provider, or implementation.

## Material groups

| Group | Includes |
| --- | --- |
| Product | roles, journeys, MVP boundary, acceptance criteria, release strategy |
| Experience | information architecture, responsive layout, design tokens, accessibility, localization |
| Application | frontend rendering, backend/API, realtime, jobs, caching, search, integrations |
| Data | relational/document data, taxonomy, media metadata, retention, backup, recovery |
| Trust | identity, authorization, privacy, secrets, audit, dependency and supply-chain controls |
| Quality | test strategy, performance, observability, incident response, release checks |
| Operations | local setup, deployment, domain, storage, CI/CD, cost, vendor exit |
| Content | source policy, CMS, media pipeline, moderation, rights, production and publish controls |

Use `Material-Catalog.md` for the required assessment fields and `Material-Lifecycle.md` for status meanings.
