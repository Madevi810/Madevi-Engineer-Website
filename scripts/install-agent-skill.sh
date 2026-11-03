#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$root/integrations/agent-skills/mew-website-engineer"
action="install"
if [[ "${1:-}" == "install" || "${1:-}" == "update" ]]; then action="$1"; shift; fi
project=""
dry_run=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) [[ $# -ge 2 ]] || { printf 'Missing project directory.\n' >&2; exit 1; }; project="$2"; shift 2 ;;
    --dry-run) dry_run=true; shift ;;
    *) printf 'Usage: mew skill [install|update] --project DIRECTORY [--dry-run]\n' >&2; exit 1 ;;
  esac
done
[[ -n "$project" && -d "$project" ]] || { printf 'Choose an existing project directory with --project.\n' >&2; exit 1; }
[[ -f "$source_dir/SKILL.md" ]] || { printf 'MEW skill package is missing.\n' >&2; exit 1; }
project="$(cd "$project" && pwd -P)"
for path in "$project/.agents" "$project/.agents/skills" "$project/.agents/skills/mew-website-engineer"; do
  [[ ! -L "$path" ]] || { printf 'Refusing symbolic-link target: %s\n' "$path" >&2; exit 1; }
done
target="$project/.agents/skills/mew-website-engineer"
if [[ "$action" == install ]]; then
  [[ ! -e "$target" ]] || { printf 'Skill already exists; use the explicit update command after review: %s\n' "$target" >&2; exit 1; }
else
  [[ -d "$target" ]] || { printf 'Existing MEW skill not found: %s\n' "$target" >&2; exit 1; }
  [[ ! -L "$project/.agents/mew-backups" ]] || { printf 'Refusing symbolic-link backup directory.\n' >&2; exit 1; }
fi
if [[ "$dry_run" == true ]]; then
  printf 'DRY RUN: would %s MEW skill at %s' "$action" "$target"
  [[ "$action" == install ]] || printf ' and preserve the previous copy in .agents/mew-backups'
  printf '\n'
  exit 0
fi
if [[ "$action" == update ]]; then
  stage="$(mktemp -d "$project/.agents/.mew-skill-stage.XXXXXX")"
  cp -R "$source_dir/." "$stage/" || { printf 'Update preparation failed; inspect %s.\n' "$stage" >&2; exit 1; }
  mkdir -p "$project/.agents/mew-backups"
  backup="$(mktemp -d "$project/.agents/mew-backups/mew-website-engineer.XXXXXX")"
  mv "$target" "$backup/previous" || { printf 'Could not preserve the previous skill.\n' >&2; exit 1; }
  if ! mv "$stage" "$target"; then
    if [[ ! -e "$target" && ! -L "$target" ]]; then
      mv "$backup/previous" "$target" || printf 'Restore the previous skill from %s\n' "$backup/previous" >&2
    fi
    printf 'Update failed; previous skill retained at %s if not restored.\n' "$backup/previous" >&2
    exit 1
  fi
  printf 'MEW skill updated: %s\nPrevious copy: %s\n' "$target" "$backup/previous"
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
