#!/usr/bin/env bash
set -euo pipefail

root="."
[[ $# -eq 0 ]] || root="$1"
root="$(cd "$root" && pwd)"
manifest="$root/FOUNDATION_MANIFEST.yaml"

[[ -f "$manifest" ]] || { printf 'Run from a MEW workspace root.\n' >&2; exit 1; }

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive="$root/Foundation/Archive/online-upgrade-$stamp"
plan="$root/Foundation/10-Upgrade-Migration/MIGRATION-$stamp.md"

mkdir -p "$archive"
cp "$manifest" "$archive/FOUNDATION_MANIFEST.before-online.yaml"
cp "$root/Foundation/03-Project-Mode/Mode-Decision.md" "$archive/Mode-Decision.before-online.md"

cat >"$plan" <<EOF
# Online Upgrade Plan

Status: DRAFT
Prepared at: $stamp

## Preserve

- Original objectives:
- Existing approved features:
- Prototype reference archive: $archive

## New online requirements

- Domain and SSL:
- Hosting/runtime:
- Database and backup:
- Authentication and roles:
- Storage and uploads:
- Monitoring and incident response:
- Cost ceiling:

## Migration analysis

- Data to migrate, discard, or anonymize:
- Integration changes:
- Security/privacy changes:
- Downtime:
- Rollback:
- Validation:

## Developer decision

- [ ] Continue online Foundation questions
- [ ] Edit the plan
- [ ] Approve migration implementation later
EOF

sed -i 's/mode: unset # prototype_local | prototype_online | beta | production_online/mode: production_online # draft target after migration review/' "$manifest"
sed -i 's/lifecycle_status: discovery/lifecycle_status: online_upgrade_draft/' "$manifest"
sed -i 's/implementation_gate: .*/implementation_gate: BLOCKED/' "$manifest"

printf 'Online upgrade draft created: %s\n' "$plan"
printf 'Prototype snapshot archived: %s\n' "$archive"
