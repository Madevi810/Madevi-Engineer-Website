#!/usr/bin/env bash
set -euo pipefail

UWF_REPO_URL="${UWF_REPO_URL:-https://github.com/Madevi810/universal-web-foundation.git}"
UWF_INSTALL_DIR="${UWF_INSTALL_DIR:-$HOME/.local/share/uwf}"
UWF_BIN_DIR="${UWF_BIN_DIR:-$HOME/.local/bin}"

for command in bash curl git; do
  command -v "$command" >/dev/null 2>&1 || { printf 'Missing required command: %s\n' "$command" >&2; exit 1; }
done

mkdir -p "$UWF_BIN_DIR" "$(dirname "$UWF_INSTALL_DIR")"
if [[ -e "$UWF_INSTALL_DIR/.git" ]]; then
  git -C "$UWF_INSTALL_DIR" pull --ff-only
elif [[ -e "$UWF_INSTALL_DIR" ]]; then
  printf 'Install directory exists but is not a Git checkout: %s\n' "$UWF_INSTALL_DIR" >&2
  exit 1
else
  git clone --depth 1 "$UWF_REPO_URL" "$UWF_INSTALL_DIR"
fi

ln -sfn "$UWF_INSTALL_DIR/scripts/uwf" "$UWF_BIN_DIR/uwf"
printf 'UWF installed. Ensure %s is in PATH, then run: uwf\n' "$UWF_BIN_DIR"
