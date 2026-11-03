#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
repo="${MEW_REPO_URL:-https://github.com/Madevi810/Madevi-Engineer-Website.git}"
mode="patch"
check_only=false

usage() {
  cat <<'EOF'
Usage: update.sh [--check] [--minor] [--major] [--edge]

Default update installs the newest stable patch in the current major/minor line.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check) check_only=true; shift ;;
    --minor) mode="minor"; shift ;;
    --major) mode="major"; shift ;;
    --edge) mode="edge"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done

[[ -d "$root/.git" ]] || {
  printf 'Update requires a Git-based MEW installation. Re-run install.sh for copied workspaces.\n' >&2
  exit 1
}

current="$(tr -d '\n' < "$root/VERSION")"
IFS='.' read -r current_major current_minor current_patch <<<"$current"

latest_tag() {
  git ls-remote --tags --refs "$repo" \
    | awk -F/ '{print $3}' \
    | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' \
    | sed 's/^v//' \
    | sort -V \
    | tail -n 1
}

latest_matching() {
  local pattern="$1"
  git ls-remote --tags --refs "$repo" \
    | awk -F/ '{print $3}' \
    | sed 's/^v//' \
    | grep -E "$pattern" \
    | sort -V \
    | tail -n 1
}

target=""
case "$mode" in
  patch) target="$(latest_matching "^$current_major\\.$current_minor\\.[0-9]+$")" ;;
  minor) target="$(latest_matching "^$current_major\\.[0-9]+\\.[0-9]+$")" ;;
  major) target="$(latest_tag)" ;;
  edge) target="main" ;;
esac

[[ -n "$target" ]] || {
  printf 'No compatible stable update tag is available for MEW %s.\n' "$current"
  exit 0
}

if [[ "$target" != "main" ]]; then
  highest="$(printf '%s\n%s\n' "$current" "$target" | sort -V | tail -n 1)"
  if [[ "$highest" == "$current" ]]; then
    printf 'MEW %s is already current or newer than the selected stable channel (%s).\n' "$current" "$target"
    exit 0
  fi
fi

printf 'Current: %s\nTarget:  %s\nMode:    %s\n' "$current" "$target" "$mode"
if [[ "$check_only" == true ]]; then
  exit 0
fi

git -C "$root" diff --quiet || {
  printf 'Refusing update because the MEW installation has local modifications.\n' >&2
  exit 1
}

if [[ "$target" == "main" ]]; then
  git -C "$root" fetch --depth 1 origin main
  git -C "$root" checkout --detach -q FETCH_HEAD
else
  git -C "$root" fetch --depth 1 origin "refs/tags/v$target:refs/tags/v$target"
  git -C "$root" checkout --detach -q "v$target"
fi

"$root/scripts/check-repository.sh"
printf 'MEW update completed.\n'
