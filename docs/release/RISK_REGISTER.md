# Hue Muse Shade AI — Risk Register

| # | Risk | Likelihood | Impact | Owner action needed |
|---|---|---|---|---|
| 1 | Codebase has never been compiled; unknown compile errors may exist | Cannot estimate — genuinely unmeasured | High if present | Run `flutter pub get && flutter analyze` immediately; this is the single highest-priority action before anything else in this register matters |
| 2 | `flutter test` may reveal failing assertions in the ~70 written-but-unexecuted test cases | Low-Medium (each was hand-traced) | Medium | Run `flutter test`; fix any failures — they'd indicate a genuine logic error, not just a missing feature |
| 3 | Performance at real data volumes is unmeasured (startup, memory, recommendation-pipeline latency) | Unknown | Medium-High | Load-test with realistic product/shade/trial/material counts on a target device |
| 4 | Android-version-specific incompatibility across the 8-14 target range | Unknown | Medium | Install and manually walk the Release Candidate Checklist on real/emulated devices spanning that range |
| 5 | `image` package (added SPR-DEP-008) may have API surface changes vs. what was coded against (never compiled) | Low-Medium | Medium | First `flutter analyze` run will surface this immediately if present |
| 6 | Restore Database's file-permission behavior on scoped-storage Android versions (10+) is unverified | Unknown | Medium | Device-test Backup -> Restore explicitly on Android 10+ |
| 7 | Product-creation gap (no UI) blocks real usage until products are seeded some other way | Certain (by design gap) | High for adoption, zero for code correctness | Decide: build a Product creation screen, or seed via direct DB access/import |
| 8 | No integration/widget test coverage means regressions in future changes won't be caught automatically | Certain (documented gap) | Medium, compounding over time | Prioritize integration test coverage before further feature work |
| 9 | `Settings` table's 4-record-type overload could become unmanageable if a 5th type is ever needed | Low near-term | Low-Medium long-term | Revisit the frozen-database constraint before adding a 5th type |
| 10 | Several business-domain weights/thresholds are engineering judgment calls, not confirmed business decisions | Certain (documented) | Low for code stability, potentially High for recommendation quality in practice | Review and tune `RuleModel` weights and ranking constants against real formulation data |
| 11 | Import Knowledge's fixed-path UX may confuse non-technical lab staff | Medium | Low-Medium | Add a real file picker in a future sprint, or document the workaround clearly for end users |

## How to read this register

Risks 1-6 are about **whether the code works at all** — they can only
be resolved by actually running the Flutter toolchain, something this
development environment has never had access to. Risks 7-11 are about
**product completeness and tuning** — real, but independent of
whether the current code compiles and runs correctly.
