# Hue Muse Shade AI — Known Issues (Complete List)

Compiled from every sprint's report. Grouped by severity as best can
be judged without a real build.

## Blocking (must resolve before any real release)

1. **No real build has ever been produced.** No Flutter SDK has been
   available in the environment that wrote this code, across all 12
   sprints — nor in the environment that performed the v1.0.0
   Release Readiness Audit. `flutter analyze`, `flutter test`,
   `flutter build apk`, and `flutter build appbundle` have never
   run. This is the single fact that makes every
   "stable"/"working"/"ready" claim in this project's history a
   code-review-level claim, not a verified one.
   **Update (Release Audit, RC-1.0.0):** the `android/` platform
   folder — previously missing entirely, which would have hard-failed
   step 1 of any real build regardless of code quality — has been
   added by hand (standard Flutter embedding v2 scaffold: Gradle
   config, manifests, `MainActivity`, launcher icons, signing
   fallback). This removes the one blocker that was guaranteed to
   fail before the Dart code was even reached, but it does not
   itself constitute a verified build. The very next required step
   is running the existing `.github/workflows/flutter_release.yml`
   pipeline (or `flutter pub get && flutter analyze && flutter test
   && flutter build apk --release && flutter build appbundle`
   locally) in an environment with a real Flutter SDK, and fixing
   whatever it surfaces.

## High — needs a decision before wide release

2. **Product creation has no UI.** New Shade's product dropdown reads
   existing `Product_Master` rows but nothing in the app can create
   one. Products must be seeded some other way (direct DB access, or
   a future sprint).
3. **Import Knowledge has no file picker** — reads a fixed path
   (`Documents/imports/knowledge_import.json`). Real UX limitation
   for non-technical users.
4. **No screen-level widget tests, no integration tests.** Every
   screen's logic has been read and traced by hand across its
   introducing sprint, never executed by `flutter test` against a
   real widget tree.
5. **Database filename discrepancy** — shipped as
   `hue_muse_shade_ai.db`; one sprint's brief said
   `huemuse_shade_ai.db`. Kept the original to avoid orphaning data;
   never confirmed which was intended.

## Medium

6. ~~`RuleModel.fromMap` silently defaults an unparseable `rule_type`
   to `RuleType.product`~~ **CLOSED (v1.0.1 planning, 2026-07-16):**
   reviewed against the codebase's convention — every other field in
   this same factory already coerces to a safe default rather than
   throwing, and no logging framework exists anywhere in `lib/` to
   "surface" corruption to. An alternative (`RuleType.unknown`) was
   considered and rejected. Intentional, not a defect. Not reachable
   through normal app usage; would only matter if `Settings` rows
   were edited outside the app.
7. **`RecommendationEngine`/`FormulaRecommendationEngine`/
   `TrialGeneratorEngine` make sequential (non-batched) repository
   calls per candidate trial** — untested at realistic data volumes;
   plausible performance risk if trial-formula counts grow large.
8. **`Settings` table hosts four discriminated record types** through
   one `record_type` column with some overloaded column meanings.
   Functionally correct and documented, but adding a fifth type would
   compound the complexity — worth reconsidering the frozen-database
   constraint if that need ever arises.
9. **Restore Database requires a manual app restart** — `sqflite`
   holds the live file open; there's no in-app restart mechanism.
10. ~~"Recent Analysis" on Home is really Recent Recommendations~~
    **CLOSED (v1.0.1 planning, 2026-07-16):** verified against
    `lib/screens/home_screen.dart:261` — the shipped UI label already
    reads "Recent Recommendations." This entry was documenting the
    naming rationale (no separate `ColorProfile` persistence exists),
    not describing a live mislabeling bug. No action needed.

## Low

11. Six raw-material models (`Pigment`/`Dye`/`Mica`/`Pearl`/`Filler`/
    `Binder`) and their repositories were code-generated from a
    shared template — intentional, not a defect, but worth knowing
    if one needs a field the others don't.
12. Several scoring/ranking constants (business-priority ordinal
    mapping, ranking-factor equal-weighting, sampling/downscaling
    parameters, dark/light brightness thresholds) are code-level
    defaults rather than `RuleEngine`-configurable — each is flagged
    in its introducing sprint's report as a judgment call in the
    business's domain, not the engineering's.
13. `ColorConversionEngine.rgbToHsl` duplicates hue/saturation/
    lightness math that also exists privately inside `ShadeEngine`
    (frozen since SPR-DEP-004) — a small, accepted duplication rather
    than modifying already-approved code.

## Open confirmation requests (not defects — judgment calls awaiting sign-off)

14. Full column schemas for all 13 Data Layer tables (defined
    SPR-DEP-003) — cosmetics-domain columns chosen from general
    knowledge, not specified in any brief.
15. The 12 seeded default business rules' weights/conditions
    (SPR-DEP-005) — starting configuration, genuinely editable
    afterward, but the initial values are a guess.
16. `TrialStatus`'s allowed-transition graph (SPR-DEP-007) — in
    particular whether Rejected should be able to return to Draft,
    and whether any status should be directly Archivable.
17. Whether Trial should be a pushed route or a 6th bottom-nav tab
    (SPR-DEP-009) — chose pushed route to avoid touching the frozen
    5-tab shell.
18. Whether `image: ^4.2.0` (added SPR-DEP-008 for pixel decoding) is
    an acceptable new dependency, or `dart:ui`'s built-in codec would
    have been preferred.

None of items 14-18 block a build — they're product/business
decisions that can be revisited independently of shipping.
