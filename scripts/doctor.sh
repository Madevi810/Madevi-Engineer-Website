#!/usr/bin/env bash
set -euo pipefail

failed=0

check_command() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'OK      %s: %s\n' "$1" "$(command -v "$1")"
  else
    printf 'MISSING %s\n' "$1" >&2
    failed=$((failed + 1))
  fi
}

printf 'MEW environment diagnostics\n'
check_command bash
check_command git
check_command sed
check_command grep

if command -v python3 >/dev/null 2>&1; then
  printf 'OK      python3: %s (project inspection and local observations)\n' "$(command -v python3)"
else
  printf 'OPTIONAL python3 missing: project inspection and local observations unavailable\n'
fi
if command -v curl >/dev/null 2>&1; then
  printf 'OK      curl: %s (HTTP observations)\n' "$(command -v curl)"
else
  printf 'OPTIONAL curl missing: HTTP observations unavailable\n'
fi

if [[ -d "$HOME/.local/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) printf 'OK      PATH includes %s\n' "$HOME/.local/bin" ;;
    *) printf 'WARNING PATH does not include %s\n' "$HOME/.local/bin" ;;
  esac
else
  printf 'WARNING %s does not exist yet\n' "$HOME/.local/bin"
fi

if [[ "$failed" -gt 0 ]]; then
  printf 'Doctor result: action required.\n' >&2
  exit 1
fi

printf 'Doctor result: ready.\n'
