/// Purpose      : Shared test infrastructure for widget tests that
///                pump a real screen (not just a leaf widget).
/// Author       : HMEOS Engineering
/// Version      : 1.0.0
/// Dependencies : flutter_test, sqflite_common_ffi,
///                core/database/database_helper.dart,
///                core/di/service_locator.dart, repositories/*,
///                engines/rule_engine.dart,
///                engines/material_matching_engine.dart,
///                engines/trial_workflow_manager.dart
/// Description  : trial_status_chip_test.dart (SPR-DEP-010) was this
///                project's first widget test and deliberately picked
///                a leaf widget needing no ServiceLocator wiring,
///                flagging "pumping a full screen would require
///                registering test doubles for the entire DI graph"
///                as a follow-up. This file is that follow-up.
///
///                Rather than a mocking framework (none is a project
///                dependency, and adding one is out of scope — "Do
///                NOT add dependencies"), this opens a real in-memory
///                SQLite database via sqflite_common_ffi (exactly
///                product_repository_test.dart's existing, already-
///                accepted pattern, extended to every table this
///                project's screens actually touch) and registers
///                real repository/engine instances against it via
///                ServiceLocator — the same objects production code
///                uses, just pointed at a throwaway database.
///                ServiceLocator.reset() in tearDown is the
///                "Intended for test teardown only" method already
///                present on ServiceLocator (SPR-DEP-002), not
///                something added for this file.
///
///                Only wires what the ten screens named in R6-003
///                actually call via ServiceLocator.get<T>() —
///                confirmed by grepping every one of those screen
///                files, not assumed. The full 30+-registration graph
///                in main.dart also wires the AI/image-analysis
///                engines, which none of those ten screens use
///                directly (only new_shade_screen.dart does, and it
///                isn't in the R6-003 list).
///
<<<<<<< HEAD
///                Also provides settle() (R7.1 fix): LoadingView
///                (lib/widgets/loading_view.dart) uses an
///                *indeterminate* CircularProgressIndicator, which
///                repeats forever by design. tester.pumpAndSettle()
///                cannot tell "still loading" from "stuck forever" —
///                it just keeps pumping the spinner's frames until it
///                hits its own default timeout, which is exactly
///                Duration(minutes: 10). That is the literal source
///                of the "TimeoutException after 10 minutes" CI hit.
///                settle() wraps the exact same pumpAndSettle() call
///                with an explicit 10-second timeout instead, so any
///                future recurrence of this fails fast and clearly —
///                seconds, not the whole CI job's time budget — while
///                behaving identically to pumpAndSettle() for every
///                test that genuinely settles quickly, which is all
///                of them against this harness's fast in-memory
///                database.
=======
///                Also provides settle() (R7.1, revised in this CI
///                Widget Test Repair pass): LoadingView
///                (lib/widgets/loading_view.dart) uses an
///                *indeterminate* CircularProgressIndicator, which
///                repeats forever by design — tester.pumpAndSettle()
///                cannot tell "still loading" from "stuck forever", it
///                just keeps pumping the spinner's frames until it
///                hits a timeout. R7.1 capped that timeout at 10
///                seconds instead of the 10-minute default, which
///                correctly turned a 10-minute CI hang into a fast
///                failure — but it was still pumpAndSettle() deciding
///                when to stop, and a real CI run then surfaced the
///                actual root cause it was fast-failing on: a Batch
///                opened inside onCreate() was fighting onCreate's own
///                implicit transaction for the write lock (see
///                _openTestDatabase() below), leaving the database
///                stuck mid-initialization so every query genuinely
///                never completed. That's now fixed at the source.
///                With it fixed, settle() no longer needs
///                pumpAndSettle() at all: it pumps a fixed, small
///                number of frames (matching the deterministic
///                bounded-loop pattern already used for engine
///                startup elsewhere in this test suite) and returns,
///                regardless of whether an indeterminate animation is
///                still running somewhere in the tree. This is
///                strictly deterministic — no dependency on Flutter's
///                own "wait until stable" heuristic, so an
///                indeterminate spinner can never cause it to hang or
///                even need a timeout to fall back on.
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
/// Change History:
///   1.0.0 - Repair Sprint R6 (Production Readiness & QA) - Initial
///           creation.
///   1.1.0 - R7.1 (Final Release Validation fix) - Added settle()
<<<<<<< HEAD
///           and ensureSqfliteFfiInitialized() — see the two notes
///           above. No change to what is registered or how.
library;

