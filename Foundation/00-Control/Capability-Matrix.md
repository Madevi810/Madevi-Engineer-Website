# UWF Capability Matrix

This matrix describes the current UWF workflow honestly. It is not a promise that every external provider, agent, or local environment supports the same action.

| Capability | Maturity | What UWF provides | Limitation / developer decision |
| --- | --- | --- | --- |
| Progressive Foundation discovery | stable | Questions, recommendations, decisions, and implementation gates | Developer still owns final decisions |
| Change and feature-gap management | stable | Change requests, impact analysis, backlog, and revision history | Analysis must be completed by a developer and/or agent |
| UI/UX planning | stable | Creative brief, responsive/accessibility review, and simulation plan | Not a visual-editor application |
| Image mockup / HTML prototype | agent-assisted | Planning artifacts when the developer explicitly asks | Output quality and available generation tools vary by agent/environment |
| Implementation history | stable | Changelog, technical decisions, traceability, and test evidence templates | Code commits require Git to be enabled by the developer |
| Prototype-to-online migration | stable | Snapshot, gap questions, migration plan, and new gate | Does not provision a cloud provider automatically |
| Plugins and integrations | controlled | Disabled-by-default registry and permission disclosure | External credentials and actions need separate approval |
| Autonomous work | controlled | Policy, budget, rollback, audit, and kill-switch planning | Scheduling/publishing is never enabled by default |
| Collaborative live editing | out of scope | Can be planned as a project feature | UWF itself is not a multiplayer design editor |
| Engineering material composition | stable | Structured material categories, composition manifest, lifecycle states, and compatibility review | The agent must still verify version-specific implementation details |
| External technical research | controlled | Research policy, evidence cards, source ranking, and GitHub/official-source review workflow | UWF does not itself provide a web-search account or bypass site rules |
| Content research and production planning | controlled | Taxonomy, source policy, scale/batch plan, rights ledger, QA, and publish queue | Actual research and generation depend on the active agent runtime and developer approval |
| Controlled content automation | controlled | Separate plan, draft, implementation, and publishing gates | Publishing stays disabled until a scoped policy is approved |
| Agent runtime disclosure | stable | A capability profile that states available tools and limits before research or writes | An unavailable tool must be reported, never simulated |

Use `DRAFT`, `REVIEW`, `PREVIEW`, `LIMITED`, `STABLE`, or `OUT_OF_SCOPE` when reporting capability status. Never use “stable” for an untested integration merely because its plan is complete.
