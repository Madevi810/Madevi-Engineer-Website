# FigCraft UI/UX Reference Catalog — Clean Room

This catalog maps public FigCraft feature areas into original UWF planning work. It does **not** import, copy, or recreate FigCraft's code, product identity, canvas editor, file formats, plugins, assets, screenshots, or interface composition.

Use it as a complete menu of reference areas. For every item selected by a developer, complete `Reference-Analysis.md`, then produce an original recommendation appropriate to the web project.

| FigCraft public feature area | What may be studied as an abstract UI/UX lesson | UWF adaptation | Classification |
| --- | --- | --- | --- |
| Auto layout, grid, constraints, sizing, spacing, alignment | Responsive hierarchy, reusable spacing rules, and predictable resizing | Record responsive layout rules in Creative Brief and Responsive Review; test mobile, tablet, desktop | Foundation UI/UX |
| Components, variants, overrides, local styles, variables | Design-system consistency, reusable patterns, theme/token planning | Define original component inventory, token decisions, and state variants | Foundation UI/UX |
| Shapes, vectors, fills, gradients, images, effects, masks | Visual language choices and performance-aware decoration | Select original color, imagery, elevation, blur, texture, and density rules; never recreate FigCraft assets/canvas | Foundation UI/UX |
| Typography, text styles, multilingual and RTL support | Reading hierarchy, content density, localization-aware design | Define typography scale, content voice, language/RTL needs, and readable mobile behavior | Foundation UI/UX |
| Prototype flows, triggers, overlays, transitions, presentation | User-flow validation before implementation | Choose only needed interactions, feedback, overlays, loading/error states, and reduced-motion behavior for an original HTML/image simulation | Foundation UI/UX |
| Smart animation, easing, springs, scrolling, fixed/sticky UI | Motion should explain state, not distract or harm performance | Record motion intent, duration/easing range, reduced-motion fallback, scroll/fixed behavior, and device checks | Foundation UI/UX |
| Device frames, preview pane, responsive presentation | Test a design in realistic viewport conditions | Use responsive simulation plan for phone/tablet/desktop; device frames are illustrative, not copied UI | Foundation UI/UX |
| Inspect mode, measurements, annotations, ready-for-dev comparison | Handoff clarity and objective design review | Use acceptance criteria, handover, traceability, visual-review notes, and implementation history | Foundation to implementation handover |
| Comments, mentions, reactions, named version history | Structured review and revision accountability | Use Change Requests, Decision Log, Revision History, and approval fields | Foundation governance |
| Export of image/vector/document assets | Determine what project assets or previews are needed | Specify web export needs and licenses; actual design-file export tooling is not UWF functionality | Optional project requirement |
| Templates such as landing page, dashboard, wireframe kit, design-system starter | Faster, guided starting points without forcing a look | Use UWF's original starter packs and developer-specific Creative Brief | Foundation UI/UX |
| Accessibility: semantic controls, keyboard routing, contrast, reduced motion | Inclusive interaction and visual safety | Complete Responsive-Accessibility-Review; require contrast, keyboard, touch target, and motion checks | Foundation UI/UX |
| Localization and language switching | UI survives translated/long/RTL content | Record supported languages, content expansion, locale formatting, and fallback rules | Optional project requirement |
| Agent control, CLI, JSON inspection, MCP | Agent work should be observable and constrained | UWF uses `AGENTS.md`, manifest, JSON CLI status, and explicit approval gates; no FigCraft protocol/code is used | UWF operation, not UI cloning |
| Plugins with declared permissions and limits | Extensions need visible scope, risk, and fallback | Use UWF plugin disclosure and developer approval; no FigCraft runtime or SDK is used | UWF operation, not UI cloning |
| Live sessions, cursors, shared editing, comments | Collaboration requirements may affect an end-user web product | Ask whether collaboration is a product feature, then create a separate module/Change Request | Optional project requirement |
| Self-hosted sharing server, invite links, online publishing | Hosting/privacy/access choices must be explicit | Plan provider, identity, access, retention, and incident handling in deployment Foundation | Optional project requirement |
| Offline-first behavior, recovery, undo, document history | Safeguards for user work and destructive actions | Define autosave, undo, recovery, audit, rollback, and backup needs if relevant | Optional project requirement |
| Import/export of design files and third-party formats | Interoperability is a separate product commitment | Treat as a specialized module with format, license, safety, and compatibility analysis | Optional project requirement |
| Rendering engine, desktop/native/browser architecture, WebAssembly | Engineering implementation choices, not visual design | Do not import into UWF reference scope; evaluate only through a separate architecture decision if the web product requires it | Out of scope by default |
| FigCraft brand, name, logos, icons, fonts, screenshots, visual composition, source code, `.fig` format, SDK, server protocol | Nothing | Never reuse or imitate | Excluded |

## Required modification rule

Each chosen lesson must become an original UWF result:

1. Explain the developer's actual problem.
2. Produce at least two original options, including a low-complexity option for beginners.
3. Analyze responsive, accessibility, performance, data/privacy, and maintenance impact.
4. Label image or HTML simulation `DRAFT` until developer approval.
5. Open a Change Request if the choice expands scope beyond UI/UX.

## FigCraft reference status

- Reference mode: public-documentation observation only.
- UWF use: optional UI/UX planning input.
- No affiliation, endorsement, dependency, code sharing, or asset sharing.
- Last reviewed: 2026-11-02.
