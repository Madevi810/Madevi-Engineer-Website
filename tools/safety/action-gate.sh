#!/usr/bin/env bash
set -euo pipefail

contract="${1:-}"
[[ -f "$contract" ]] || { printf 'Tool contract not found: %s\n' "$contract" >&2; exit 1; }

field() { awk -F': ' -v key="$1" '$1 == key { print $2; exit }' "$contract"; }
mode="$(field mode)"
approval="$(field approval_required)"

case "$mode" in
  local_read|foundation_write) printf 'ALLOWED_DRY_RUN: %s\n' "$mode" ;;
  external_read) printf 'BLOCKED_UNTIL_RUNTIME_AND_SCOPE: declared external access and approved research scope required\n' ;;
  external_write) printf 'BLOCKED_UNTIL_EXPLICIT_APPROVAL: external write requires policy and developer approval\n' ;;
  *) printf 'BLOCKED_UNKNOWN_MODE: %s\n' "$mode" >&2; exit 1 ;;
esac

if [[ "$approval" == "true" ]]; then
  printf 'APPROVAL_REQUIRED: true\n'
fi
