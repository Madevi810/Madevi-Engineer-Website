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

known() {
  grep -Eq "^  - id: $1$" "$registry"
}

case "$action" in
  list)
    printf 'Available plugins:\n'
    grep -E '^  - id:' "$registry" | sed -E 's/^  - id: /- /'
    printf '\nEnabled plugins:\n'
    grep -E '^  - ' "$enabled" | sed -E 's/^  - /- /' || true
    ;;
  enable)
    [[ $# -eq 1 ]] || { printf 'Usage: plugin-manager.sh enable plugin-id\n' >&2; exit 1; }
    known "$1" || { printf 'Unknown plugin: %s\n' "$1" >&2; exit 1; }
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
    known "$1" || { printf 'Unknown plugin: %s\n' "$1" >&2; exit 1; }
    sed -i "/^  - $1$/d" "$enabled"
    printf 'Plugin disabled for this workspace: %s\n' "$1"
    ;;
  *)
    printf 'Usage: plugin-manager.sh [list|enable|disable] [plugin-id]\n' >&2
    exit 1
    ;;
esac
