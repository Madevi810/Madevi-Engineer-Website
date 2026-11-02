#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
failed=0
required=(id mode purpose requires permissions dry_run approval_required risk_level writes fallback audit_log)

for contract in "$root"/tools/contracts/*.yaml; do
  [[ -f "$contract" ]] || continue
  for field in "${required[@]}"; do
    grep -q "^$field:" "$contract" || { printf 'Missing %s in %s\n' "$field" "$contract" >&2; failed=1; }
  done
  mode="$(awk -F': ' '$1 == "mode" { print $2; exit }' "$contract")"
  case "$mode" in local_read|foundation_write|external_read|external_write) ;; *) printf 'Unknown mode in %s: %s\n' "$contract" "$mode" >&2; failed=1 ;; esac
done

[[ "$failed" -eq 0 ]] || exit 1
printf 'Tool contracts validated.\n'
