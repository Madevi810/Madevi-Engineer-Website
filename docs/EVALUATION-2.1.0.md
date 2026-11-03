# MEW 2.1.0 evaluation

## Implemented

- A portable project skill covers Foundation, existing applications, approved implementation, and live-operations guidance.
- `mew skill update --project` explicitly updates a project skill while retaining the previous copy, including project-specific modifications.
- `mew init` includes the skill; `mew skill install --project` installs it without replacing an existing skill or project instructions.
- `mew health check` performs one explicitly requested HTTP observation; `mew health watch` repeats observations in the foreground. Neither installs a service or controls a server.
- `mew inspect project` produces a bounded, read-only project inventory with evidence and unverified fields; Python 3 is required for this command.
- `mew observe system` and `mew observe service` provide one-shot read-only local snapshots; systemd access is optional and unavailable status is reported explicitly.

## Verified

- Automated tests create new and existing projects, test dry-run and collision handling, reject symlinked skill paths, and exercise HTTP checks and bounded foreground repetition against a local server with 200, 302, 503, credential rejection and connection failure cases.
- Skill-update tests verify that a locally modified prior copy is retained in a backup and that symlinked backup directories are rejected.
- The smoke and safety regression suites pass with the skill integration tests.
- Inspector tests cover mixed-framework fixtures, private values, symbolic links, depth limits, invalid and oversized manifests, and absence of project writes or executed scripts.
- System observation tests cover real local filesystem metrics and simulated systemd success, failure, and invalid service names.
- A project containing the installed skill was evaluated with the project-root discovery, safety scanner, and frontmatter parser from the Hermes source at commit `b200f5bc60e31588ba2cb60e288029c4a54ba5fa`. This exercised the discovery components on an isolated local Git project; it did not run a complete Hermes session or verify an AI model's behavior.
- The Hermes project trust decision was exercised with isolated simulated trusted and untrusted configurations; untrusted project skills were not returned, while the trusted skill was discovered. The complete Hermes tool runtime could not be imported in this environment because its `ruamel.yaml` dependency is missing; an authenticated model session remains untested.

## Limits and further work

- Hermes and Codex versions may differ. A full live session with each harness, trust configuration, and an authenticated model still needs user-environment testing. Other harnesses are unverified.
- The skill gives the harness guidance and one local tool; it is not a standalone agent or a guarantee of complete engineering judgment.
- Persistent background monitoring, database inspection, alerting, deployment, external research, recovery and live control are not implemented by this update. They need real adapters, explicit permissions, safe failure behavior and dedicated tests.
- A single HTTP response is not full website health. The caller must authorize the endpoint; credentials and sensitive query strings must not be placed in command arguments.
