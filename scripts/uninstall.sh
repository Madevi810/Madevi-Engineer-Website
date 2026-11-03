#!/usr/bin/env bash
set -euo pipefail

[[ $# -eq 1 && "$1" == "--yes" ]] || {
  printf 'Usage: uninstall.sh --yes\n' >&2
  printf 'This removes only the standard MEW CLI installation, never project workspaces.\n' >&2
  exit 1
}

install_dir="$HOME/.local/share/mew"
bin_dir="$HOME/.local/bin"

rm -f "$bin_dir/mew"
rm -rf "$install_dir"
printf 'MEW CLI removed. Project workspaces were not changed.\n'
