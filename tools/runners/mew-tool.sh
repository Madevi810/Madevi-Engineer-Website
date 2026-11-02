#!/usr/bin/env bash
set -euo pipefail

mew_home="${1:-}"
workspace="${2:-}"
shift 2 || true
[[ -d "$mew_home/tools/contracts" && -f "$workspace/FOUNDATION_MANIFEST.yaml" ]] || { printf 'Invalid MEW home or workspace.\n' >&2; exit 1; }

command="${1:-}"
shift || true
contract_for() { printf '%s/tools/contracts/%s.yaml\n' "$mew_home" "$1"; }
section_value() {
  local section="$1" key="$2"
  awk -v section="$section" -v key="$key" '
    $0 == section ":" { active=1; next }
    active && /^[^[:space:]]/ { exit }
    active && $0 ~ "^  " key ":" { sub("^  " key ":[[:space:]]*", ""); sub("[[:space:]]*#.*$", ""); print; exit }
  ' "$workspace/FOUNDATION_MANIFEST.yaml"
}
record_job() {
  local id="$1" result="$2" stamp jobdir job
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  jobdir="$workspace/Foundation/00-Control/Jobs"
  mkdir -p "$jobdir"
  job="$jobdir/JOB-$stamp-$id.md"
  cat >"$job" <<EOF
# Tool Job JOB-$stamp-$id

- Tool: $id
- Mode: dry_run
- Result: $result
- Time: $stamp
- External action: none
- Application write: none
EOF
  printf '| %s | Tool Runtime | %s | dry_run | local workspace | %s | %s | not required |\n' "$stamp" "$id" "$result" "$job" >>"$workspace/Foundation/00-Control/Action-Journal.md"
  printf '%s\n' "$job"
}

case "$command" in
  list)
    find "$mew_home/tools/contracts" -maxdepth 1 -type f -name '*.yaml' -printf '%f\n' | sed 's/\.yaml$//' | sort
    ;;
  inspect)
    id="${1:-}"; contract="$(contract_for "$id")"; [[ -f "$contract" ]] || { printf 'Unknown tool: %s\n' "$id" >&2; exit 1; }; cat "$contract"
    ;;
  doctor)
    missing=0
    for executable in bash awk sed grep find; do
      if command -v "$executable" >/dev/null 2>&1; then
        printf 'OK %s\n' "$executable"
      else
        printf 'MISSING %s\n' "$executable" >&2
        missing=$((missing + 1))
      fi
    done
    "$mew_home/tools/validators/validate-tool-contracts.sh"
    [[ "$missing" -eq 0 ]] || exit 1
    ;;
  capability)
    printf 'web_research: %s\n' "$(section_value agent_runtime web_research)"
    printf 'github_access: %s\n' "$(section_value agent_runtime github_access)"
    printf 'filesystem_write: %s\n' "$(section_value agent_runtime filesystem_write)"
    printf 'publication_access: %s\n' "$(section_value agent_runtime publication_access)"
    printf 'orchestration_mode: %s\n' "$(section_value agent_orchestration mode)"
    ;;
  run)
    id="${1:-}"; flag="${2:-}"; contract="$(contract_for "$id")"
    [[ -f "$contract" && "$flag" == "--dry-run" && $# -eq 2 ]] || { printf 'Use: mew tool run TOOL-ID --dry-run\n' >&2; exit 1; }
    "$mew_home/tools/safety/action-gate.sh" "$contract"
    mode="$(awk -F': ' '$1 == "mode" { print $2; exit }' "$contract")"
    case "$mode" in
      local_read|foundation_write)
        case "$id" in
          capability-detector) result="runtime capabilities reported" ;;
          workspace-inspector) result="workspace structure inspected" ;;
          manifest-engine) result="manifest compatibility dry-run prepared" ;;
          compatibility-engine) result="compatibility review dry-run prepared" ;;
          taxonomy-builder) result="taxonomy planning dry-run prepared" ;;
          content-batch-planner) result="content batch dry-run prepared" ;;
          quality-review) result="quality review dry-run prepared" ;;
          release-evaluator) result="release evaluation dry-run prepared" ;;
          *) result="contract dry-run prepared" ;;
        esac
        job="$(record_job "$id" "$result")"
        printf 'DRY_RUN_READY: %s\nJOB: %s\n' "$result" "$job"
        ;;
      external_read|external_write)
        printf 'NO_EXTERNAL_RUN: contract requires a declared adapter, policy, scope, and approval.\n' >&2
        exit 2
        ;;
    esac
    ;;
  *) printf 'Use: mew-tool [list|inspect ID|doctor|capability|run ID --dry-run]\n' >&2; exit 1 ;;
esac
