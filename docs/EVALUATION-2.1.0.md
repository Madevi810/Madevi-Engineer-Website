# MEW 2.1.0 evaluation

## Implemented

- A portable project skill covers Foundation, existing applications, approved implementation, and live-operations guidance.
- `mew init` includes the skill; `mew skill install --project` installs it without replacing an existing skill or project instructions.
- `mew health check` performs one explicitly requested HTTP observation. It does not install monitoring or control a server.

## Verified

- Automated tests create new and existing projects, test dry-run and collision handling, reject symlinked skill paths, and exercise the HTTP tool against a local server with 200, 302, 503, credential rejection and connection failure cases.
- The smoke and safety regression suites pass with the skill integration tests.
- A project containing the installed skill was evaluated with the project-root discovery, safety scanner, and frontmatter parser from the Hermes source at commit `b200f5bc60e31588ba2cb60e288029c4a54ba5fa`. This exercised the discovery components on an isolated local Git project; it did not run a complete Hermes session or verify an AI model's behavior.

## Limits and further work

- Hermes and Codex versions may differ. A full live session with each harness, trust configuration, and an authenticated model still needs user-environment testing. Other harnesses are unverified.
- The skill gives the harness guidance and one local tool; it is not a standalone agent or a guarantee of complete engineering judgment.
- Recurring monitoring, service or database inspection, alerting, deployment, external research, recovery and live control are not implemented by this update. They need real adapters, explicit permissions, safe failure behavior and dedicated tests.
- A single HTTP response is not full website health. The caller must authorize the endpoint; credentials and sensitive query strings must not be placed in command arguments.
