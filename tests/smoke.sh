#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash -n "$root/scripts/install.sh"
bash -n "$root/scripts/uwf"
bash -n "$root/scripts/create-project.sh"
bash -n "$root/scripts/validate-foundation.sh"
"$root/scripts/validate-foundation.sh" "$root"
printf 'Smoke tests passed.\n'
