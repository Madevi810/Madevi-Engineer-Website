# Changelog

## 2.0.1 - Unreleased

- Limit the automation kill switch to automation fields; external runners still require separate stopping.
- Validate selected Foundation details, supported modes, and active reference records before implementation approval; restore the previous approval state if project activation fails.
- Archive the previous Foundation and manifest before preparing an online upgrade, preserve the current project mode, and reopen the Foundation gate for review.
- Make dry-run output honest about work not performed and give tool jobs unique names.
- Add safety regression tests and clarify the boundaries of AI reasoning, adapters, and runtime capability detection.

## 2.0.0 - 2026-11-03

- Renamed the project to Madevi Engineer Website (MEW), including documentation, workspace identity, manifests, previews, policies, and machine-readable output.
- Added `mew` as the primary command for Madevi Engineer Website workflows.
- Updated installer, update, uninstall, and workspace migration paths for the new repository and command identity.

## 1.3.0 - 2026-11-03

- Added the Agent Orchestrator architecture: autonomous Foundation composition, three-question budget, explicit assumptions, specialist routing, status protocol, and escalation rules.
- Added a provider-neutral Tool Runtime with tool contracts, local dry-run runner, permission/action gates, job records, adapter boundaries, and action journal.
- Added structured policies, schemas, evaluation scenarios, expected artifacts, negative tests, and regression runner.
- Added local workspace inspection, capability reporting, manifest checks, tool-contract validation, evaluation commands, and AI-agent routing commands.
- Rewrote the public README with beginner-friendly workflow, honest limits, safety model, tool usage, and `Name-Project` examples.

## 1.2.0 - 2026-11-02

- Reworked the v1.2 Foundation architecture around engineering-material composition, external evidence, agent-runtime truthfulness, and research/content operations rather than adding isolated templates.
- Added structured material lifecycle, Composition Manifest, Evidence Cards, source/trust policy, rights ledger, content taxonomy, scale/batch planning, production queue, and controlled publish policy.
- Added explicit separation between UI inspiration, engineering dependencies, factual sources, and creative-content references.
- Added CLI preparation/status commands for materials, evidence, composition, research, taxonomy, content operations, and validation; they create planning artifacts and do not silently search or publish.
- Added runtime capability, evidence, composition, and content-operation fields to the workspace manifest and gate checks.
- Added evaluation scenarios and negative tests for unavailable research access, incomplete source policy, unresolved rights, and content automation without approval.
- Added an original capability-maturity matrix, starter Foundation packs, clean-room reference-analysis workflow, and release-readiness checklist.
- Added plugin inspection with declared permissions, data scope, write effects, risk level, and fallback.
- Added CLI commands for templates, references, capability status, and release readiness.
- Scoped external-reference work to UI/UX Foundation by default, with FigCraft recorded only as a review-required UI/UX reference.
- Added a full FigCraft public-feature reference catalog that maps each relevant area to original MEW planning, optional product scope, or exclusion.
- Added active UI/UX reference status, a FigCraft analysis draft command, and a gate check for unanalyzed active references.
- Added validated `mew reference complete` and generic custom-reference workflow so active UI/UX references do not require manual manifest editing.

## 1.1.0 - 2026-11-02

- Added change-request, impact-analysis, backlog, and revision-history Foundation workflow for forgotten or late features.
- Added implementation-history, decision, traceability, and changelog templates to activated project workspaces.
- Added feature-gap audit and optional UI/UX creative-brief, responsive/accessibility, and simulation planning artifacts.
- Added agent-safe `context`, `status --json`, `next --json`, and `validate --json` CLI output.

## 1.0.2 - 2026-11-01

- Fixed CLI root resolution when the mew command is invoked through its installed symlink.

## 1.0.1 - 2026-11-01

- Changed new installation to resolve the newest stable semantic-version tag by default.
- Added patch-safe update behavior; minor, major, and edge updates now require explicit choices.
- Added atomic install validation, backup of prior CLI installation, and update safety checks.

## 1.0.0 - 2026-11-01

- Declared manifest schema version 1 and MEW 1.x compatibility policy.
- Added manifest compatibility checks, local release package/checksum creation, and guarded CLI uninstall.
- Marked the Foundation, CLI, validation, migration, plugin, automation, and governance baseline as stable.

## 0.9.0 - 2026-11-01

- Added repository hardening checks, issue templates, code of conduct, and release policy.
- Added version-selectable installer behavior.
- Added CI checks for repository structure, semantic versioning, and common secret patterns.

## 0.8.0 - 2026-11-01

- Added automation safety rules, policy preparation, status, and kill switch commands.
- Added validation for enabled automation without a policy.
- Kept scheduling, publishing, and external provider execution outside the default CLI.

## 0.7.0 - 2026-11-01

- Added project-scoped plugin listing, enable, and disable commands.
- Added plugin policy and explicit plugin approval template.
- Kept external credentials and provider actions outside plugin activation.

## 0.6.0 - 2026-11-01

- Added draft prototype-to-online migration workflow.
- Added automatic Foundation snapshot, online upgrade questions, migration plan, and blocked implementation gate.

## 0.5.0 - 2026-11-01

- Added machine-readable stack profiles and compatibility rules.
- Added provider-class decision guidance and stack decision template.
- Added CLI stack list and stack advise commands.

## 0.4.0 - 2026-11-01

- Added CLI diagnostics, version, next-step, stage-review, and update-capability commands.
- Added clear CLI documentation and non-destructive update behavior.

## 0.3.0 - 2026-11-01

- Added a status-based Foundation validation engine.
- Added gate validation for developer level, guidance mode, project mode, primary objective, Foundation readiness, and critical risks.
- Prevented implementation activation when the implementation gate is blocked.

## 0.2.0 - 2026-11-01

- Added a progressive Question Bank for beginner, intermediate, and professional developer journeys.
- Added project-mode and module-specific discovery packs for content, commerce, browser games, animation/video, and autonomous operations.
- Defined question completion, recommendation, custom-choice, and stage-review rules.

## 0.1.0 - 2026-11-01

Initial public Foundation architecture: staged analysis, developer guidance modes, project-mode planning, migration planning, autonomous-operation policy, optional Git/GitHub integration model, and Linux CLI bootstrap.
