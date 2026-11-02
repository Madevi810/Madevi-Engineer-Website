# Stage 12 — Implementation Handover

The handover is the only package an implementation agent should need before starting an approved stage. It includes:

- approved objectives, scope, and feature specs;
- selected stack or a clear deferred-decision list;
- UX/UI and acceptance criteria;
- architecture and data/API decisions;
- risks, constraints, and unresolved non-blocking questions;
- test, deployment, and rollback expectations.

Use `templates/handover.md`. After code changes, update the handover status and record material implementation deviations.

Before a release is described as stable, complete `Release-Readiness.md`. A release can be blocked, limited, preview-only, or stable; do not claim a stronger status than the evidence supports.
