#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
version="$(tr -d '\n' < "$root/VERSION")"
output="$root/dist"
[[ $# -eq 0 ]] || output="$1"

mkdir -p "$output"
archive="$output/madevi-engineer-website-$version.tar.gz"

tar \
  --exclude=.git \
  --exclude=dist \
  --exclude=.DS_Store \
  -czf "$archive" \
  -C "$(dirname "$root")" \
  "$(basename "$root")"

sha256sum "$archive" >"$archive.sha256"
printf 'Created %s and checksum.\n' "$archive"
