# Foundation Manifest Schema

MEW 1.x supports manifest schema version 1.

The manifest is the current machine-readable source of truth for:

- project identity and mode;
- developer level and guidance mode;
- Foundation and implementation gate state;
- objectives and modules;
- technology and operation decisions;
- automation controls.
- change-management, UI/UX simulation, and implementation-history state;
- agent runtime capability disclosure;
- engineering-material composition and external-evidence state;
- research/content-operation taxonomy, policy, scale, and publishing state.
- agent orchestration mode, question budget, active roles/tools, status report, and action journal.

Rules:

1. New optional fields may be added in compatible minor releases.
2. Incompatible schema changes require a major version and migration notes.
3. A migration must preserve the old manifest state before changing it; MEW's compatible 1.2 field migration only appends default optional sections.
4. Unknown schema versions are blocked until a compatible MEW version is installed.
