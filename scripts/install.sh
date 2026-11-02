#!/usr/bin/env bash
set -euo pipefail

UWF_REPO_URL="${UWF_REPO_URL:-https://github.com/Madevi810/Universal-Web-Foundation.git}"
UWF_INSTALL_DIR="${UWF_INSTALL_DIR:-$HOME/.local/share/uwf}"
UWF_BIN_DIR="${UWF_BIN_DIR:-$HOME/.local/bin}"
UWF_CONFIG_DIR="${UWF_CONFIG_DIR:-$HOME/.config/uwf}"
channel="stable"
requested_version=""

usage() {
  cat <<'EOF'
Usage: install.sh [--version vX.Y.Z | --edge]

Default: install the latest stable semantic-version tag.
--version: install one exact stable tag.
--edge: install the moving main branch for testing only.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      [[ $# -ge 2 ]] || { usage >&2; exit 1; }
      requested_version="$2"
      shift 2
      ;;
    --edge)
      channel="edge"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

for command in bash curl git sort mktemp; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  }
done

latest_tag() {
  git ls-remote --tags --refs "$UWF_REPO_URL" \
    | awk -F/ '{print $3}' \
    | grep -E '^v?[0-9]+\.[0-9]+\.[0-9]+$' \
    | sed 's/^v//' \
    | sort -V \
    | tail -n 1
}

target=""
if [[ "$channel" == "edge" ]]; then
  target="main"
elif [[ -n "$requested_version" ]]; then
  target="${requested_version#v}"
  git ls-remote --tags --refs "$UWF_REPO_URL" "refs/tags/v$target" | grep -q . || {
    printf 'Stable tag v%s was not found.\n' "$target" >&2
    exit 1
  }
  target="v$target"
else
  stable="$(latest_tag)"
  [[ -n "$stable" ]] || {
    printf 'No stable UWF release tag exists yet. Refusing to install moving main.\n' >&2
    printf 'Use --edge only for testing, or install after a stable release is published.\n' >&2
    exit 1
  }
  target="v$stable"
fi

parent="$(dirname "$UWF_INSTALL_DIR")"
mkdir -p "$parent"
temporary="$(mktemp -d "$parent/.uwf-install.XXXXXX")"
cleanup() { rm -rf "$temporary"; }
trap cleanup EXIT

git clone --depth 1 --branch "$target" "$UWF_REPO_URL" "$temporary/source"
"$temporary/source/scripts/check-repository.sh"

mkdir -p "$UWF_BIN_DIR" "$UWF_CONFIG_DIR" "$parent"
if [[ -e "$UWF_INSTALL_DIR" ]]; then
  backup="$UWF_INSTALL_DIR.backup.$(date -u +%Y%m%dT%H%M%SZ)"
  mv "$UWF_INSTALL_DIR" "$backup"
  printf 'Previous CLI installation backed up at %s\n' "$backup"
fi
mv "$temporary/source" "$UWF_INSTALL_DIR"
ln -sfn "$UWF_INSTALL_DIR/scripts/uwf" "$UWF_BIN_DIR/uwf"

cat >"$UWF_CONFIG_DIR/install.env" <<EOF
UWF_CHANNEL=$channel
UWF_VERSION=$target
UWF_REPO_URL=$UWF_REPO_URL
EOF

printf 'UWF %s installed on channel %s.\n' "$target" "$channel"
printf 'Ensure %s is in PATH, then run: uwf\n' "$UWF_BIN_DIR"
