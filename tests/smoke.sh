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
bash -n "$root/scripts/create-project.sh"
bash -n "$root/scripts/validate-foundation.sh"
"$root/scripts/validate-foundation.sh" "$root"
"$root/scripts/uwf" version
"$root/scripts/uwf" stack list
"$root/scripts/check-repository.sh"
printf 'Smoke tests passed.\n'
