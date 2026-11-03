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
    temporary="$(mktemp "${manifest}.tmp.XXXXXX")"
    awk '
      /^automation:$/ { active=1; print; next }
      active && /^[^[:space:]]/ { active=0 }
      active && /^  enabled:/ { print "  enabled: false"; next }
      active && /^  mode:/ { print "  mode: manual # automation stopped by kill switch"; next }
      active && /^  kill_switch:/ { print "  kill_switch: true"; next }
      { print }
    ' "$manifest" >"$temporary"
    mv "$temporary" "$manifest"
    printf 'Automation disabled in the workspace policy; any external runner must also be stopped separately.\n'
    ;;
  *)
    printf 'Usage: automation-policy.sh [prepare|status|kill]\n' >&2
    exit 1
    ;;
esac
