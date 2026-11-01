#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"
mode="${2:-standard}"
root="$(cd "$root" && pwd)"
manifest="$root/FOUNDATION_MANIFEST.yaml"
errors=0
warnings=0
critical=0

error() {
  printf 'ERROR: %s\n' "$1" >&2
  errors=$((errors + 1))
}

warning() {
  printf 'WARNING: %s\n' "$1"
  warnings=$((warnings + 1))
}

required=(
  "AGENTS.md"
  "FOUNDATION_MANIFEST.yaml"
  "Foundation/00-Control/Open-Questions.md"
  "Foundation/00-Control/Decision-Log.md"
  "Foundation/00-Control/Risk-Register.md"
  "Foundation/12-Handover/README.md"
)

for file in "${required[@]}"; do
  [[ -f "$root/$file" ]] || error "missing required file: $file"
done

if [[ ! -f "$manifest" ]]; then
  printf 'Validation failed: manifest is missing.\n' >&2
  exit 1
fi

value() {
  local key="$1"
  grep -E "^  $key:" "$manifest" | head -n 1 | sed -E "s/^  $key:[[:space:]]*//" | sed 's/[[:space:]]*#.*$//'
}

project_mode="$(value mode)"
experience="$(value experience_level)"
guidance="$(value guidance_mode)"
gate="$(value implementation_gate)"
foundation_status="$(value status)"
primary="$(grep -E '^  primary:' "$manifest" | head -n 1 | sed -E 's/^  primary:[[:space:]]*//')"

[[ -n "$gate" ]] || error "manifest is missing implementation_gate"
[[ "$project_mode" != "unset" ]] || warning "project mode is not selected"
[[ "$experience" != "unset" ]] || warning "developer experience level is not selected"
[[ "$guidance" != "unset" ]] || warning "guidance mode is not selected"
[[ "$primary" != "[]" && -n "$primary" ]] || warning "primary objective is not recorded"

if grep -Eq '^\|[^|]*\|[[:space:]]*CRITICAL[[:space:]]*\|.*\|[[:space:]]*OPEN[[:space:]]*\|' "$root/Foundation/00-Control/Risk-Register.md"; then
  critical=1
  error "an open CRITICAL risk exists"
fi

if grep -Eq '^\|[^|]*\|.*\|[[:space:]]*OPEN[[:space:]]*\|[^|]*\|[[:space:]]*OPEN[[:space:]]*\|' "$root/Foundation/00-Control/Open-Questions.md"; then
  warning "open Foundation questions remain"
fi

if [[ -d "$root/Project-Implementasi" ]]; then
  unexpected="$(find "$root/Project-Implementasi" -type f ! -name README.md ! -name .gitkeep -print -quit)"
  [[ -z "$unexpected" ]] || warning "implementation area contains a file before activation: $unexpected"
fi

if [[ "$mode" == "--gate" ]]; then
  [[ "$project_mode" != "unset" ]] || error "implementation gate requires a project mode"
  [[ "$experience" != "unset" ]] || error "implementation gate requires a developer level"
  [[ "$guidance" != "unset" ]] || error "implementation gate requires a guidance mode"
  [[ "$primary" != "[]" && -n "$primary" ]] || error "implementation gate requires a primary objective"
  [[ "$foundation_status" == "READY" ]] || error "implementation gate requires foundation.status to be READY"
  [[ "$critical" -eq 0 ]] || error "implementation gate cannot pass with CRITICAL risk"
fi

if [[ "$errors" -gt 0 ]]; then
  printf 'Validation result: BLOCKED (%s error(s), %s warning(s))\n' "$errors" "$warnings" >&2
  exit 1
fi

if [[ "$warnings" -gt 0 ]]; then
  printf 'Validation result: NEED_INFO (0 errors, %s warning(s))\n' "$warnings"
else
  printf 'Validation result: READY\n'
fi
