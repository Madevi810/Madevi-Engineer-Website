# MEW Capability Matrix

This matrix describes the current MEW workflow honestly. It is not a promise that every external provider, agent, or local environment supports the same action.

| Capability | Maturity | What MEW provides | Limitation / developer decision |
| --- | --- | --- | --- |
| Progressive Foundation discovery | agent-assisted | Questions, recommendation rules, decisions, and implementation gates | A separate AI runtime performs the conversation and reasoning; developer owns final decisions |
| Change and feature-gap management | stable | Change requests, impact analysis, backlog, and revision history | Analysis must be completed by a developer and/or agent |
| UI/UX planning | stable | Creative brief, responsive/accessibility review, and simulation plan | Not a visual-editor application |
| Image mockup / HTML prototype | agent-assisted | Planning artifacts when the developer explicitly asks | Output quality and available generation tools vary by agent/environment |
| Implementation history | stable | Changelog, technical decisions, traceability, and test evidence templates | Code commits require Git to be enabled by the developer |
| Prototype-to-online migration | preview | Snapshot, gap questions, migration plan, and new gate | The developer selects the target mode; does not provision a cloud provider automatically |
| Plugins and integrations | controlled | Disabled-by-default registry and permission disclosure | External credentials and actions need separate approval |
| Autonomous work | controlled | Policy, budget, rollback, audit, and kill-switch planning | Scheduling/publishing is never enabled by default |
| Collaborative live editing | out of scope | Can be planned as a project feature | MEW itself is not a multiplayer design editor |
| Engineering material composition | agent-assisted | Material categories, composition manifest, lifecycle states, and compatibility review guidance | The catalog is selective; the agent must verify compatibility and version-specific details |
| External technical research | controlled | Research policy, evidence cards, source ranking, and GitHub/official-source review workflow | MEW does not itself provide a web-search account or bypass site rules |
| Content research and production planning | controlled | Taxonomy, source policy, scale/batch plan, rights ledger, QA, and publish queue | Actual research and generation depend on the active agent runtime and developer approval |
| Controlled content automation | controlled | Separate plan, draft, implementation, and publishing gates | Publishing stays disabled until a scoped policy is approved |
| Agent runtime disclosure | agent-assisted | A capability profile to record available tools and limits before research or writes | Availability is declared by the runtime or user; the CLI does not automatically detect external capabilities |
| Foundation Orchestrator | controlled | Role routing, assumptions, question budget, status protocol, escalation rules, and decision trace | Reasoning quality depends on the chosen AI runtime and complete project evidence |
| Tool Runtime | preview | Local tool contracts, capability report, dry-run runner, action journal, job records, and permission gate | Tools do not create external access; only local dry-runs execute by default |
| External adapters | planned | Contracts for GitHub research, web search, deployment, and publishing | A real adapter, scope, runtime access, policy, and approval must exist before any external run |
| Evaluation and regression | preview | Smoke checks, safety regressions, tool-contract validation, and scenario artifacts | These checks do not prove AI reasoning quality, production safety, or correctness on every platform |

Use `DRAFT`, `REVIEW`, `PREVIEW`, `LIMITED`, `STABLE`, or `OUT_OF_SCOPE` when reporting capability status. Never use “stable” for an untested integration merely because its plan is complete.
