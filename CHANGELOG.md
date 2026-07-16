# Changelog

All notable changes to Hue Muse Shade AI are documented here.
Source of truth for sprint-level detail: `docs/release/VERSION_HISTORY.md`
and the individual `docs/sprints/SPR-DEP-*-completion-report.md` files.

## [1.0.0] — Release Candidate (this audit)

**Status: source-complete; build newly unblocked, not yet executed
in a real Flutter environment.** See the Release Audit Report for
the full readiness assessment.

### Added
- `android/` platform folder (previously missing entirely across all
  12 development sprints — see Known Issues #1). Standard Flutter
  embedding v2 project: Gradle config, manifests, `MainActivity`,
  launcher icons in the app's brand color, release signing
  scaffold (`key.properties.example`) that falls back to debug
  signing until a real upload keystore is supplied.
- Root `VERSION`, `CHANGELOG.md` files.

### Changed
- `pubspec.yaml` version bumped `0.1.0+1` → `1.0.0+1`.
- `.gitignore` updated so `gradlew`/`gradlew.bat` are tracked (needed
  now that `android/` is a real, committed platform folder rather
  than something CI regenerates on every run).

### Carried forward from development (SPR-DEP-001 through SPR-DEP-012)
- SPR-DEP-001 — Flutter project foundation: scaffold, folder
  structure, SQLite init (14 tables), splash screen, home placeholder.
- SPR-DEP-002 — Application shell: 5-tab bottom navigation, routing,
  DI (`ServiceLocator`), reusable widgets.
- SPR-DEP-003 — Data Layer: models, repositories, shared CRUD base,
  full domain columns (schema v2).
- SPR-DEP-004 — Knowledge Engine Foundation: `KnowledgeEngine`,
  `ShadeEngine`, `RecommendationEngine` (v1).
- SPR-DEP-005 — Rule Engine Foundation: fully rule-driven
  recommendations (schema v3).
- SPR-DEP-006 — Formula Recommendation Engine: conflict detection,
  ranking, recommendation history (schema v4).
- SPR-DEP-007 — Trial Recommendation Workflow: 6-state trial
  lifecycle with full audit trail (schema v5).
- SPR-DEP-008 — Image Intelligence Foundation: deterministic offline
  colour extraction/classification (new dependency: `image ^4.2.0`).
- SPR-DEP-009 — UI Integration: all engines wired into Home, New
  Shade, Search, Knowledge, Settings, and Trial screens.
- SPR-DEP-010 — QA & Beta Readiness: fixed unguarded release-build
  logging and unvalidated database restore; added first
  repository-backed and widget tests.
- SPR-DEP-011 — Release Candidate Audit: static pass for unused
  imports, dead code, memory leaks, DI consistency — 0 new defects.
- SPR-DEP-012 — Production Release Package: full release
  documentation set; explicit non-certification of the (at that
  time) unverified build gate.

### Known limitations at this release
See `docs/release/KNOWN_ISSUES.md` for the complete, severity-ranked
list. Headline items: no real `flutter build`/`flutter test` run has
been executed yet in a genuine Flutter/Android toolchain (this audit
removed the `android/`-folder blocker to that but could not itself
run the toolchain — see Release Audit Report); no in-app product
creation UI; no file picker for knowledge import; no screen-level
widget/integration tests.
