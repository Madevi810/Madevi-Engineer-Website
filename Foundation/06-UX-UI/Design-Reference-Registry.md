# UI/UX Design Reference Registry

Register an external reference before the agent analyzes it. A reference supplies a discussion topic, never a copying instruction.

| ID | Reference | UI/UX area to study | Allowed output | Explicit exclusions | Status |
| --- | --- | --- | --- | --- | --- |
| UXREF-001 | FigCraft public repository | Interface-design and prototyping workflow; template and design-review ideas | Original UWF layout/process recommendations | Code, brand, icons, fonts, screenshots, canvas UI, `.fig` format, plugin runtime, and distinctive visual composition | REVIEW_REQUIRED |

## Decision rules

1. Record the specific lesson in `Reference-Analysis.md`; do not treat the whole product as a style to copy.
2. Connect the lesson to this web project's users, responsive needs, accessibility, and performance constraints.
3. Produce an original simulation only after the developer selects a direction.
4. If the reference would affect architecture, implementation, or a third-party dependency, open a separate Change Request instead of expanding UI/UX scope silently.

For FigCraft, use `FigCraft-Reference-Catalog.md`. It maps all relevant public feature areas to an original UWF Foundation action, optional product requirement, or explicit out-of-scope classification.
