# Compatibility Policy

UWF 1.0 guarantees that schema version 1 workspaces can be read by UWF 1.x releases.

Plugins are optional and must declare their own compatibility. A plugin that requires a newer UWF version must remain disabled until the developer upgrades.

UWF does not guarantee compatibility with undocumented external provider APIs, prices, permissions, or terms. The agent must verify those current facts when making a provider-specific recommendation.
