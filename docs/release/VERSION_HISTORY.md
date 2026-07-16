# Hue Muse Shade AI — Version History / Change Log

All changes are tracked as one commit per sprint in the local git
repository (`git log` in the delivered zip shows the full history).

| Sprint | Summary |
|---|---|
| SPR-DEP-001 | Flutter project foundation: scaffold, folder structure, `pubspec.yaml`, SQLite init (14 tables, foundation columns), splash screen, home placeholder |
| SPR-DEP-002 | Application shell: bottom navigation (5 tabs), routing, DI (`ServiceLocator`), 10 reusable widgets, 5 screens |
| SPR-DEP-003 | Data Layer: 13 models, 11 repositories, `BaseSqliteRepository` shared CRUD, full domain columns (schema v2) |
| SPR-DEP-004 | Knowledge Engine Foundation: `EngineResult`, `SearchMatcher`, `KnowledgeEngine`, `ShadeEngine`, `RecommendationEngine` (v1, weights hardcoded) |
| SPR-DEP-005 | Rule Engine Foundation: `RuleEngine`, `ShadeMatchingEngine`, `MaterialMatchingEngine`; `RecommendationEngine` refactored to be fully rule-driven (schema v3 — rules in `Settings`) |
| SPR-DEP-006 | Formula Recommendation Engine: `RecommendationConflictDetector`, `ReasonBuilder`, `Filter`, `Ranker`, `History`, `FormulaRecommendationEngine` (schema v4 — recommendation history in `Settings`) |
| SPR-DEP-007 | Trial Recommendation Workflow: `TrialGeneratorEngine`, `TrialValidationEngine`, `TrialComparisonEngine`, `TrialExplanationEngine`, `TrialWorkflowManager`, `TrialStatus` (6-state graph), audit trail (schema v5) |
| SPR-DEP-008 | Image Intelligence Foundation: `ColorConversionEngine`, `ImageProcessor`, `ColorSamplingEngine`, `DominantColorEngine`, `ColorExtractionEngine`, `ColorProfileBuilder`, `ImageAnalysisEngine`. New dependency: `image ^4.2.0` |
| SPR-DEP-009 | UI Integration: all 8 top-level engines wired into Home/New Shade/Search/Knowledge/Settings screens + new Trial screen (pushed route) |
| SPR-DEP-010 | QA & Beta Readiness: fixed unguarded release-build logging (3 sites) and unvalidated database restore; added repository-backed `RuleEngine` test and first widget test |
| SPR-DEP-011 | Release Candidate Audit: deeper static pass (unused imports, dead code, memory leaks, DI consistency) — 0 new defects found |
| SPR-DEP-012 | Production Release Package (this sprint): release documentation set; **no code changes** (nothing found to fix); explicit non-certification of the unverified build gate |

## Semantic versioning note

This project has used `0.1.0` as its `pubspec.yaml` version
throughout development. This sprint's brief asks for "Version 1.0.0"
— bumping to 1.0.0 is a statement that the software is
production-ready, which per this sprint's own report cannot yet be
certified (no real build has ever run). The version number in
`pubspec.yaml` has **not** been changed to 1.0.0 as part of this
sprint; see the SPR-DEP-012 completion report for the reasoning.
