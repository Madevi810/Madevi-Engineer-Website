# Plugin Policy

Plugins extend UWF but never replace Core Foundation rules.

- All plugins are disabled by default.
- Enabling a plugin records a project decision only; it does not grant external credentials or perform provider actions.
- The agent must explain purpose, permissions, dependencies, risks, and fallback before a developer enables a plugin.
- A plugin may be disabled at any time.
- Production credentials are never stored in enabled.yaml.
- Every plugin must disclose requested permissions, data scope, write effects, risk level, and fallback before it is enabled.
- Use `uwf plugin inspect plugin-id` before enabling a plugin. Enabling remains a project decision; it never grants credentials or publishes anything.
