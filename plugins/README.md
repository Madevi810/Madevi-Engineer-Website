# Plugin Policy

Plugins extend UWF but never replace Core Foundation rules.

- All plugins are disabled by default.
- Enabling a plugin records a project decision only; it does not grant external credentials or perform provider actions.
- The agent must explain purpose, permissions, dependencies, risks, and fallback before a developer enables a plugin.
- A plugin may be disabled at any time.
- Production credentials are never stored in enabled.yaml.
