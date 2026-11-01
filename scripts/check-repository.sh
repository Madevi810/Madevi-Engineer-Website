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
