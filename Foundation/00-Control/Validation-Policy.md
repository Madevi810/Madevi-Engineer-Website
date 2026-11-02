# Validation Policy

Standard validation reports missing information as warnings and returns NEED_INFO.

Gate validation is used before implementation approval. It requires:

- developer experience level;
- guidance mode;
- project mode;
- a primary objective;
- Foundation status READY;
- declared agent runtime capability profile;
- Composition Manifest status READY or APPROVED;
- no open CRITICAL risk.

If content operations are enabled, standard validation also checks that the Operations workspace exists. Autonomous or publish-enabled content operation requires the approved autonomy policy and run history. Source, taxonomy, rights, and publishing reviews remain required before the relevant action; a content target alone is never permission to write or publish.

Only a developer approval command can change the implementation gate to APPROVED. An agent may recommend READY but may not bypass gate validation.

Release readiness is separate from implementation approval. Use `Foundation/12-Handover/Release-Readiness.md` before calling an implementation release stable; record known limits instead of overstating maturity.
