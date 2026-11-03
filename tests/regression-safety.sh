#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
trial="$(mktemp -d)"
cd "$trial"
"$root/scripts/mew" init "Regression Safety" >/dev/null
cd regression-safety
cli="$root/scripts/mew"

sed -i 's/mode: unset # prototype_local/mode: prototype_local # prototype_local/' FOUNDATION_MANIFEST.yaml
"$cli" automation kill >/dev/null
grep -q '^  mode: prototype_local ' FOUNDATION_MANIFEST.yaml
grep -q '^  mode: autonomous_foundation_composition ' FOUNDATION_MANIFEST.yaml
grep -q '^  mode: plan_only ' FOUNDATION_MANIFEST.yaml

sed -i 's/experience_level: unset/experience_level: beginner/; s/guidance_mode: unset/guidance_mode: full_agent_recommendation/; s/primary: \[\]/primary: [portal]/; s/profile_status: DRAFT/profile_status: DECLARED/; s/^  status: DRAFT # DRAFT | ROUTED/  status: ROUTED # DRAFT | ROUTED/; s/^  status: DRAFT # DRAFT | REVIEW | READY | APPROVED/  status: READY # DRAFT | REVIEW | READY | APPROVED/; 0,/status: DRAFT/s//status: READY/' FOUNDATION_MANIFEST.yaml

if "$cli" approve implementation --project "Regression Safety" >/dev/null 2>&1; then
  printf 'Empty composition unexpectedly passed the implementation gate.\n' >&2; exit 1
fi
grep -q '^  implementation_gate: BLOCKED' FOUNDATION_MANIFEST.yaml

composition=Foundation/15-Engineering-Materials/Composition-Manifest.md
sed -i 's/^Status: DRAFT/Status: READY/; s/^- Primary objective:$/- Primary objective: Portal/; s/^- Target users:$/- Target users: Readers/; s/^- Project mode:$/- Project mode: local prototype/; s/^- Scope boundary:$/- Scope boundary: pilot/; s/^| | | | | | pending |$/| Static site | suitable pilot | local browser | minimal | reviewed | selected |/' "$composition"

sed -i 's/active_reference: unset/active_reference: custom/' FOUNDATION_MANIFEST.yaml
if "$cli" approve implementation --project "Regression Safety" >/dev/null 2>&1; then
  printf 'Unanalyzed reference unexpectedly passed the implementation gate.\n' >&2; exit 1
fi
sed -i 's/active_reference: custom/active_reference: unset/' FOUNDATION_MANIFEST.yaml

sed -i 's/mode: prototype_local /mode: invalid_mode /' FOUNDATION_MANIFEST.yaml
if "$cli" approve implementation --project "Regression Safety" >/dev/null 2>&1; then
  printf 'Invalid project mode unexpectedly passed the implementation gate.\n' >&2; exit 1
fi
sed -i 's/mode: invalid_mode /mode: prototype_local /' FOUNDATION_MANIFEST.yaml

mkdir Project-regression-safety
if "$cli" approve implementation --project "Regression Safety" >/dev/null 2>&1; then
  printf 'Existing target unexpectedly passed the implementation gate.\n' >&2; exit 1
fi
grep -q '^  implementation_gate: BLOCKED' FOUNDATION_MANIFEST.yaml
rmdir Project-regression-safety

# Simulate a late template failure after the implementation directory is moved.
mkdir -p "$trial/broken-install/templates/implementation"
cp -R "$root/scripts" "$trial/broken-install/scripts"
if "$trial/broken-install/scripts/mew" approve implementation --project "Regression Safety" >/dev/null 2>&1; then
  printf 'Missing implementation template unexpectedly succeeded.\n' >&2; exit 1
fi
grep -q '^  implementation_gate: BLOCKED' FOUNDATION_MANIFEST.yaml
test -d Project-Implementasi
test ! -e Project-regression-safety

"$cli" approve implementation --project "Regression Safety" >/dev/null
grep -q '^  implementation_gate: APPROVED' FOUNDATION_MANIFEST.yaml
test -f Project-regression-safety/docs/IMPLEMENTATION-HISTORY.md

mkdir -p Foundation/.private-test
printf 'snapshot marker\n' > Foundation/.private-test/marker
"$cli" upgrade online --prepare >/dev/null
grep -q '^  mode: prototype_local ' FOUNDATION_MANIFEST.yaml
grep -q '^  implementation_gate: BLOCKED' FOUNDATION_MANIFEST.yaml
grep -q '^  implementation_status: DEFERRED' FOUNDATION_MANIFEST.yaml
grep -q '^  status: DRAFT' FOUNDATION_MANIFEST.yaml
snapshot="$(find Foundation/Archive -mindepth 1 -maxdepth 1 -type d -name 'online-upgrade-*' -print -quit)"
test -f "$snapshot/FOUNDATION_MANIFEST.before-online.yaml"
test -f "$snapshot/Foundation/15-Engineering-Materials/Composition-Manifest.md"
grep -q '^  implementation_gate: APPROVED' "$snapshot/FOUNDATION_MANIFEST.before-online.yaml"
grep -q 'Primary objective: Portal' "$snapshot/Foundation/15-Engineering-Materials/Composition-Manifest.md"
test -f "$snapshot/Foundation/.private-test/marker"
grep -q '^Status: DRAFT$' "$composition"
test ! -e "$snapshot/Foundation/Archive"

"$cli" tool run workspace-inspector --dry-run | grep -q 'no inspection performed'
"$cli" tool run workspace-inspector --dry-run >/dev/null
[[ "$(find Foundation/00-Control/Jobs -maxdepth 1 -name '*workspace-inspector*.md' | wc -l)" -eq 2 ]]
if "$cli" tool run web-search --dry-run >/dev/null 2>&1; then
  printf 'External search unexpectedly ran without an adapter.\n' >&2; exit 1
fi
printf 'Safety regression tests passed.\n'