import 'package:flutter/material.dart';
=======
///           (then pumpAndSettle()-with-10s-timeout-based) and
///           ensureSqfliteFfiInitialized().
///   1.2.0 - CI Widget Test Repair - Fixed _openTestDatabase()'s
///           onCreate to use plain sequential db.execute() instead of
///           a Batch (root cause of the "database has been locked"/
///           "already closed" cascade CI actually hit). Rewrote
///           settle() as a fully deterministic bounded pump loop,
///           removing its last dependency on pumpAndSettle() entirely.
library;

>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:hue_muse_shade_ai/core/database/database_helper.dart';
import 'package:hue_muse_shade_ai/core/di/service_locator.dart';
import 'package:hue_muse_shade_ai/engines/material_matching_engine.dart';
import 'package:hue_muse_shade_ai/engines/rule_engine.dart';
import 'package:hue_muse_shade_ai/engines/trial_workflow_manager.dart';
import 'package:hue_muse_shade_ai/repositories/binder_repository.dart';
import 'package:hue_muse_shade_ai/repositories/dye_repository.dart';
import 'package:hue_muse_shade_ai/repositories/filler_repository.dart';
import 'package:hue_muse_shade_ai/repositories/knowledge_repository.dart';
import 'package:hue_muse_shade_ai/repositories/mica_repository.dart';
import 'package:hue_muse_shade_ai/repositories/pearl_repository.dart';
import 'package:hue_muse_shade_ai/repositories/pigment_repository.dart';
import 'package:hue_muse_shade_ai/repositories/product_repository.dart';
import 'package:hue_muse_shade_ai/repositories/recommendation_history_repository.dart';
import 'package:hue_muse_shade_ai/repositories/rule_repository.dart';
import 'package:hue_muse_shade_ai/repositories/shade_repository.dart';
import 'package:hue_muse_shade_ai/repositories/trial_audit_repository.dart';
import 'package:hue_muse_shade_ai/repositories/trial_repository.dart';

