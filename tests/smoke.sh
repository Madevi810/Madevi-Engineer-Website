#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$root/scripts/install.sh"
bash -n "$root/scripts/uwf"
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
"$root/scripts/validate-foundation.sh" "$root"
"$root/scripts/uwf" version
"$root/scripts/uwf" stack list
"$root/scripts/check-repository.sh"
"$root/scripts/manifest-migrate.sh" "$root"

trial="$(mktemp -d)"
(
  cd "$trial"
  "$root/scripts/uwf" init "Smoke Web" >/dev/null
  cd smoke-web
  "$root/scripts/uwf" context --json | grep -Fq 'uwf-agent-context/v1'
  "$root/scripts/uwf" status --json | grep -Fq 'uwf-status/v1'
  "$root/scripts/uwf" next --json | grep -Fq 'uwf-next/v1'
  "$root/scripts/uwf" validate --json | grep -Fq 'uwf-validation/v1'
  "$root/scripts/uwf" change new "Remembered bookmark feature" >/dev/null
  "$root/scripts/uwf" change list | grep -Fq 'CR-'
  "$root/scripts/uwf" feature-gap audit >/dev/null
  find Foundation/05-Features-Requirements -name 'Feature-Gap-Audit-*.md' -print -quit | grep -q .
  "$root/scripts/uwf" ui brief >/dev/null
  "$root/scripts/uwf" ui review >/dev/null
  "$root/scripts/uwf" template list | grep -Fq 'content-platform'
  "$root/scripts/uwf" template apply dashboard >/dev/null
  test -f Foundation/04-Product-Modules/Starter-Pack-dashboard.md
  "$root/scripts/uwf" reference >/dev/null
  "$root/scripts/uwf" reference figcraft | grep -Fq 'Reference-Analysis-FigCraft.md'
  test -f Foundation/06-UX-UI/Design-Reference-Registry.md
  test -f Foundation/06-UX-UI/FigCraft-Reference-Catalog.md
  test -f Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  "$root/scripts/uwf" status --json | grep -Fq 'figcraft_public_repository'
  "$root/scripts/uwf" validate --json | grep -Fq 'NEED_INFO'
  sed -i 's~^- Source URL or name:.*~- Source URL or name: https://github.com/storytold/figcraft~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- Reference catalog category (if registered):.*~- Reference catalog category (if registered): responsive layout~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- General principle worth considering:.*~- General principle worth considering: test responsive hierarchy before implementation~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- New, original name and structure:.*~- New, original name and structure: UWF responsive review~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  sed -i 's~^- Developer decision:.*~- Developer decision: use as inspiration~' Foundation/06-UX-UI/Reference-Analysis-FigCraft.md
  "$root/scripts/uwf" reference complete figcraft >/dev/null
  "$root/scripts/uwf" status --json | grep -Fq '"reference_status":"ANALYZED"'
  "$root/scripts/uwf" capability | grep -Fq 'Capability Matrix'
  "$root/scripts/uwf" release check >/dev/null
  test -f Foundation/12-Handover/Release-Readiness.md
  "$root/scripts/uwf" plugin inspect git | grep -Fq 'risk_level: medium'
  if "$root/scripts/uwf" approve implementation --project "Smoke Web" >/dev/null 2>&1; then
    printf 'Expected incomplete Foundation gate to block implementation.\n' >&2
    exit 1
  fi
  sed -i 's/mode: unset # prototype_local | prototype_online | beta | production_online/mode: prototype_local # prototype_local | prototype_online | beta | production_online/' FOUNDATION_MANIFEST.yaml
  sed -i 's/experience_level: unset # beginner | intermediate | professional/experience_level: beginner # beginner | intermediate | professional/' FOUNDATION_MANIFEST.yaml
  sed -i 's/guidance_mode: unset # full_agent_recommendation | recommendation_with_custom_choice/guidance_mode: full_agent_recommendation # full_agent_recommendation | recommendation_with_custom_choice/' FOUNDATION_MANIFEST.yaml
  sed -i 's/primary: \[\]/primary: [smoke objective]/' FOUNDATION_MANIFEST.yaml
  sed -i 's/status: DRAFT/status: READY/' FOUNDATION_MANIFEST.yaml
  sed -i 's/reference_status: ANALYSIS_REQUIRED/reference_status: ANALYZED/' FOUNDATION_MANIFEST.yaml
  "$root/scripts/uwf" approve implementation --project "Smoke Web" >/dev/null
  test -f Project-smoke-web/CHANGELOG.md
  test -f Project-smoke-web/docs/IMPLEMENTATION-HISTORY.md
  test -f Project-smoke-web/docs/DECISIONS.md
  test -f Project-smoke-web/docs/TRACEABILITY.md
)

template_trial="$(mktemp -d)"
(
  cd "$template_trial"
  "$root/scripts/uwf" init "Template Web" --template content-platform >/dev/null
  test -f template-web/Foundation/04-Product-Modules/Starter-Pack-content-platform.md
)

custom_reference_trial="$(mktemp -d)"
(
  cd "$custom_reference_trial"
  "$root/scripts/uwf" init "Custom Reference Web" >/dev/null
  cd custom-reference-web
  "$root/scripts/uwf" reference custom "Public UI Reference" >/dev/null
  test -f Foundation/06-UX-UI/Reference-Analysis-Custom-public-ui-reference.md
  "$root/scripts/uwf" status --json | grep -Fq '"active_reference":"custom"'
)
printf 'Smoke tests passed.\n'
