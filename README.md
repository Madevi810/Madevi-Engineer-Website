# Universal Web Foundation

Current stable version: 1.0.0

Universal Web Foundation (UWF) is an open-source, AI-ready planning and governance workspace for web projects. It helps a developer and an AI agent turn an idea into an approved web implementation without forcing a fixed stack, provider, or level of experience.

UWF is for websites, web applications, dashboards, SaaS, commerce, content platforms, browser games, and mixed platforms. It is not a native iOS, Android, desktop, or embedded-app framework.

## What UWF does

- Adapts questions and recommendations for beginner, intermediate, and professional developers.
- Supports either full AI guidance or AI recommendations with a complete choice list and a custom-answer option.
- Builds a Foundation in safe stages: objectives, users, project mode, modules, MVP, UX/UI, architecture, operations, and quality.
- Prevents implementation from starting until the relevant stage is analyzed and approved.
- Supports prototype-local, prototype-online, beta, and production-online modes.
- Plans a controlled migration from prototype to online production while retaining the archived prototype foundation.
- Supports optional automation with explicit scope, budgets, quality gates, logs, rollback, and a kill switch.

## Quick start

After installing the CLI, run:

```bash
uwf
```

The interactive flow asks for a project name and creates a workspace. Advanced users may use:

```bash
uwf init nama-web
```

Open the generated workspace in an AI coding environment and ask the agent to read `AGENTS.md` and `FOUNDATION_MANIFEST.yaml` first.

## Workspace lifecycle

```text
Discovery and Foundation
  -> stage analysis
  -> developer approval
  -> implementation of an approved stage
  -> review and change analysis
  -> next stage, upgrade, or release
```

The template starts with `Project-Implementasi/` locked for application code. When the implementation gate is approved, use `uwf approve implementation --project "Nama Web"` to rename it to `Project-Nama-Web/` and create a minimal implementation skeleton.

## Important documents

| File | Audience | Purpose |
| --- | --- | --- |
| `README.md` | Humans | Installation and high-level usage |
| `AGENTS.md` | AI agents | Mandatory operating rules |
| `FOUNDATION_MANIFEST.yaml` | Humans and agents | Current machine-readable project state |
| `Foundation/` | Humans and agents | Decisions, questions, analysis, reports, and handover |

## Installation from GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/Madevi810/universal-web-foundation/main/scripts/install.sh -o install-uwf.sh
less install-uwf.sh
bash install-uwf.sh
```

The installer uses no root access and installs the newest stable release into `~/.local/bin`. It needs `bash`, `curl`, and `git`. Use `--edge` only when intentionally testing the moving main branch.

## Open-source scope

UWF is deliberately provider-neutral. Git, GitHub, Docker, hosting providers, databases, payment services, content automation, and AI providers are optional integrations. The core Foundation works offline after installation.

See [Foundation/README.md](Foundation/README.md) for the Foundation map and [docs/beginner/START-HERE.md](docs/beginner/START-HERE.md) for the beginner path.