/// Every column set below is copied verbatim from
/// database_helper.dart's own schema (read directly, not assumed) —
/// this file can't import that map, since it's a private field of a
/// different library. Every table also gets the same
/// is_active/created_at/updated_at audit columns
/// database_helper.dart's _createTableStatement appends to all of
/// them.
const Map<String, List<String>> _kTestSchemaColumns = <String, List<String>>{
  'Product_Master': <String>[
    'name TEXT NOT NULL',
    'product_code TEXT NOT NULL',
    'category TEXT NOT NULL',
    'base_type TEXT',
    'description TEXT',
  ],
  'Shade_Master': <String>[
    'name TEXT NOT NULL',
    'shade_code TEXT NOT NULL',
    'product_id INTEGER',
    'hex_color TEXT',
    'shade_family TEXT',
    'finish TEXT',
    "status TEXT NOT NULL DEFAULT 'draft'",
  ],
  'Pigment_Master': <String>[
    'name TEXT NOT NULL',
    'material_code TEXT NOT NULL',
    'cas_number TEXT',
    'supplier TEXT',
    "unit TEXT NOT NULL DEFAULT 'g'",
    'cost_per_unit REAL NOT NULL DEFAULT 0',
    'stock_quantity REAL NOT NULL DEFAULT 0',
    'color_index TEXT',
  ],
  'Dye_Master': <String>[
    'name TEXT NOT NULL',
    'material_code TEXT NOT NULL',
    'cas_number TEXT',
    'supplier TEXT',
    "unit TEXT NOT NULL DEFAULT 'g'",
    'cost_per_unit REAL NOT NULL DEFAULT 0',
    'stock_quantity REAL NOT NULL DEFAULT 0',
    'solubility TEXT',
  ],
  'Mica_Master': <String>[
    'name TEXT NOT NULL',
    'material_code TEXT NOT NULL',
    'cas_number TEXT',
    'supplier TEXT',
    "unit TEXT NOT NULL DEFAULT 'g'",
    'cost_per_unit REAL NOT NULL DEFAULT 0',
    'stock_quantity REAL NOT NULL DEFAULT 0',
    'particle_size TEXT',
  ],
  'Pearl_Master': <String>[
    'name TEXT NOT NULL',
    'material_code TEXT NOT NULL',
    'cas_number TEXT',
    'supplier TEXT',
    "unit TEXT NOT NULL DEFAULT 'g'",
    'cost_per_unit REAL NOT NULL DEFAULT 0',
    'stock_quantity REAL NOT NULL DEFAULT 0',
    'pearl_type TEXT',
  ],
  'Filler_Master': <String>[
    'name TEXT NOT NULL',
    'material_code TEXT NOT NULL',
    'cas_number TEXT',
    'supplier TEXT',
    "unit TEXT NOT NULL DEFAULT 'g'",
    'cost_per_unit REAL NOT NULL DEFAULT 0',
    'stock_quantity REAL NOT NULL DEFAULT 0',
    'filler_type TEXT',
  ],
  'Binder_Master': <String>[
    'name TEXT NOT NULL',
    'material_code TEXT NOT NULL',
    'cas_number TEXT',
    'supplier TEXT',
    "unit TEXT NOT NULL DEFAULT 'g'",
    'cost_per_unit REAL NOT NULL DEFAULT 0',
    'stock_quantity REAL NOT NULL DEFAULT 0',
    'binder_type TEXT',
  ],
  'Trial_Formula': <String>[
    'name TEXT NOT NULL',
    'trial_code TEXT NOT NULL',
    'shade_id INTEGER',
    'product_id INTEGER',
    "status TEXT NOT NULL DEFAULT 'draft'",
    'notes TEXT',
  ],
  'Formula_Material': <String>[
    'name TEXT',
    'trial_formula_id INTEGER NOT NULL',
    'material_table TEXT NOT NULL',
    'material_id INTEGER NOT NULL',
    'percentage REAL NOT NULL DEFAULT 0',
    'notes TEXT',
  ],
  'Approved_Formula': <String>[
    'name TEXT',
    'trial_formula_id INTEGER NOT NULL',
    'approved_by TEXT',
    'approval_notes TEXT',
  ],
  'Knowledge_Base': <String>[
    'name TEXT NOT NULL',
    'approved_formula_id INTEGER',
    'tags TEXT',
    'content TEXT',
  ],
  // Backs RuleRepository, RecommendationHistoryRepository, and
  // TrialAuditRepository, discriminated by record_type — same
  // multi-purpose table database_helper.dart itself uses.
  'Settings': <String>[
    'name TEXT',
    "record_type TEXT NOT NULL DEFAULT 'setting'",
    'rule_type TEXT',
    'condition_key TEXT',
    'condition_operator TEXT',
    'condition_value TEXT',
    'priority INTEGER NOT NULL DEFAULT 0',
    'weight REAL NOT NULL DEFAULT 1.0',
    'rule_version INTEGER NOT NULL DEFAULT 1',
    'description TEXT',
    'input_parameters TEXT',
    'selected_trial_formula_id INTEGER',
    'confidence_score REAL',
    'reason_text TEXT',
    'status_from TEXT',
    'status_to TEXT',
    'changed_by TEXT',
    'related_recommendation_id INTEGER',
  ],
};

