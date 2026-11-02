#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
repo="https://github.com/Madevi810/Universal-Web-Foundation.git"
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
  printf 'Update requires a Git-based UWF installation. Re-run install.sh for copied workspaces.\n' >&2
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
  printf 'No compatible stable update tag is available for UWF %s.\n' "$current"
  exit 0
}

if [[ "$target" != "main" && "$target" == "$current" ]]; then
  printf 'UWF %s is already current for the selected update channel.\n' "$current"
  exit 0
fi

printf 'Current: %s\nTarget:  %s\nMode:    %s\n' "$current" "$target" "$mode"
if [[ "$check_only" == true ]]; then
  exit 0
fi

git -C "$root" diff --quiet || {
  printf 'Refusing update because the UWF installation has local modifications.\n' >&2
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
printf 'UWF update completed.\n'
