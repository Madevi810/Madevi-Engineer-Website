#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
url="${1:-}"
[[ -n "$url" ]] || { printf 'Usage: watch-http.sh URL [--interval SECONDS] [--count N]\n' >&2; exit 1; }
shift
interval=60
count=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --interval) [[ $# -ge 2 ]] || exit 1; interval="$2"; shift 2 ;;
    --count) [[ $# -ge 2 ]] || exit 1; count="$2"; shift 2 ;;
    *) printf 'Unknown watch option: %s\n' "$1" >&2; exit 1 ;;
  esac
done
[[ "$interval" =~ ^[1-9][0-9]{0,4}$ && "$count" =~ ^(0|[1-9][0-9]{0,4})$ ]] || { printf 'Invalid interval or count.\n' >&2; exit 1; }
(( interval >= 10 && interval <= 86400 && count <= 10000 )) || { printf 'Interval must be 10-86400 seconds; count must be 0-10000.\n' >&2; exit 1; }
run=0
while :; do
  if result="$(bash "$script_dir/health-check.sh" "$url")"; then
    :
  else
    code=$?
    [[ "$code" -eq 2 ]] || exit "$code"
  fi
  printf '{"time":"%s","result":%s}\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$result"
  run=$((run + 1))
  (( count == 0 || run < count )) || break
  sleep "$interval"
done
