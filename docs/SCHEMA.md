# Foundation Manifest Schema

UWF 1.x supports manifest schema version 1.

The manifest is the current machine-readable source of truth for:

- project identity and mode;
- developer level and guidance mode;
- Foundation and implementation gate state;
- objectives and modules;
- technology and operation decisions;
- automation controls.
- change-management, UI/UX simulation, and implementation-history state.

Rules:

1. New optional fields may be added in compatible minor releases.
2. Incompatible schema changes require a major version and migration notes.
3. A migration must snapshot the old manifest before changing it.
4. Unknown schema versions are blocked until a compatible UWF version is installed.
