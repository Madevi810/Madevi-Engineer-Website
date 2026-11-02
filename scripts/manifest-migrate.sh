#!/usr/bin/env bash
set -euo pipefail

root="."
[[ $# -eq 0 ]] || root="$1"
manifest="$root/FOUNDATION_MANIFEST.yaml"
[[ -f "$manifest" ]] || { printf 'Manifest not found: %s\n' "$manifest" >&2; exit 1; }

schema="$(grep -E '^schema_version:' "$manifest" | head -n 1 | sed -E 's/^schema_version:[[:space:]]*//')"
case "$schema" in
  1) printf 'Manifest schema 1 is supported by MEW.\n' ;;
  *) printf 'Unsupported manifest schema: %s\n' "$schema" >&2; exit 1 ;;
esac

if grep -q '^uwf_version:' "$manifest"; then
  backup="${manifest}.pre-mew-brand.bak"
  [[ -e "$backup" ]] || cp "$manifest" "$backup"
  sed -i 's/^uwf_version:/mew_version:/' "$manifest"
  printf 'Migrated legacy manifest branding; backup: %s\n' "$backup"
fi

if ! grep -q '^agent_runtime:' "$manifest"; then
  backup="${manifest}.pre-v1.2.bak"
  [[ -e "$backup" ]] || cp "$manifest" "$backup"
  temporary="$(mktemp "${manifest}.tmp.XXXXXX")"
  awk '
    { print }
    /^  implementation_status:/ {
      print ""
      print "agent_runtime:"
      print "  profile_status: DRAFT # DRAFT | DECLARED | VERIFIED | LIMITED"
      print "  web_research: unknown # unknown | unavailable | available_with_approval"
      print "  github_access: unknown # unknown | unavailable | available_with_approval"
      print "  filesystem_write: unknown # unknown | unavailable | available_with_approval"
      print "  publication_access: unavailable # unavailable | available_with_approval"
      print "  limits: []"
      print ""
      print "composition:"
      print "  status: DRAFT # DRAFT | REVIEW | READY | APPROVED"
      print "  manifest_file: Foundation/15-Engineering-Materials/Composition-Manifest.md"
      print "  selected_materials: []"
      print "  rejected_materials: []"
      print ""
      print "external_evidence:"
      print "  status: OPTIONAL # OPTIONAL | PLANNED | REVIEW | VERIFIED | LIMITED"
      print "  registry_file: Foundation/16-External-Reference-Evidence/Evidence-Registry.md"
      print "  source_policy_status: DRAFT # DRAFT | READY | APPROVED"
    }
    /^  kill_switch:/ {
      print ""
      print "content_operations:"
      print "  enabled: false"
      print "  status: DEFERRED # DEFERRED | PLANNED | READY | ACTIVE | PAUSED | ARCHIVED"
      print "  mode: plan_only # plan_only | draft_assisted | implementation_assisted | controlled_autonomous"
      print "  scale_target: 0"
      print "  taxonomy_status: DEFERRED # DEFERRED | DRAFT | REVIEW | READY | APPROVED"
      print "  research_policy_status: DEFERRED # DEFERRED | DRAFT | READY | APPROVED"
      print "  publishing_status: DISABLED # DISABLED | REVIEW_REQUIRED | APPROVED_LIMITED"
      print "  operations_root: unset"
    }
  ' "$manifest" >"$temporary"
  mv "$temporary" "$manifest"
  printf 'Added MEW 1.2 runtime, composition, evidence, and content-operation fields; backup: %s\n' "$backup"
fi

if ! grep -q '^agent_orchestration:' "$manifest"; then
  backup="${manifest}.pre-v1.3.bak"
  [[ -e "$backup" ]] || cp "$manifest" "$backup"
  temporary="$(mktemp "${manifest}.tmp.XXXXXX")"
  awk '
    { print }
    /^  limits:/ {
      print ""
      print "agent_orchestration:"
      print "  status: DRAFT # DRAFT | ROUTED | NEED_INFO | READY | APPROVED"
      print "  mode: autonomous_foundation_composition # autonomous_foundation_composition | guided_choice"
      print "  question_budget: 3"
      print "  active_roles: []"
      print "  active_tools: []"
      print "  status_report_file: Foundation/00-Control/Status-Report.md"
      print "  action_journal: Foundation/00-Control/Action-Journal.md"
    }
  ' "$manifest" >"$temporary"
  mv "$temporary" "$manifest"
  printf 'Added MEW 1.3 agent orchestration fields; backup: %s\n' "$backup"
fi
