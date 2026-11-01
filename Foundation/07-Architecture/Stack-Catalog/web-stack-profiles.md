# Curated Web Stack Profiles

These are starting profiles, not mandatory choices or an exhaustive technology list. Providers and version-specific compatibility must be verified when a real implementation decision is made.

| Profile | Best for | Difficulty | Typical combination | Notes |
| --- | --- | --- | --- | --- |
| Static content | Landing pages, documentation, simple articles | Beginner | Static generator or modern frontend + static host | Lowest operations cost; no server-side user features by default |
| Rapid full-stack web | MVPs, dashboards, simple SaaS | Beginner–Intermediate | React/Next-style full stack + managed Postgres/auth | Fast setup; verify vendor limits and export path |
| PHP business web | CMS, content, commerce, familiar shared hosting | Intermediate | Laravel-style backend + relational database + server-rendered or JS frontend | Strong conventions; needs PHP-capable local/hosting environment |
| JavaScript service web | API-heavy apps and real-time features | Intermediate | TypeScript frontend + Node-style API + Postgres | Flexible; requires careful package/runtime operations |
| Python data/AI web | Data workflows and AI-backed web products | Intermediate–Professional | Python API + web frontend + relational database | Good for Python ecosystems; separate async/worker needs may apply |
| Modular enterprise web | Larger teams, multiple domains, compliance | Professional | Separate frontend/API/services + managed relational data + observability | Use only when real scale or boundaries justify the complexity |
| Browser game | Interactive web games | Intermediate–Professional | Game framework + web frontend + asset pipeline + optional backend | Define device/performance and asset-rights limits early |
| Content/video platform | Articles, animation/video, media library | Intermediate–Professional | Web frontend + CMS/API + object storage + CDN | Storage, encoding, copyright, and moderation become core concerns |

For each selected profile, evaluate auth, database, storage, hosting, backups, observability, local tooling, budget, skills, and migration path. A custom stack is always allowed but must be marked supported, unverified, or incompatible after analysis.
