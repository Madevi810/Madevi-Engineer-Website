#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
catalog="$root/Foundation/07-Architecture/Stack-Catalog/stack-profiles.yaml"
action="list"
[[ $# -eq 0 ]] || action="$1"

case "$action" in
  list)
    printf 'Available MEW stack profiles:\n'
    grep -E '^  - id:' "$catalog" | sed -E 's/^  - id: /- /'
    ;;
  advise)
    printf 'Choose stack only after project mode, active modules, developer level, and budget class are known.\n'
    printf 'Use templates/stack-decision.md and record custom choices as UNVERIFIED until tested.\n'
    ;;
  *)
    printf 'Usage: stack-advisor.sh [list|advise]\n' >&2
    exit 1
    ;;
esac
