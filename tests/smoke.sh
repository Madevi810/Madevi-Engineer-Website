#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$root/scripts/install.sh"
bash -n "$root/scripts/mew"
bash -n "$root/scripts/doctor.sh"
bash -n "$root/scripts/stack-advisor.sh"
bash -n "$root/scripts/upgrade-online.sh"
bash -n "$root/scripts/plugin-manager.sh"
bash -n "$root/scripts/automation-policy.sh"
bash -n "$root/scripts/check-repository.sh"
bash -n "$root/scripts/manifest-migrate.sh"
bash -n "$root/scripts/package-release.sh"
bash -n "$root/scripts/uninstall.sh"
bash -n "$root/scripts/update.sh"
bash -n "$root/scripts/create-project.sh"
bash -n "$root/scripts/validate-foundation.sh"
bash -n "$root/tools/runners/mew-tool.sh"
bash -n "$root/tools/safety/action-gate.sh"
bash -n "$root/tools/validators/validate-tool-contracts.sh"
bash -n "$root/evaluations/regression/run.sh"
"$root/scripts/validate-foundation.sh" "$root"
"$root/scripts/mew" version
"$root/scripts/mew" stack list
"$root/scripts/check-repository.sh"
"$root/tools/validators/validate-tool-contracts.sh"
"$root/scripts/manifest-migrate.sh" "$root"
test -f "$root/docs/images/mew-linux-cli-preview.svg"
test -f "$root/docs/images/mew-ide-preview.svg"
grep -Fq 'docs/images/mew-linux-cli-preview.svg' "$root/README.md"
grep -Fq 'docs/images/mew-ide-preview.svg' "$root/README.md"

