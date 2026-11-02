#!/usr/bin/env bash
set -euo pipefail

root="."
[[ $# -ge 1 ]] || { printf 'Usage: automation-policy.sh [prepare|status|kill]\n' >&2; exit 1; }
action="$1"
root="$(pwd)"
policy="$root/Foundation/11-Autonomous-Operations/AUTONOMY_POLICY.md"
manifest="$root/FOUNDATION_MANIFEST.yaml"

[[ -f "$manifest" ]] || { printf 'Run from a MEW workspace root.\n' >&2; exit 1; }

case "$action" in
  prepare)
    [[ -f "$policy" ]] || cp "$root/templates/autonomy-policy.md" "$policy"
    printf 'Automation policy draft is ready: %s\n' "$policy"
    printf 'Automation remains disabled until the policy is complete and approved.\n'
    ;;
  status)
    grep -A7 '^automation:' "$manifest" || true
    [[ -f "$policy" ]] && printf 'Policy: %s\n' "$policy" || printf 'Policy: not prepared\n'
    ;;
  kill)
    sed -i 's/  enabled: true/  enabled: false/' "$manifest"
    sed -i 's/  mode: .*/  mode: manual # automation stopped by kill switch/' "$manifest"
    printf 'Automation disabled for this workspace.\n'
    ;;
  *)
    printf 'Usage: automation-policy.sh [prepare|status|kill]\n' >&2
    exit 1
    ;;
esac
