#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bash "$root/tests/smoke.sh"
bash "$root/tests/regression-safety.sh"
python3 "$root/tests/test_agent_skill.py"
python3 "$root/tests/test_project_inspector.py"
python3 "$root/tests/test_system_observation.py"
python3 "$root/tests/test_update_integrity.py"
bash "$root/tools/validators/validate-tool-contracts.sh"
printf 'MEW regression evaluation passed.\n'
