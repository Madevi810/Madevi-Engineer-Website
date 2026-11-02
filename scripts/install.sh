#!/usr/bin/env bash
set -euo pipefail

# UWF_* variables remain accepted only to migrate a prior installation safely.
MEW_REPO_URL="${MEW_REPO_URL:-${UWF_REPO_URL:-https://github.com/Madevi810/Madevi-Engineer-Website.git}}"
MEW_INSTALL_DIR="${MEW_INSTALL_DIR:-${UWF_INSTALL_DIR:-$HOME/.local/share/mew}}"
MEW_BIN_DIR="${MEW_BIN_DIR:-${UWF_BIN_DIR:-$HOME/.local/bin}}"
MEW_CONFIG_DIR="${MEW_CONFIG_DIR:-${UWF_CONFIG_DIR:-$HOME/.config/mew}}"
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
  git ls-remote --tags --refs "$MEW_REPO_URL" \
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
  git ls-remote --tags --refs "$MEW_REPO_URL" "refs/tags/v$target" | grep -q . || {
    printf 'Stable tag v%s was not found.\n' "$target" >&2
    exit 1
  }
  target="v$target"
else
  stable="$(latest_tag)"
  [[ -n "$stable" ]] || {
    printf 'No stable MEW release tag exists yet. Refusing to install moving main.\n' >&2
    printf 'Use --edge only for testing, or install after a stable release is published.\n' >&2
    exit 1
  }
  target="v$stable"
fi

parent="$(dirname "$MEW_INSTALL_DIR")"
mkdir -p "$parent"
temporary="$(mktemp -d "$parent/.mew-install.XXXXXX")"
cleanup() { rm -rf "$temporary"; }
trap cleanup EXIT

git clone --depth 1 --branch "$target" "$MEW_REPO_URL" "$temporary/source"
"$temporary/source/scripts/check-repository.sh"
[[ -x "$temporary/source/scripts/mew" ]] || {
  printf 'Stable tag %s predates the MEW command migration and cannot satisfy a `mew` install.\n' "$target" >&2
  printf 'Use --edge to test MEW v2 before its stable release is published.\n' >&2
  exit 1
}

mkdir -p "$MEW_BIN_DIR" "$MEW_CONFIG_DIR" "$parent"
if [[ -e "$MEW_INSTALL_DIR" ]]; then
  backup="$MEW_INSTALL_DIR.backup.$(date -u +%Y%m%dT%H%M%SZ)"
  mv "$MEW_INSTALL_DIR" "$backup"
  printf 'Previous CLI installation backed up at %s\n' "$backup"
fi
mv "$temporary/source" "$MEW_INSTALL_DIR"
ln -sfn "$MEW_INSTALL_DIR/scripts/mew" "$MEW_BIN_DIR/mew"
ln -sfn "$MEW_INSTALL_DIR/scripts/uwf" "$MEW_BIN_DIR/uwf"

cat >"$MEW_CONFIG_DIR/install.env" <<EOF
MEW_CHANNEL=$channel
MEW_VERSION=$target
MEW_REPO_URL=$MEW_REPO_URL
EOF

printf 'MEW %s installed on channel %s.\n' "$target" "$channel"
printf 'Ensure %s is in PATH, then run: mew\n' "$MEW_BIN_DIR"
printf 'The former `uwf` command remains available as a compatibility alias.\n'
