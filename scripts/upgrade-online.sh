#!/usr/bin/env bash
set -euo pipefail

root="."
[[ $# -eq 0 ]] || root="$1"
root="$(cd "$root" && pwd)"
manifest="$root/FOUNDATION_MANIFEST.yaml"

[[ -f "$manifest" ]] || { printf 'Run from a MEW workspace root.\n' >&2; exit 1; }

stamp="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$root/Foundation/Archive"
archive="$(mktemp -d "$root/Foundation/Archive/online-upgrade-$stamp-XXXXXX")"
plan="$root/Foundation/10-Upgrade-Migration/MIGRATION-${archive##*online-upgrade-}.md"

cp "$manifest" "$archive/FOUNDATION_MANIFEST.before-online.yaml"
# Keep the previous Foundation, but do not recursively copy earlier archives.
mkdir -p "$archive/Foundation"
while IFS= read -r -d '' entry; do
  cp -R "$entry" "$archive/Foundation/"
done < <(find "$root/Foundation" -mindepth 1 -maxdepth 1 ! -name Archive -print0)

cat >"$plan" <<EOF
# Online Upgrade Plan

Status: DRAFT
Prepared at: $stamp

## Preserve

- Original objectives: see archived Foundation and manifest
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

temporary="$(mktemp "${manifest}.tmp.XXXXXX")"
awk '
  /^project:$/ { section="project"; print; next }
  /^foundation:$/ { section="foundation"; print; next }
  /^composition:$/ { section="composition"; print; next }
  /^[^[:space:]]/ { section="" }
  section == "project" && /^  lifecycle_status:/ { print "  lifecycle_status: online_upgrade_draft"; next }
  section == "foundation" && /^  status:/ { print "  status: DRAFT"; next }
  section == "foundation" && /^  implementation_gate:/ { print "  implementation_gate: BLOCKED"; next }
  section == "foundation" && /^  implementation_status:/ { print "  implementation_status: DEFERRED"; next }
  section == "composition" && /^  status:/ { print "  status: DRAFT"; next }
  { print }
' "$manifest" >"$temporary"
mv "$temporary" "$manifest"
composition="$root/Foundation/15-Engineering-Materials/Composition-Manifest.md"
if [[ -f "$composition" ]]; then
  sed -i 's/^Status: \(READY\|APPROVED\)[[:space:]]*$/Status: DRAFT/' "$composition"
fi

printf 'Online upgrade draft created: %s\n' "$plan"
printf 'Prototype snapshot archived: %s\n' "$archive"
printf 'Existing project mode is preserved until the developer selects and approves an online target.\n'
