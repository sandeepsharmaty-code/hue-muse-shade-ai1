# Hue Muse Shade AI — Architecture Summary

## Layering (Clean Architecture)

```
Presentation Layer   lib/screens/, lib/widgets/
        |
Business Layer       lib/engines/ (23 classes), lib/core/services/
        |
Repository Layer      lib/repositories/ (14 repositories,
                       BaseSqliteRepository shared CRUD)
        |
Data Layer            lib/core/database/ (DatabaseHelper, SQLite)
```

**Hard rule, grep-verified every sprint since it was introduced**: no
screen or widget ever calls SQLite directly or contains SQL. All
business logic (scoring, ranking, matching, validation, colour
analysis) lives in `lib/engines/`; screens only call engines/
repositories through `ServiceLocator` and render results.

## Dependency Injection

`lib/core/di/service_locator.dart` — a minimal, dependency-free
type-keyed singleton registry (deliberately not a third-party DI
package). `lib/main.dart` constructs and registers, in order:
`DatabaseHelper` -> 14 repositories -> engines that depend only on
repositories (`RuleEngine`, `KnowledgeEngine`, `ShadeEngine`,
`MaterialMatchingEngine`) -> engines that depend on other engines
(`RecommendationEngine` -> `FormulaRecommendationEngine` ->
`TrialGeneratorEngine`, `ShadeMatchingEngine`, the Image Intelligence
chain).

## Routing

`lib/core/routing/` — named routes via `MaterialApp.onGenerateRoute`.
Splash -> Shell (5-tab bottom navigation, `IndexedStack`-based) is
the only always-live route; Trial is a pushed route reached from New
Shade's workflow, carrying `TrialScreenArgs` (productId,
shadeFamily).

## State Management

`provider` package, used narrowly: `AppStateProvider` (database-ready
flag), `NavigationProvider` (selected shell tab). Screen-local async
state (repository/engine call results) uses plain `StatefulWidget` +
cached `Future` fields + `FutureBuilder`, not a heavier state
management layer — a deliberate choice to keep business logic fully
inside engines rather than spread across state-management
boilerplate.

## The engine pipeline (business logic)

```
ImageAnalysisEngine
   -> ImageProcessor, ColorExtractionEngine, ColorSamplingEngine,
      DominantColorEngine, ColorConversionEngine, ColorProfileBuilder
   -> ShadeEngine (shade family/undertone classification)
        v
RuleEngine  <-- reads configurable RuleModel rows via RuleRepository
   used by: MaterialMatchingEngine, RecommendationEngine,
            ShadeMatchingEngine
        v
RecommendationEngine (ranks candidate Trial_Formula rows)
        v
FormulaRecommendationEngine (adds conflict detection, ranking
   factors, reason building, history logging)
        v
TrialGeneratorEngine (adds duplicate screening, produces the final
   Top 5)
        v
TrialValidationEngine / TrialComparisonEngine / TrialExplanationEngine
   (post-hoc analysis of the Top 5, called from the Trial screen)
        v
TrialWorkflowManager (lab-status transitions + audit trail)
```

Every arrow above is a real constructor dependency wired in
`main.dart` — nothing is discovered dynamically or duck-typed.

## Why some data lives in the `Settings` table

The approved 14-table schema was frozen after SPR-DEP-001/003. Three
later sprints needed to persist genuinely new kinds of data
(configurable rules, recommendation history, the trial audit trail)
with no dedicated table available and an explicit "database remains
frozen" instruction each time. All three are stored as `Settings`
rows, discriminated by a `record_type` column ('rule' |
'recommendation_history' | 'trial_audit' | the original 'setting').
This is documented in detail — including a real, fixed bug where an
early implementation would have leaked rows across record types — in
`docs/sprints/SPR-DEP-005-completion-report.md` through
`SPR-DEP-007-completion-report.md` and in
`lib/core/database/database_helper.dart`'s own header comment.

## Testing architecture

`test/` mirrors the layering: pure-logic tests need no setup
(`match_type_test.dart`, `rule_evaluator_test.dart`,
`color_conversion_engine_test.dart`, etc.); repository/engine tests
that touch SQLite use `sqflite_common_ffi` with
`DatabaseHelper.forTesting(db)` to run against an in-memory database
without `path_provider`'s platform channel. One widget test
(`trial_status_chip_test.dart`) exists as a starting point for
UI-level coverage.
