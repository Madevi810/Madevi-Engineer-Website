# Tool Contract Format

Every tool contract must declare `id`, `mode`, `purpose`, `requires`, `permissions`, `dry_run`, `approval_required`, `risk_level`, `writes`, `fallback`, and `audit_log`.

Contracts are validated by `tools/validators/validate-tool-contracts.sh`. Unknown contract fields may be added, but required fields may not be omitted.
