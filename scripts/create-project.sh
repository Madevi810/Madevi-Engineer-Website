#!/usr/bin/env bash
set -euo pipefail

project_name="${1:-}"
[[ -n "$project_name" ]] || { printf 'Project name is required.\n' >&2; exit 1; }
[[ -f FOUNDATION_MANIFEST.yaml ]] || { printf 'Run from UWF workspace root.\n' >&2; exit 1; }
grep -q '^  implementation_gate: APPROVED' FOUNDATION_MANIFEST.yaml || { printf 'Implementation gate is not APPROVED.\n' >&2; exit 1; }
[[ -d Project-Implementasi ]] || { printf 'Project-Implementasi is missing.\n' >&2; exit 1; }
slug="$(printf '%s' "$project_name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')"
target="Project-$slug"
[[ ! -e "$target" ]] || { printf 'Target already exists: %s\n' "$target" >&2; exit 1; }
mv Project-Implementasi "$target"
mkdir -p "$target"/{docs,tests,infrastructure}
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
template_dir="$(cd "$script_dir/../templates/implementation" && pwd)"
cp "$template_dir/CHANGELOG.md" "$target/CHANGELOG.md"
cp "$template_dir/IMPLEMENTATION-HISTORY.md" "$target/docs/IMPLEMENTATION-HISTORY.md"
cp "$template_dir/DECISIONS.md" "$target/docs/DECISIONS.md"
cp "$template_dir/TRACEABILITY.md" "$target/docs/TRACEABILITY.md"
cat >"$target/IMPLEMENTATION-START.md" <<EOF
# Implementation Start

Project: $project_name

This directory is active only because the developer approved the implementation gate.
Read ../Foundation/12-Handover/ before selecting a stack or writing application code.

Record approved work in docs/IMPLEMENTATION-HISTORY.md, user-visible changes in CHANGELOG.md,
technical choices in docs/DECISIONS.md, and Foundation-to-code links in docs/TRACEABILITY.md.
New or forgotten scope must first be recorded under ../Foundation/14-Change-Management/.
EOF
printf 'Implementation workspace created: %s\n' "$target"
