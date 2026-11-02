#!/usr/bin/env bash
set -euo pipefail

root="."
[[ $# -ge 1 ]] || { printf 'Usage: plugin-manager.sh [list|enable|disable] [plugin-id]\n' >&2; exit 1; }
action="$1"
shift
registry="plugins/registry.yaml"
enabled="plugins/enabled.yaml"

[[ -f "$registry" ]] || { printf 'Plugin registry not found in current workspace.\n' >&2; exit 1; }
[[ -f "$enabled" ]] || printf 'enabled: []\n' >"$enabled"

valid_id() {
  [[ "$1" =~ ^[a-z][a-z0-9_-]*$ ]]
}

known() {
  grep -Fxq "  - id: $1" "$registry"
}

inspect() {
  awk -v id="$1" '
    $0 == "  - id: " id { show=1 }
    show && $0 ~ /^  - id: / && $0 != "  - id: " id { exit }
    show { print }
  ' "$registry"
}

case "$action" in
  list)
    printf 'Available plugins:\n'
    grep -E '^  - id:' "$registry" | sed -E 's/^  - id: /- /'
    printf '\nEnabled plugins:\n'
    grep -E '^  - ' "$enabled" | sed -E 's/^  - /- /' || true
    ;;
  inspect)
    [[ $# -eq 1 ]] || { printf 'Usage: plugin-manager.sh inspect plugin-id\n' >&2; exit 1; }
    valid_id "$1" || { printf 'Invalid plugin ID: %s\n' "$1" >&2; exit 1; }
    known "$1" || { printf 'Unknown plugin: %s\n' "$1" >&2; exit 1; }
    printf 'Plugin disclosure (review before enabling):\n'
    inspect "$1"
    ;;
  enable)
    [[ $# -eq 1 ]] || { printf 'Usage: plugin-manager.sh enable plugin-id\n' >&2; exit 1; }
    valid_id "$1" || { printf 'Invalid plugin ID: %s\n' "$1" >&2; exit 1; }
    known "$1" || { printf 'Unknown plugin: %s\n' "$1" >&2; exit 1; }
    printf 'Plugin disclosure (developer decision required):\n'
    inspect "$1"
    if grep -Fxq "  - $1" "$enabled"; then
      printf 'Plugin already enabled: %s\n' "$1"
    else
      if grep -Fqx 'enabled: []' "$enabled"; then
        printf 'enabled:\n  - %s\n' "$1" >"$enabled"
      else
        printf '  - %s\n' "$1" >>"$enabled"
      fi
      printf 'Plugin enabled for this workspace: %s\n' "$1"
    fi
    ;;
  disable)
    [[ $# -eq 1 ]] || { printf 'Usage: plugin-manager.sh disable plugin-id\n' >&2; exit 1; }
    valid_id "$1" || { printf 'Invalid plugin ID: %s\n' "$1" >&2; exit 1; }
    known "$1" || { printf 'Unknown plugin: %s\n' "$1" >&2; exit 1; }
    sed -i "/^  - $1$/d" "$enabled"
    printf 'Plugin disabled for this workspace: %s\n' "$1"
    ;;
  *)
    printf 'Usage: plugin-manager.sh [list|inspect|enable|disable] [plugin-id]\n' >&2
    exit 1
    ;;
esac
