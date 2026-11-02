# Contributing to MEW

Thank you for improving Madevi Engineer Website.

## Contribution principles

- Preserve Foundation-first behavior; do not add application code to the template project directory.
- Keep integrations optional and provider-neutral.
- Add recommendations with trade-offs, known limits, and version/date context.
- Do not add credentials, private URLs, or secret values.
- Use clear language for beginners without removing professional detail.

## Pull requests

1. Create a branch.
2. Update the relevant docs, templates, and manifest schema together.
3. Run `bash tests/smoke.sh`.
4. Explain compatibility and migration impact in the pull request.

Major schema changes require a migration note in `docs/migration/`.
