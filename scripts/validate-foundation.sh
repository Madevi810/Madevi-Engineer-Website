#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"
root="$(cd "$root" && pwd)"
required=(
  "AGENTS.md"
  "FOUNDATION_MANIFEST.yaml"
  "Foundation/00-Control/Open-Questions.md"
  "Foundation/00-Control/Decision-Log.md"
  "Foundation/12-Handover/README.md"
)
errors=0
for file in "${required[@]}"; do
  if [[ ! -f "$root/$file" ]]; then
    printf 'ERROR missing required file: %s\n' "$file" >&2
    errors=1
  fi
done
if [[ -f "$root/FOUNDATION_MANIFEST.yaml" ]] && ! grep -q '^  implementation_gate: ' "$root/FOUNDATION_MANIFEST.yaml"; then
  printf 'ERROR manifest is missing implementation_gate.\n' >&2
  errors=1
fi
if [[ -d "$root/Project-Implementasi" ]]; then
  unexpected="$(find "$root/Project-Implementasi" -type f ! -name README.md ! -name .gitkeep -print -quit)"
  if [[ -n "$unexpected" ]]; then
    printf 'WARNING implementation-area contains file before activation: %s\n' "$unexpected"
  fi
fi
if [[ "$errors" -ne 0 ]]; then exit 1; fi
printf 'Foundation validation passed: %s\n' "$root"
