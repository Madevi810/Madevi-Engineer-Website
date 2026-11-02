# Decision Graph

Use this graph to preserve consequences when a decision changes. It complements the chronological Decision Log.

```text
Objective → Module → Requirement → Material → Architecture → Test → Deploy → Operation
              └→ Taxonomy/Content → Source/Rights → Quality → Publish
```

| Decision ID | Upstream reason | Downstream affected areas | Change request required? | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| | | | | | pending |

When a decision changes, identify and review every downstream node before implementation is changed. A feature request is not complete until its impacts are either approved, deferred, or rejected.
