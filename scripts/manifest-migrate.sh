#!/usr/bin/env bash
set -euo pipefail

root="."
[[ $# -eq 0 ]] || root="$1"
manifest="$root/FOUNDATION_MANIFEST.yaml"
[[ -f "$manifest" ]] || { printf 'Manifest not found: %s\n' "$manifest" >&2; exit 1; }

schema="$(grep -E '^schema_version:' "$manifest" | head -n 1 | sed -E 's/^schema_version:[[:space:]]*//')"
case "$schema" in
  1) printf 'Manifest schema 1 is supported by UWF 1.1.\n' ;;
  *) printf 'Unsupported manifest schema: %s\n' "$schema" >&2; exit 1 ;;
esac
