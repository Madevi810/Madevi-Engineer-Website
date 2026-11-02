#!/usr/bin/env bash
set -euo pipefail

# Legacy compatibility entrypoint. New tool calls use `mew-tool.sh`.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$script_dir/mew-tool.sh" "$@"
