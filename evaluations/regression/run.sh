#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bash "$root/tests/smoke.sh"
bash "$root/tools/validators/validate-tool-contracts.sh"
printf 'UWF regression evaluation passed.\n'