trial="$(mktemp -d)"
(
  cd "$trial"
  "$root/scripts/mew" init "Smoke Web" >/dev/null
  cd smoke-web
  "$root/scripts/mew" context --json | grep -Fq 'mew-agent-context/v1'
  "$root/scripts/mew" status --json | grep -Fq 'mew-status/v1'
  "$root/scripts/mew" next --json | grep -Fq 'mew-next/v1'
  "$root/scripts/mew" validate --json | grep -Fq 'mew-validation/v1'
  "$root/scripts/mew" agent status | grep -Fq 'question_budget: 3'
  "$root/scripts/mew" agent route | grep -Fq 'foundation-orchestrator'
  grep -Eq '^  status: ROUTED( |$)' FOUNDATION_MANIFEST.yaml
  "$root/scripts/mew" tool list | grep -Fq 'workspace-inspector'
  "$root/scripts/mew" tool doctor | grep -Fq 'Tool contracts validated.'
  "$root/scripts/mew" tool capability | grep -Fq 'orchestration_mode:'
  "$root/scripts/mew" tool run workspace-inspector --dry-run | grep -Fq 'DRY_RUN_READY'
  tool_job="$($root/scripts/mew job list | tail -n 1)"
  "$root/scripts/mew" job inspect "$tool_job" | grep -Fq 'Tool: workspace-inspector'
  "$root/scripts/mew" job cancel "$tool_job" | grep -Fq 'CANCELLED'
  if "$root/scripts/mew" tool run github-research --dry-run >/dev/null 2>&1; then
    printf 'Expected external tool without adapter/scope to be blocked.\n' >&2
    exit 1
  fi
  "$root/scripts/mew" evaluation list | grep -Fq 'beginner-content-portal'
  "$root/scripts/mew" evaluation inspect large-content-scale | grep -Fq '10,000'
  "$root/scripts/mew" runtime prepare >/dev/null
  test -f Foundation/00-Control/Agent-Runtime-Profile.md
  "$root/scripts/mew" material list | grep -Fq 'Material Catalog Model'
  "$root/scripts/mew" material assess >/dev/null
  "$root/scripts/mew" compose plan >/dev/null
  "$root/scripts/mew" evidence add "Official astronomy source" >/dev/null
  "$root/scripts/mew" evidence list | grep -Fq 'official-astronomy-source.md'
  "$root/scripts/mew" research prepare >/dev/null
  "$root/scripts/mew" taxonomy plan >/dev/null
  if "$root/scripts/mew" operations prepare >/dev/null 2>&1; then
    printf 'Expected content operations to require approved implementation.\n' >&2
    exit 1
  fi
  "$root/scripts/mew" change new "Remembered bookmark feature" >/dev/null
  "$root/scripts/mew" change list | grep -Fq 'CR-'
  "$root/scripts/mew" feature-gap audit >/dev/null
  find Foundation/05-Features-Requirements -name 'Feature-Gap-Audit-*.md' -print -quit | grep -q .
  "$root/scripts/mew" ui brief >/dev/null
  "$root/scripts/mew" ui review >/dev/null
  "$root/scripts/mew" template list | grep -Fq 'content-platform'
  "$root/scripts/mew" template apply dashboard >/dev/null
  test -f Foundation/04-Product-Modules/Starter-Pack-dashboard.md
  "$root/scripts/mew" reference >/dev/null
  "$root/scripts/mew" reference figcraft | grep -Fq 'Reference-Analysis-FigCraft.md'
  test -f Foundation/06-UX-UI/Design-Reference-Registry.md
  test -f Foundation/06-UX-UI/FigCraft-Reference-Catalog.md
  test -f Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  "$root/scripts/mew" status --json | grep -Fq 'figcraft_public_repository'
  "$root/scripts/mew" validate --json | grep -Fq 'NEED_INFO'
  sed -i 's~^- Source URL or name:.*~- Source URL or name: https://github.com/storytold/figcraft~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- Reference catalog category (if registered):.*~- Reference catalog category (if registered): responsive layout~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- General principle worth considering:.*~- General principle worth considering: test responsive hierarchy before implementation~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- New, original name and structure:.*~- New, original name and structure: MEW responsive review~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- Developer decision:.*~- Developer decision: use as inspiration~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  "$root/scripts/mew" reference complete figcraft >/dev/null
  "$root/scripts/mew" status --json | grep -Fq '"reference_status":"ANALYZED"'
  "$root/scripts/mew" capability | grep -Fq 'Capability Matrix'
  "$root/scripts/mew" release check >/dev/null
  test -f Foundation/12-Handover/Release-Readiness.md
  "$root/scripts/mew" plugin inspect git | grep -Fq 'risk_level: medium'
  if "$root/scripts/mew" approve implementation --project "Smoke Web" >/dev/null 2>&1; then
    printf 'Expected incomplete Foundation gate to block implementation.\n' >&2
    exit 1
  fi
  sed -i 's/mode: unset # prototype_local | prototype_online | beta | production_online/mode: prototype_local # prototype_local | prototype_online | beta | production_online/' FOUNDATION_MANIFEST.yaml
  sed -i 's/experience_level: unset # beginner | intermediate | professional/experience_level: beginner # beginner | intermediate | professional/' FOUNDATION_MANIFEST.yaml
  sed -i 's/guidance_mode: unset # full_agent_recommendation | recommendation_with_custom_choice/guidance_mode: full_agent_recommendation # full_agent_recommendation | recommendation_with_custom_choice/' FOUNDATION_MANIFEST.yaml
  sed -i 's/primary: \[\]/primary: [smoke objective]/' FOUNDATION_MANIFEST.yaml
  sed -i 's/status: DRAFT/status: READY/' FOUNDATION_MANIFEST.yaml
  sed -i 's/profile_status: DECLARED/profile_status: VERIFIED/' FOUNDATION_MANIFEST.yaml
  sed -i 's/orchestration_status: DRAFT/orchestration_status: ROUTED/' FOUNDATION_MANIFEST.yaml
  sed -i 's/^  status: DRAFT # DRAFT | ROUTED | NEED_INFO | READY | APPROVED/  status: ROUTED # DRAFT | ROUTED | NEED_INFO | READY | APPROVED/' FOUNDATION_MANIFEST.yaml
  sed -i 's/^  status: REVIEW # DRAFT | REVIEW | READY | APPROVED/  status: READY # DRAFT | REVIEW | READY | APPROVED/' FOUNDATION_MANIFEST.yaml
  sed -i 's/reference_status: ANALYSIS_REQUIRED/reference_status: ANALYZED/' FOUNDATION_MANIFEST.yaml
  sed -i 's/^Status: DRAFT/Status: READY/; s/^- Primary objective:$/- Primary objective: Smoke objective/; s/^- Target users:$/- Target users: Test users/; s/^- Project mode:$/- Project mode: local prototype/; s/^- Scope boundary:$/- Scope boundary: smoke test/; s/^| | | | | | pending |$/| Static site | simple test | local | minimal | reviewed | selected |/' Foundation/15-Engineering-Materials/Composition-Manifest.md
  "$root/scripts/mew" approve implementation --project "Smoke Web" >/dev/null
  test -f Project-smoke-web/CHANGELOG.md
  test -f Project-smoke-web/docs/IMPLEMENTATION-HISTORY.md
  test -f Project-smoke-web/docs/DECISIONS.md
  test -f Project-smoke-web/docs/TRACEABILITY.md
  "$root/scripts/mew" operations prepare >/dev/null
  test -f Project-smoke-web/Operations/Content-Map.md
  test -f Project-smoke-web/Operations/Production-Queue.md
  test -f Project-smoke-web/Operations/Rights-Ledger.md
  test -f Project-smoke-web/Operations/Run-History.md
  test -f Project-smoke-web/Operations/Freshness-Capacity-Plan.md
  "$root/scripts/mew" content plan --count 200 >/dev/null
  operations_status="$("$root/scripts/mew" operations status)"
  grep -Fq 'scale_target: 200' <<<"$operations_status"
  "$root/scripts/mew" operations validate >/dev/null
  sed -i 's/mode: plan_only # plan_only | draft_assisted | implementation_assisted | controlled_autonomous/mode: controlled_autonomous # plan_only | draft_assisted | implementation_assisted | controlled_autonomous/' FOUNDATION_MANIFEST.yaml
  if "$root/scripts/mew" operations validate >/dev/null 2>&1; then
    printf 'Expected autonomous content operations without policy to be blocked.\n' >&2
    exit 1
  fi
)

