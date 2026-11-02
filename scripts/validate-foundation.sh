#!/usr/bin/env bash
set -euo pipefail

root="${1:-.}"
shift || true
mode="standard"
json=false
for argument in "$@"; do
  case "$argument" in
    --gate) mode="--gate" ;;
    --json) json=true ;;
    *) printf 'Unknown validation option: %s\n' "$argument" >&2; exit 1 ;;
  esac
done
root="$(cd "$root" && pwd)"
manifest="$root/FOUNDATION_MANIFEST.yaml"
errors=0
warnings=0
critical=0

error() {
  if [[ "$json" != true ]]; then printf 'ERROR: %s\n' "$1" >&2; fi
  errors=$((errors + 1))
}

warning() {
  if [[ "$json" != true ]]; then printf 'WARNING: %s\n' "$1"; fi
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
active_reference="$(grep -E '^  active_reference:' "$manifest" | head -n 1 | sed -E 's/^  active_reference:[[:space:]]*//' | sed 's/[[:space:]]*#.*$//')"
reference_analysis_file="$(grep -E '^  reference_analysis_file:' "$manifest" | head -n 1 | sed -E 's/^  reference_analysis_file:[[:space:]]*//' | sed 's/[[:space:]]*#.*$//')"
reference_status="$(grep -E '^  reference_status:' "$manifest" | head -n 1 | sed -E 's/^  reference_status:[[:space:]]*//' | sed 's/[[:space:]]*#.*$//')"

[[ -n "$gate" ]] || error "manifest is missing implementation_gate"
[[ "$project_mode" != "unset" ]] || warning "project mode is not selected"
[[ "$experience" != "unset" ]] || warning "developer experience level is not selected"
[[ "$guidance" != "unset" ]] || warning "guidance mode is not selected"
[[ "$primary" != "[]" && -n "$primary" ]] || warning "primary objective is not recorded"

if [[ -n "$active_reference" && "$active_reference" != "unset" ]]; then
  if [[ -z "$reference_analysis_file" || "$reference_analysis_file" == "unset" || ! -f "$root/$reference_analysis_file" ]]; then
    warning "active UI/UX reference has no dedicated analysis file"
  fi
  [[ "$reference_status" != "ANALYSIS_REQUIRED" ]] || warning "active UI/UX reference still requires clean-room analysis"
fi

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

automation_enabled="$(grep -E '^  enabled:' "$manifest" | tail -n 1 | sed -E 's/^  enabled:[[:space:]]*//')"
if [[ "$automation_enabled" == "true" ]]; then
  policy="$root/Foundation/11-Autonomous-Operations/AUTONOMY_POLICY.md"
  if [[ ! -f "$policy" ]]; then
    error "automation is enabled but AUTONOMY_POLICY.md is missing"
  elif ! grep -q '^## Approval' "$policy"; then
    error "automation policy has no approval section"
  else
    warning "automation is enabled; verify budget, runner, quality gate, rollback, and kill switch before execution"
  fi
fi

if [[ "$mode" == "--gate" ]]; then
  [[ "$project_mode" != "unset" ]] || error "implementation gate requires a project mode"
  [[ "$experience" != "unset" ]] || error "implementation gate requires a developer level"
  [[ "$guidance" != "unset" ]] || error "implementation gate requires a guidance mode"
  [[ "$primary" != "[]" && -n "$primary" ]] || error "implementation gate requires a primary objective"
  [[ "$foundation_status" == "READY" ]] || error "implementation gate requires foundation.status to be READY"
  [[ "$reference_status" != "ANALYSIS_REQUIRED" ]] || error "implementation gate requires active UI/UX reference analysis"
  [[ "$critical" -eq 0 ]] || error "implementation gate cannot pass with CRITICAL risk"
fi

result="READY"
if [[ "$errors" -gt 0 ]]; then
  result="BLOCKED"
elif [[ "$warnings" -gt 0 ]]; then
  result="NEED_INFO"
fi

if [[ "$json" == true ]]; then
  printf '{"schema":"uwf-validation/v1","result":"%s","errors":%s,"warnings":%s,"gate_check":%s}\n' \
    "$result" "$errors" "$warnings" "$([[ "$mode" == "--gate" ]] && printf true || printf false)"
elif [[ "$errors" -gt 0 ]]; then
  printf 'Validation result: BLOCKED (%s error(s), %s warning(s))\n' "$errors" "$warnings" >&2
elif [[ "$warnings" -gt 0 ]]; then
  printf 'Validation result: NEED_INFO (0 errors, %s warning(s))\n' "$warnings"
else
  printf 'Validation result: READY\n'
fi

if [[ "$errors" -gt 0 ]]; then
  exit 1
fi
