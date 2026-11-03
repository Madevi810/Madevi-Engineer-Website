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

To update a previously installed project skill after updating the MEW CLI:

```bash
mew skill update --project /path/to/project --dry-run
mew skill update --project /path/to/project
```

Update preserves the complete previous skill directory under `.agents/mew-backups/` before installing the newer copy. This replaces the active project skill, so review and reapply any local customizations from the backup. It does not edit `AGENTS.md` or update other projects automatically.

When opening an existing project, ask the AI to use the MEW skill, inspect the project, and propose where to keep a Foundation. Creating a Foundation or altering application files remains subject to the developer's instructions and the applicable MEW gates.

To inventory a project without running its code or writing a Foundation, use `mew inspect project /path/to/project --json` (requires Python 3). This bounded scan skips dependency folders, symbolic links, most hidden directories, and `.env` files. It reads only selected small manifest files for recognized framework names; output includes relative evidence paths, scan limits and unknown areas. It does not verify running services, traffic, database connectivity, security or compatibility. It is not a sandbox against a hostile filesystem being changed concurrently. Project paths and results may be sensitive: review any external AI or service's data handling before sharing them.

For a user-authorized local system, `mew observe system /path/to/project --json` returns a one-shot disk, memory and load snapshot; `mew observe service nginx.service --json` requests the named local systemd service state. The disk measurement concerns the filesystem containing the chosen directory, not just files in that directory. Memory and load refer to the environment visible to the command; container limits may differ. Systemd may be unavailable or permissions may restrict observations. Neither command verifies website health or modifies a service.

The installed MEW library can be read without a project workspace:

```bash
mew library map
mew library materials
mew library stack
mew library path
```

The path identifies the installed general materials; it is not the project's own Foundation. If only the portable skill was copied and the CLI is unavailable, the harness can still read the references bundled with that skill.

## Hermes and Codex

The `.agents/skills/` layout follows the shared project-skill convention documented by Hermes and Codex. Hermes project-skill discovery applies to Git project roots and requires the project to be explicitly trusted; consult your installed Hermes version's documentation before running its trust command. Other harnesses and versions may need a different installation or explicit loading. This repository does not change harness trust configuration.

- Hermes documentation: https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md
- Codex skill guidance: https://developers.openai.com/blog/skills-agents-sdk

## HTTP observation and foreground monitoring

If you own or have permission to check an HTTP endpoint:

```bash
mew health check https://example.com/
```

The command makes one request, does not follow redirects, and prints a response status and duration or a network error. Any HTTP response, including an error status, is an observation, not a claim the website is healthy. Do not include credentials or sensitive query strings in command arguments; process lists or shell history may expose them.

For repeated checks in the foreground, explicitly start:

```bash
mew health watch https://example.com/ --interval 60 --count 3
```

Omit `--count` to continue until stopped with Ctrl-C. The interval is 10–86400 seconds between completed checks; each line is a timestamped JSON observation. This is a foreground process: it stops when the process or hosting session stops. It does not install a daemon, send alerts, inspect traffic, restart services, or guarantee availability. A persistent runner and alerting require separate configuration and authorization. A monitor on the same VPS also cannot independently alert when the entire VPS is unavailable.

The integration tests use Python 3 and its standard library; Python is not required for the skill installer or one-shot HTTP command. Runtime HTTP checks require `curl`.