template_trial="$(mktemp -d)"
(
  cd "$template_trial"
  "$root/scripts/mew" init "Template Web" --template content-platform >/dev/null
  test -f template-web/Foundation/04-Product-Modules/Starter-Pack-content-platform.md
)

custom_reference_trial="$(mktemp -d)"
(
  cd "$custom_reference_trial"
  "$root/scripts/mew" init "Custom Reference Web" >/dev/null
  cd custom-reference-web
  "$root/scripts/mew" reference custom "Public UI Reference" >/dev/null
  test -f Foundation/06-UX-UI/Reference-Analysis-Custom-public-ui-reference.md
  "$root/scripts/mew" status --json | grep -Fq '"active_reference":"custom"'
)

legacy_trial="$(mktemp -d)"
mkdir -p "$legacy_trial/legacy"
awk '
  /^(agent_runtime|agent_orchestration|composition|external_evidence|content_operations):/ { skip=1; next }
  skip && /^[^[:space:]]/ { skip=0 }
  !skip { print }
' "$root/FOUNDATION_MANIFEST.yaml" >"$legacy_trial/legacy/FOUNDATION_MANIFEST.yaml"
"$root/scripts/manifest-migrate.sh" "$legacy_trial/legacy" >/dev/null
grep -Fq 'agent_runtime:' "$legacy_trial/legacy/FOUNDATION_MANIFEST.yaml"
grep -Fq 'content_operations:' "$legacy_trial/legacy/FOUNDATION_MANIFEST.yaml"
grep -Fq 'agent_orchestration:' "$legacy_trial/legacy/FOUNDATION_MANIFEST.yaml"
test -f "$legacy_trial/legacy/FOUNDATION_MANIFEST.yaml.pre-v1.2.bak"
test -f "$legacy_trial/legacy/FOUNDATION_MANIFEST.yaml.pre-v1.3.bak"

legacy_workspace_trial="$(mktemp -d)"
(
  cd "$legacy_workspace_trial"
  "$root/scripts/mew" init "Legacy Workspace" >/dev/null
  cd legacy-workspace
  mkdir -p ../legacy-stash
  mv Foundation/15-Engineering-Materials Foundation/16-External-Reference-Evidence Foundation/17-Research-Content-Operations ../legacy-stash/
  awk '
    /^(agent_runtime|agent_orchestration|composition|external_evidence|content_operations):/ { skip=1; next }
    skip && /^[^[:space:]]/ { skip=0 }
    !skip { print }
  ' FOUNDATION_MANIFEST.yaml > FOUNDATION_MANIFEST.tmp
  mv FOUNDATION_MANIFEST.tmp FOUNDATION_MANIFEST.yaml
  "$root/scripts/mew" validate --json | grep -Fq 'mew-validation/v1'
  test -f Foundation/15-Engineering-Materials/Composition-Manifest.md
  test -f Foundation/17-Research-Content-Operations/Research-Policy.md
  test -f agent/Orchestrator.md
  test -f tools/contracts/workspace-inspector.yaml
)
printf 'Smoke tests passed.\n'