<<<<<<< HEAD
/// Same as `tester.pumpAndSettle()`, but with an explicit 10-second
/// timeout instead of pumpAndSettle()'s own 10-minute default — see
/// this file's header for why that default is the literal source of
/// the "TimeoutException after 10 minutes" CI hit. Behaves exactly
/// like pumpAndSettle() otherwise (same pump interval, same engine
/// phase) for any test that genuinely settles, which is every test
/// against this harness's fast in-memory database.
Future<void> settle(WidgetTester tester) {
  return tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
=======
/// Deterministic replacement for `tester.pumpAndSettle()`. Pumps one
/// immediate frame, then [extraPumps] more frames [step] apart, and
/// returns — it never asks "has everything stopped animating?" the
/// way pumpAndSettle() does, so an indeterminate spinner (LoadingView
/// uses one) can't make it wait indefinitely; there is nothing here
/// for it to wait *on*. Each pump() still drains the microtask queue
/// once, which is what actually lets an in-flight repository query
/// resolve and its rebuild happen — 21 pumps is comfortably more than
/// this harness's fast in-memory-SQLite screens need, including
/// multi-hop chains like FormulaDetailsScreen's per-ingredient
/// IMaterialMatchingEngine calls. Bounded and fixed-cost either way:
/// nothing here can hang, and nothing here can take longer than
/// [extraPumps] frames regardless of what's on screen.
Future<void> settle(
  WidgetTester tester, {
  int extraPumps = 20,
  Duration step = const Duration(milliseconds: 100),
}) async {
  await tester.pump();
  for (int i = 0; i < extraPumps; i++) {
    await tester.pump(step);
  }
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
}

bool _sqfliteFfiInitialized = false;

/// Initializes the sqflite FFI loader once per test isolate instead
/// of once per test. sqfliteFfiInit() is safe to call repeatedly, but
/// every widget test file's setUp() (which runs before *each* test,
/// not once per file) calling it before every single test adds
/// redundant initialization overhead that compounds across a suite
/// this size.
void ensureSqfliteFfiInitialized() {
  if (!_sqfliteFfiInitialized) {
    sqfliteFfiInit();
    _sqfliteFfiInitialized = true;
  }
}

Future<Database> _openTestDatabase() async {
  ensureSqfliteFfiInitialized();
  return databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (Database db, int version) async {
<<<<<<< HEAD
        final Batch batch = db.batch();
        for (final MapEntry<String, List<String>> entry
            in _kTestSchemaColumns.entries) {
          final String columns = entry.value.join(', ');
          batch.execute('''
=======
        // onCreate already runs inside an implicit transaction — a
        // separate Batch here previously fought that transaction for
        // the write lock (confirmed by CI: "Warning database has been
        // locked for 0:00:10.000000... use the transaction object for
        // database operations during a transaction", followed by
        // pumpAndSettle/test timeouts on every test). Plain sequential
        // execute() calls are exactly what the already-working
        // product_repository_test.dart uses for its own single-table
        // onCreate — no Batch involved there either.
        for (final MapEntry<String, List<String>> entry
            in _kTestSchemaColumns.entries) {
          final String columns = entry.value.join(', ');
          await db.execute('''
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
            CREATE TABLE ${entry.key} (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              $columns,
              is_active INTEGER NOT NULL DEFAULT 1,
              created_at TEXT NOT NULL DEFAULT (datetime('now')),
              updated_at TEXT NOT NULL DEFAULT (datetime('now'))
            )
          ''');
        }
<<<<<<< HEAD
        await batch.commit(noResult: true);
=======
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
      },
    ),
  );
}

/// Everything a widget test needs: an isolated in-memory database and
/// every repository/engine the ten R6-003 screens use, all pointed
/// at it. Call [WidgetTestHarness.open] in setUp and
/// [WidgetTestHarness.close] in tearDown.
<<<<<<< HEAD
=======
///
/// Lifecycle contract: each test gets its own fresh database (a new
/// [WidgetTestHarness.open] call in that test's own setUp — never
/// shared or reused across tests) and its own fresh ServiceLocator
/// registrations. Call [settle] (above) before your test's last
/// assertion so every repository call the widget triggered has
/// actually completed *before* tearDown calls [close] — that
/// ordering, not anything close() can do after the fact, is what
/// prevents a query from touching the database after it's gone.
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
class WidgetTestHarness {
  WidgetTestHarness._(this._db, this.databaseHelper);

  final Database _db;
  final DatabaseHelper databaseHelper;
<<<<<<< HEAD
=======
  bool _closed = false;
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)

  static Future<WidgetTestHarness> open() async {
    final Database db = await _openTestDatabase();
    final DatabaseHelper helper = DatabaseHelper.forTesting(db);
    final WidgetTestHarness harness = WidgetTestHarness._(db, helper);
    harness._registerAll();
    return harness;
  }

  Future<void> close() async {
<<<<<<< HEAD
=======
    if (_closed) {
      // Never double-close: sqflite itself throws on a second close(),
      // and a defensive no-op here is the correct response to that,
      // not a hidden bug — the actual close below already happened.
      return;
    }
    _closed = true;
    // One microtask-queue drain for anything scheduled but not yet
    // run at the moment tearDown fired — belt-and-suspenders on top
    // of each test calling settle() before its own last assertion,
    // which is the real guarantee that nothing is still in flight
    // here.
    await Future<void>.delayed(Duration.zero);
>>>>>>> f931330 (Fix widget test deadlocks and CI stability)
    ServiceLocator.instance.reset();
    await _db.close();
  }

  void _registerAll() {
    final ProductRepository productRepository = ProductRepository(
      databaseHelper: databaseHelper,
    );
    final ShadeRepository shadeRepository = ShadeRepository(
      databaseHelper: databaseHelper,
    );
    final PigmentRepository pigmentRepository = PigmentRepository(
      databaseHelper: databaseHelper,
    );
    final DyeRepository dyeRepository = DyeRepository(
      databaseHelper: databaseHelper,
    );
    final MicaRepository micaRepository = MicaRepository(
      databaseHelper: databaseHelper,
    );
    final PearlRepository pearlRepository = PearlRepository(
      databaseHelper: databaseHelper,
    );
    final FillerRepository fillerRepository = FillerRepository(
      databaseHelper: databaseHelper,
    );
    final BinderRepository binderRepository = BinderRepository(
      databaseHelper: databaseHelper,
    );
    final TrialRepository trialRepository = TrialRepository(
      databaseHelper: databaseHelper,
    );
    final KnowledgeRepository knowledgeRepository = KnowledgeRepository(
      databaseHelper: databaseHelper,
    );
    final RuleRepository ruleRepository = RuleRepository(
      databaseHelper: databaseHelper,
    );
    final RecommendationHistoryRepository historyRepository =
        RecommendationHistoryRepository(databaseHelper: databaseHelper);
    final TrialAuditRepository trialAuditRepository = TrialAuditRepository(
      databaseHelper: databaseHelper,
    );

    final RuleEngine ruleEngine = RuleEngine(ruleRepository: ruleRepository);
    final MaterialMatchingEngine materialMatchingEngine =
        MaterialMatchingEngine(
      ruleEngine: ruleEngine,
      pigmentRepository: pigmentRepository,
      dyeRepository: dyeRepository,
      micaRepository: micaRepository,
      pearlRepository: pearlRepository,
      fillerRepository: fillerRepository,
      binderRepository: binderRepository,
    );
    final TrialWorkflowManager trialWorkflowManager = TrialWorkflowManager(
      trialRepository: trialRepository,
      auditRepository: trialAuditRepository,
    );

    ServiceLocator.instance
      ..registerSingleton<ProductRepository>(productRepository)
      ..registerSingleton<ShadeRepository>(shadeRepository)
      ..registerSingleton<PigmentRepository>(pigmentRepository)
      ..registerSingleton<DyeRepository>(dyeRepository)
      ..registerSingleton<MicaRepository>(micaRepository)
      ..registerSingleton<PearlRepository>(pearlRepository)
      ..registerSingleton<FillerRepository>(fillerRepository)
      ..registerSingleton<BinderRepository>(binderRepository)
      ..registerSingleton<TrialRepository>(trialRepository)
      ..registerSingleton<KnowledgeRepository>(knowledgeRepository)
      ..registerSingleton<RuleRepository>(ruleRepository)
      ..registerSingleton<RecommendationHistoryRepository>(historyRepository)
      ..registerSingleton<TrialAuditRepository>(trialAuditRepository)
      ..registerSingleton<IRuleEngine>(ruleEngine)
      ..registerSingleton<IMaterialMatchingEngine>(materialMatchingEngine)
      ..registerSingleton<ITrialWorkflowManager>(trialWorkflowManager);
  }
}
