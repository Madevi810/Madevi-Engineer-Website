# Compatibility Policy

MEW 1.x guarantees that schema version 1 workspaces can be read by MEW 1.x releases.

Plugins are optional and must declare their own compatibility. A plugin that requires a newer MEW version must remain disabled until the developer upgrades.

MEW does not guarantee compatibility with undocumented external provider APIs, prices, permissions, or terms. The agent must verify those current facts when making a provider-specific recommendation.
