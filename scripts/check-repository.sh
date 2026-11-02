#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
failed=0

need() {
  [[ -f "$root/$1" ]] || { printf 'Missing: %s\n' "$1" >&2; failed=1; }
}

for file in README.md AGENTS.md FOUNDATION_MANIFEST.yaml VERSION LICENSE CHANGELOG.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md; do
  need "$file"
done

for file in \
  Foundation/05-Features-Requirements/Feature-Gap-Audit.md \
  Foundation/06-UX-UI/Creative-Brief.md \
  Foundation/06-UX-UI/Responsive-Accessibility-Review.md \
  Foundation/06-UX-UI/Simulation-Plan.md \
  Foundation/06-UX-UI/Reference-Analysis.md \
  Foundation/06-UX-UI/Design-Reference-Registry.md \
  Foundation/06-UX-UI/FigCraft-Reference-Catalog.md \
  Foundation/00-Control/Capability-Matrix.md \
  Foundation/12-Handover/Release-Readiness.md \
  Foundation/14-Change-Management/README.md \
  Foundation/14-Change-Management/Backlog.md \
  Foundation/14-Change-Management/Revision-History.md \
  templates/change-request.md \
  templates/release-readiness.md \
  templates/starter-packs/content-platform.md \
  templates/starter-packs/marketplace.md \
  templates/starter-packs/dashboard.md \
  templates/starter-packs/hybrid-platform.md \
  templates/implementation/CHANGELOG.md \
  templates/implementation/IMPLEMENTATION-HISTORY.md \
  templates/implementation/DECISIONS.md \
  templates/implementation/TRACEABILITY.md \
  docs/images/uwf-linux-cli-preview.svg \
  docs/images/uwf-ide-preview.svg; do
  need "$file"
done

if ! grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' "$root/VERSION"; then
  printf 'VERSION must use semantic version format.\n' >&2
  failed=1
fi

if grep -RInE '(AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH) PRIVATE KEY|password[[:space:]]*=[[:space:]]*[^[:space:]]+)' "$root" --exclude-dir=.git --exclude=check-repository.sh; then
  printf 'Potential secret pattern found. Remove it before release.\n' >&2
  failed=1
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

printf 'Repository hardening checks passed.\n'
