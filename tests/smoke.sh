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
  if "$root/scripts/uwf" approve implementation --project "Smoke Web" >/dev/null 2>&1; then
    printf 'Expected incomplete Foundation gate to block implementation.\n' >&2
    exit 1
  fi
  sed -i 's/mode: unset # prototype_local | prototype_online | beta | production_online/mode: prototype_local # prototype_local | prototype_online | beta | production_online/' FOUNDATION_MANIFEST.yaml
  sed -i 's/experience_level: unset # beginner | intermediate | professional/experience_level: beginner # beginner | intermediate | professional/' FOUNDATION_MANIFEST.yaml
  sed -i 's/guidance_mode: unset # full_agent_recommendation | recommendation_with_custom_choice/guidance_mode: full_agent_recommendation # full_agent_recommendation | recommendation_with_custom_choice/' FOUNDATION_MANIFEST.yaml
  sed -i 's/primary: \[\]/primary: [smoke objective]/' FOUNDATION_MANIFEST.yaml
  sed -i 's/status: DRAFT/status: READY/' FOUNDATION_MANIFEST.yaml
  "$root/scripts/uwf" approve implementation --project "Smoke Web" >/dev/null
  test -f Project-smoke-web/CHANGELOG.md
  test -f Project-smoke-web/docs/IMPLEMENTATION-HISTORY.md
  test -f Project-smoke-web/docs/DECISIONS.md
  test -f Project-smoke-web/docs/TRACEABILITY.md
)
printf 'Smoke tests passed.\n'
