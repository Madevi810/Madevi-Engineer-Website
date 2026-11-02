# Implementation Area — Locked

This directory intentionally contains no application code.

It can become `Project-Name-Project/` only after:

1. the relevant Foundation stage is `READY`;
2. the developer has approved implementation;
3. `FOUNDATION_MANIFEST.yaml` has `implementation_gate: APPROVED`.

Run:

```bash
uwf approve implementation --project "Name-Project"
```

The command creates a minimal, technology-neutral application workspace with a changelog, implementation history, technical decision record, and Foundation-to-code traceability record. Stack-specific code is created only after the approved handover identifies it.
