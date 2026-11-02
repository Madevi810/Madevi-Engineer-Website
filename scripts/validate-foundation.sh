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
  "Foundation/15-Engineering-Materials/Composition-Manifest.md"
  "Foundation/16-External-Reference-Evidence/Source-Policy.md"
  "Foundation/16-External-Reference-Evidence/Evidence-Registry.md"
  "Foundation/17-Research-Content-Operations/README.md"
  "Foundation/17-Research-Content-Operations/Research-Policy.md"
  "Foundation/17-Research-Content-Operations/Taxonomy-Content-Map.md"
  "Foundation/17-Research-Content-Operations/Scale-Batch-Plan.md"
  "Foundation/17-Research-Content-Operations/Publish-Controls.md"
  "Foundation/17-Research-Content-Operations/Freshness-Capacity-Plan.md"
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

section_value_missing_safe() {
  local section="$1" key="$2" source="$3"
  awk -v section="$section" -v key="$key" '
    $0 == section ":" { active=1; next }
    active && /^[^[:space:]]/ { exit }
    active && $0 ~ "^  " key ":" {
      sub("^  " key ":[[:space:]]*", "")
      sub("[[:space:]]*#.*$", "")
      print
      exit
    }
  ' "$source"
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
runtime_status="$(section_value_missing_safe agent_runtime profile_status "$manifest")"
composition_status="$(section_value_missing_safe composition status "$manifest")"
evidence_status="$(section_value_missing_safe external_evidence status "$manifest")"
source_policy_status="$(section_value_missing_safe external_evidence source_policy_status "$manifest")"
content_enabled="$(section_value_missing_safe content_operations enabled "$manifest")"
content_status="$(section_value_missing_safe content_operations status "$manifest")"
content_mode="$(section_value_missing_safe content_operations mode "$manifest")"
taxonomy_status="$(section_value_missing_safe content_operations taxonomy_status "$manifest")"
research_policy_status="$(section_value_missing_safe content_operations research_policy_status "$manifest")"
publishing_status="$(section_value_missing_safe content_operations publishing_status "$manifest")"
operations_root="$(section_value_missing_safe content_operations operations_root "$manifest")"

[[ -n "$gate" ]] || error "manifest is missing implementation_gate"
[[ "$project_mode" != "unset" ]] || warning "project mode is not selected"
[[ "$experience" != "unset" ]] || warning "developer experience level is not selected"
[[ "$guidance" != "unset" ]] || warning "guidance mode is not selected"
[[ "$primary" != "[]" && -n "$primary" ]] || warning "primary objective is not recorded"
[[ "$runtime_status" != "unknown" && -n "$runtime_status" ]] || warning "agent runtime capability profile is not declared"
[[ "$composition_status" != "DRAFT" && -n "$composition_status" ]] || warning "engineering Composition Manifest is not under review"

if [[ "$evidence_status" != "OPTIONAL" && "$source_policy_status" == "DRAFT" ]]; then
  warning "external evidence is planned but Source Policy is still DRAFT"
fi

if [[ "$content_enabled" == "true" ]]; then
  [[ -n "$operations_root" && "$operations_root" != "unset" && -d "$root/$operations_root" ]] || error "content operations is enabled but Operations workspace is missing"
  [[ "$taxonomy_status" == "READY" || "$taxonomy_status" == "APPROVED" ]] || warning "content operations is enabled but taxonomy is not READY"
  [[ "$research_policy_status" == "READY" || "$research_policy_status" == "APPROVED" ]] || warning "content operations is enabled but research policy is not READY"
  if [[ "$content_mode" == "controlled_autonomous" || "$publishing_status" == "APPROVED_LIMITED" ]]; then
    [[ -f "$root/Foundation/11-Autonomous-Operations/AUTONOMY_POLICY.md" ]] || error "autonomous or publish-enabled content operations requires AUTONOMY_POLICY.md"
    [[ -f "$root/$operations_root/Run-History.md" ]] || error "autonomous or publish-enabled content operations requires Run-History.md"
  fi
fi

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

automation_enabled="$(section_value_missing_safe automation enabled "$manifest")"
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
  [[ "$runtime_status" == "DECLARED" || "$runtime_status" == "VERIFIED" || "$runtime_status" == "LIMITED" ]] || error "implementation gate requires an agent runtime capability profile"
  [[ "$composition_status" == "READY" || "$composition_status" == "APPROVED" ]] || error "implementation gate requires Composition Manifest status READY or APPROVED"
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
