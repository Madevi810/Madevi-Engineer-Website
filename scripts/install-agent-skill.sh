#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$root/integrations/agent-skills/mew-website-engineer"
project=""
dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) [[ $# -ge 2 ]] || { printf 'Missing project directory.\n' >&2; exit 1; }; project="$2"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    *) printf 'Usage: mew skill install --project DIRECTORY [--dry-run]\n' >&2; exit 1 ;;
  esac
done
[[ -n "$project" && -d "$project" ]] || { printf 'Choose an existing project directory with --project.\n' >&2; exit 1; }
[[ -f "$source_dir/SKILL.md" ]] || { printf 'MEW skill package is missing.\n' >&2; exit 1; }
project="$(cd "$project" && pwd -P)"
for path in "$project/.agents" "$project/.agents/skills" "$project/.agents/skills/mew-website-engineer"; do
  [[ ! -L "$path" ]] || { printf 'Refusing symbolic-link target: %s\n' "$path" >&2; exit 1; }
done
target="$project/.agents/skills/mew-website-engineer"
[[ ! -e "$target" ]] || { printf 'Skill already exists; review it before updating: %s\n' "$target" >&2; exit 1; }
if [[ "$dry_run" == true ]]; then
  printf 'DRY RUN: would install MEW skill to %s\n' "$target"
  exit 0
fi
mkdir -p "$project/.agents/skills"
mkdir "$target" || { printf 'Could not create skill directory.\n' >&2; exit 1; }
if ! cp -R "$source_dir/." "$target/"; then
  printf 'Installation incomplete; inspect %s before retrying.\n' "$target" >&2
  exit 1
fi
printf 'MEW skill installed: %s\n' "$target"
printf 'Open the project in a compatible harness. Hermes project discovery may require an explicitly trusted Git repository.\n'
