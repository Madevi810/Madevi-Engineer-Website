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
cat >"$target/IMPLEMENTATION-START.md" <<EOF
# Implementation Start

Project: $project_name

This directory is active only because the developer approved the implementation gate.
Read ../Foundation/12-Handover/ before selecting a stack or writing application code.
EOF
printf 'Implementation workspace created: %s\n' "$target"
