#!/usr/bin/env bash
set -euo pipefail

url="${1:-}"
[[ $# -eq 1 && "$url" =~ ^https?://[^[:space:]]+$ ]] || { printf 'Usage: health-check.sh http(s)://host/path\n' >&2; exit 1; }
authority="${url#*://}"
authority="${authority%%/*}"
authority="${authority%%\?*}"
authority="${authority%%\#*}"
[[ -n "$authority" && "$authority" != *'@'* ]] || { printf 'URL credentials are not accepted.\n' >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { printf 'curl is required.\n' >&2; exit 1; }

if result="$(curl --disable --silent --output /dev/null --connect-timeout 5 --max-time 10 --proto '=http,https' --write-out '%{http_code} %{time_total}' -- "$url" 2>/dev/null)"; then
  read -r status duration <<<"$result"
  [[ "$status" =~ ^[0-9]{3}$ && "$duration" =~ ^[0-9]+([.][0-9]+)?$ ]] || { printf 'Unexpected curl output.\n' >&2; exit 1; }
  printf '{"observation":"http_response","http_status":%s,"duration_seconds":%s,"redirects_followed":false}\n' "$((10#$status))" "$duration"
else
  code=$?
  printf '{"observation":"network_error","curl_exit":%s,"redirects_followed":false}\n' "$code"
  exit 2
fi
