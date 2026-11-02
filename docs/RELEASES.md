# Releases

MEW uses semantic versioning.

- Patch versions fix defects without changing Foundation behavior.
- Minor versions add backward-compatible capability.
- Major versions may change the manifest schema or plugin contract.

Every release must include:

1. Updated VERSION and CHANGELOG.
2. Smoke tests and repository checks.
3. A compatibility note.
4. Migration instructions for manifest changes.
5. A Git tag and checksum artifacts when release automation is available.

Never silently update an installed MEW copy. Developers choose when to update.
