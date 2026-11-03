#!/usr/bin/env bash
set -euo pipefail

MEW_REPO_URL="${MEW_REPO_URL:-https://github.com/Madevi810/Madevi-Engineer-Website.git}"
MEW_INSTALL_DIR="${MEW_INSTALL_DIR:-$HOME/.local/share/mew}"
MEW_BIN_DIR="${MEW_BIN_DIR:-$HOME/.local/bin}"
MEW_CONFIG_DIR="${MEW_CONFIG_DIR:-$HOME/.config/mew}"
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
  local tags
  tags="$(git ls-remote --tags --refs "$MEW_REPO_URL")" || {
    printf 'Unable to query stable tags; installation was not performed.\n' >&2
    return 1
  }
  printf '%s\n' "$tags" \
    | awk -F/ '{print $3}' \
    | { grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' || true; } \
    | sed 's/^v//' \
    | sort -V \
    | tail -n 1
}

target=""
if [[ "$channel" == "edge" ]]; then
  target="main"
elif [[ -n "$requested_version" ]]; then
  target="${requested_version#v}"
  [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { printf 'Version must be a stable tag like v2.1.0.\n' >&2; exit 1; }
  tag_result="$(git ls-remote --tags --refs "$MEW_REPO_URL" "refs/tags/v$target")" || {
    printf 'Unable to query stable tags; installation was not performed.\n' >&2
    exit 1
  }
  [[ -n "$tag_result" ]] || {
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
cleanup() {
  if [[ -n "${config_temp:-}" ]]; then rm -f -- "$config_temp"; fi
  rm -rf -- "$temporary"
}
trap cleanup EXIT

git clone --depth 1 --branch "$target" "$MEW_REPO_URL" "$temporary/source"
"$temporary/source/scripts/check-repository.sh"
[[ -x "$temporary/source/scripts/mew" ]] || {
  printf 'Stable tag %s predates the MEW command migration and cannot satisfy a `mew` install.\n' "$target" >&2
  printf 'Use --edge to test MEW v2 before its stable release is published.\n' >&2
  exit 1
}

mkdir -p "$MEW_BIN_DIR" "$MEW_CONFIG_DIR" "$parent"
install_name="$(basename "$MEW_INSTALL_DIR")"
[[ "$install_name" != "." && "$install_name" != ".." && "$install_name" != "/" ]] || { printf 'Choose a dedicated installation directory.\n' >&2; exit 1; }
parent="$(cd "$parent" && pwd -P)"
MEW_INSTALL_DIR="$parent/$install_name"
MEW_BIN_DIR="$(cd "$MEW_BIN_DIR" && pwd -P)"
MEW_CONFIG_DIR="$(cd "$MEW_CONFIG_DIR" && pwd -P)"
for other in "$MEW_BIN_DIR" "$MEW_CONFIG_DIR"; do
  if [[ "$other/" == "$MEW_INSTALL_DIR/"* || "$MEW_INSTALL_DIR/" == "$other/"* ]]; then
    printf 'Installation, bin, and config directories must not overlap.\n' >&2
    exit 1
  fi
done
[[ ! -L "$MEW_INSTALL_DIR" ]] || { printf 'Refusing a symlinked installation directory.\n' >&2; exit 1; }
if [[ -e "$MEW_INSTALL_DIR" ]]; then
  [[ -d "$MEW_INSTALL_DIR" && -f "$MEW_INSTALL_DIR/VERSION" && -f "$MEW_INSTALL_DIR/scripts/mew" ]] || {
    printf 'Refusing to replace an unrecognized installation directory: %s\n' "$MEW_INSTALL_DIR" >&2
    exit 1
  }
fi
link="$MEW_BIN_DIR/mew"
expected_link="$MEW_INSTALL_DIR/scripts/mew"
config="$MEW_CONFIG_DIR/install.env"
if [[ -L "$link" ]]; then
  [[ "$(readlink "$link")" == "$expected_link" ]] || { printf 'Refusing to replace a different mew symlink: %s\n' "$link" >&2; exit 1; }
elif [[ -e "$link" ]]; then
  printf 'Refusing to replace an existing mew command: %s\n' "$link" >&2
  exit 1
fi
[[ ! -L "$config" ]] || { printf 'Refusing a symlinked installer configuration: %s\n' "$config" >&2; exit 1; }
[[ ! -e "$config" || -f "$config" ]] || { printf 'Installer configuration is not a regular file: %s\n' "$config" >&2; exit 1; }
config_temp="$(mktemp "$MEW_CONFIG_DIR/.install.env.XXXXXX")"
cat >"$config_temp" <<EOF
MEW_CHANNEL=$channel
MEW_VERSION=$target
MEW_REPO_URL=$MEW_REPO_URL
EOF

backup=""
if [[ -e "$MEW_INSTALL_DIR" || -L "$MEW_INSTALL_DIR" ]]; then
  backup="$(mktemp -d "$parent/.mew-backup.XXXXXX")"
  mv "$MEW_INSTALL_DIR" "$backup/previous"
  printf 'Previous CLI installation backed up at %s\n' "$backup/previous"
fi
restore_previous() {
  if [[ -e "$MEW_INSTALL_DIR" || -L "$MEW_INSTALL_DIR" ]]; then
    mv "$MEW_INSTALL_DIR" "$temporary/failed-install" || {
      printf 'Could not move the failed installation; inspect %s and %s.\n' "$MEW_INSTALL_DIR" "$backup" >&2
      return 1
    }
  fi
  if [[ -n "$backup" ]]; then
    mv "$backup/previous" "$MEW_INSTALL_DIR" || {
      printf 'Could not restore the previous installation from %s.\n' "$backup/previous" >&2
      return 1
    }
  fi
}
if ! mv "$temporary/source" "$MEW_INSTALL_DIR"; then
  restore_previous || true
  printf 'Installation failed; inspect the previous backup if restoration failed.\n' >&2
  exit 1
fi
created_link=false
if [[ ! -L "$link" ]]; then
  if ! ln -s "$expected_link" "$link"; then
    restore_previous || true
    printf 'Could not create the mew command; previous installation restored when available.\n' >&2
    exit 1
  fi
  created_link=true
fi
if ! mv "$config_temp" "$config"; then
  if [[ "$created_link" == true && -L "$link" && "$(readlink "$link")" == "$expected_link" ]]; then rm -f "$link"; fi
  restore_previous || true
  printf 'Could not save installer configuration; previous installation restored when available.\n' >&2
  exit 1
fi

printf 'MEW %s installed on channel %s.\n' "$target" "$channel"
printf 'Ensure %s is in PATH, then run: mew\n' "$MEW_BIN_DIR"
