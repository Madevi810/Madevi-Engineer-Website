# Use MEW with an AI harness

MEW supplies a portable skill, Foundation documents and CLI tools. A compatible harness supplies an AI model and the tools available to the agent. MEW does not install, authenticate, or run the harness for you.

## A new MEW workspace

```bash
mew init Name-Project
cd name-project
```

The new workspace includes `.agents/skills/mew-website-engineer/SKILL.md`. Open the workspace in your compatible harness and ask it to use the `mew-website-engineer` skill. Skill discovery depends on the harness and its trust settings.

## An existing project

From the MEW installation, choose an existing project directory explicitly:

```bash
mew skill install --project /path/to/project --dry-run
mew skill install --project /path/to/project
```

This adds only `.agents/skills/mew-website-engineer/` to that project. It does not replace project instructions or an existing skill of the same name; resolve a collision manually after reviewing it. Do not point the installer at an unrelated or untrusted project. Make a backup or commit before changing important work.

When opening an existing project, ask the AI to use the MEW skill, inspect the project, and propose where to keep a Foundation. Creating a Foundation or altering application files remains subject to the developer's instructions and the applicable MEW gates.

## Hermes and Codex

The `.agents/skills/` layout follows the shared project-skill convention documented by Hermes and Codex. Hermes project-skill discovery applies to Git project roots and requires the project to be explicitly trusted; consult your installed Hermes version's documentation before running its trust command. Other harnesses and versions may need a different installation or explicit loading. This repository does not change harness trust configuration.

- Hermes documentation: https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md
- Codex skill guidance: https://developers.openai.com/blog/skills-agents-sdk

## One-shot observation, not continuous monitoring

If you own or have permission to check an HTTP endpoint:

```bash
mew health check https://example.com/
```

The command makes one request, does not follow redirects, and prints a response status and duration or a network error. Any HTTP response, including an error status, is an observation, not a claim the website is healthy. Do not include credentials or sensitive query strings in command arguments; process lists or shell history may expose them.

Continuous checks, traffic analysis, notifications, automated recovery and control require a real scheduler or external adapter with configured authorization. The skill alone does not enable them. A monitor on the same VPS also cannot independently alert when the entire VPS is unavailable.

The integration tests use Python 3 and its standard library; Python is not required for the skill installer or one-shot HTTP command. Runtime HTTP checks require `curl`.
