# Validation Policy

Standard validation reports missing information as warnings and returns NEED_INFO.

Gate validation is used before implementation approval. It requires:

- developer experience level;
- guidance mode;
- project mode;
- a primary objective;
- Foundation status READY;
- no open CRITICAL risk.

Only a developer approval command can change the implementation gate to APPROVED. An agent may recommend READY but may not bypass gate validation.

Release readiness is separate from implementation approval. Use `Foundation/12-Handover/Release-Readiness.md` before calling an implementation release stable; record known limits instead of overstating maturity.
