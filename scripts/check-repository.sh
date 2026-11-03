#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
failed=0

need() {
  [[ -f "$root/$1" ]] || { printf 'Missing: %s\n' "$1" >&2; failed=1; }
}

for file in README.md AGENTS.md FOUNDATION_MANIFEST.yaml VERSION LICENSE CHANGELOG.md CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md scripts/mew; do
  need "$file"
done

for file in \
  scripts/install-agent-skill.sh \
  scripts/inspect-project.py \
  scripts/observe-system.py \
  integrations/agent-skills/mew-website-engineer/SKILL.md \
  integrations/agent-skills/mew-website-engineer/references/engineering.md \
  integrations/agent-skills/mew-website-engineer/references/live-operations.md \
  integrations/agent-skills/mew-website-engineer/scripts/health-check.sh \
  integrations/agent-skills/mew-website-engineer/scripts/watch-http.sh; do
  need "$file"
done

for file in \
  Foundation/05-Features-Requirements/Feature-Gap-Audit.md \
  Foundation/06-UX-UI/Creative-Brief.md \
  Foundation/06-UX-UI/Responsive-Accessibility-Review.md \
  Foundation/06-UX-UI/Simulation-Plan.md \
  Foundation/06-UX-UI/Reference-Analysis.md \
  Foundation/06-UX-UI/Design-Reference-Registry.md \
  Foundation/06-UX-UI/FigCraft-Reference-Catalog.md \
  Foundation/00-Control/Capability-Matrix.md \
  Foundation/00-Control/Decision-Graph.md \
  Foundation/00-Control/Evaluation-Lab.md \
  Foundation/00-Control/Status-Report.md \
  Foundation/00-Control/Action-Journal.md \
  Foundation/15-Engineering-Materials/README.md \
  Foundation/15-Engineering-Materials/Material-Catalog.md \
  Foundation/15-Engineering-Materials/Material-Lifecycle.md \
  Foundation/15-Engineering-Materials/Composition-Manifest.md \
  Foundation/16-External-Reference-Evidence/README.md \
  Foundation/16-External-Reference-Evidence/Source-Policy.md \
  Foundation/16-External-Reference-Evidence/Evidence-Registry.md \
  Foundation/17-Research-Content-Operations/README.md \
  Foundation/17-Research-Content-Operations/Research-Policy.md \
  Foundation/17-Research-Content-Operations/Taxonomy-Content-Map.md \
  Foundation/17-Research-Content-Operations/Scale-Batch-Plan.md \
  Foundation/17-Research-Content-Operations/Publish-Controls.md \
  Foundation/17-Research-Content-Operations/Freshness-Capacity-Plan.md \
  Foundation/09-Deployment-Operations/Data-Lifecycle-Fallback.md \
  Foundation/12-Handover/Release-Readiness.md \
  Foundation/14-Change-Management/README.md \
  Foundation/14-Change-Management/Backlog.md \
  Foundation/14-Change-Management/Revision-History.md \
  templates/change-request.md \
  templates/composition-manifest.md \
  templates/evidence-card.md \
  templates/runtime-profile.md \
  templates/research-plan.md \
  templates/content-map.md \
  templates/production-queue.md \
  templates/rights-ledger.md \
  templates/operations-run-history.md \
  templates/freshness-capacity-plan.md \
  templates/release-readiness.md \
  templates/starter-packs/content-platform.md \
  templates/starter-packs/marketplace.md \
  templates/starter-packs/dashboard.md \
  templates/starter-packs/hybrid-platform.md \
  templates/implementation/CHANGELOG.md \
  templates/implementation/IMPLEMENTATION-HISTORY.md \
  templates/implementation/DECISIONS.md \
  templates/implementation/TRACEABILITY.md \
  docs/images/mew-linux-cli-preview.svg \
  docs/images/mew-ide-preview.svg \
  agent/README.md \
  agent/Orchestrator.md \
  agent/Routing-Rules.yaml \
  agent/Question-Policy.md \
  agent/Assumption-Policy.md \
  agent/Status-Protocol.md \
  agent/Escalation-Rules.md \
  tools/README.md \
  tools/contracts/README.md \
  tools/runners/mew-tool.sh \
  tools/safety/action-gate.sh \
  tools/validators/validate-tool-contracts.sh \
  policies/permissions/README.md \
  policies/external-research/README.md \
  policies/data-handling/README.md \
  policies/publishing/README.md \
  policies/automation/README.md \
  policies/model-runtime/README.md \
  schemas/manifest/README.md \
  schemas/tool-contract/README.md \
  schemas/job-log/README.md \
  schemas/status-report/README.md \
  schemas/decision-graph/README.md \
  evaluations/README.md \
  evaluations/regression/run.sh; do
  need "$file"
done

for contract in capability-detector workspace-inspector manifest-engine compatibility-engine taxonomy-builder content-batch-planner quality-review release-evaluator github-research web-search deployment-adapter publish-queue; do
  need "tools/contracts/$contract.yaml"
done

for file in \
  skills/README.md \
  skills/foundation-orchestrator/SKILL.md \
  skills/product-discovery/SKILL.md \
  skills/architecture-stack/SKILL.md \
  skills/ux-ui/SKILL.md \
  skills/quality-security-rights/SKILL.md \
  skills/operations-release/SKILL.md \
  skills/engineering-composer/SKILL.md \
  skills/external-reference-scout/SKILL.md \
  skills/taxonomy-architect/SKILL.md \
  skills/content-operations/SKILL.md \
  skills/rights-and-provenance/SKILL.md \
  skills/dependency-vetter/SKILL.md; do
  need "$file"
done

if ! grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' "$root/VERSION"; then
  printf 'VERSION must use semantic version format.\n' >&2
  failed=1
fi

if grep -RInE '(AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH) PRIVATE KEY|password[[:space:]]*=[[:space:]]*[^[:space:]]+)' "$root" --exclude-dir=.git --exclude=check-repository.sh; then
  printf 'Potential secret pattern found. Remove it before release.\n' >&2
  failed=1
fi

if [[ "$failed" -ne 0 ]]; then
  exit 1
fi

printf 'Repository hardening checks passed.\n'
