/// Purpose      : Home tab content for the application shell.
/// Author       : HMEOS Engineering
/// Version      : 3.0.0
/// Dependencies : flutter/material.dart, provider,
///                core/services/navigation_provider.dart,
///                core/di/service_locator.dart,
///                repositories/product_repository.dart,
///                repositories/shade_repository.dart,
///                repositories/trial_repository.dart,
///                repositories/recommendation_history_repository.dart,
///                widgets/*
/// Description  : Landing tab shown inside RootShellScreen's
///                IndexedStack. Displays this sprint's required
///                "HOME SCREEN" content — Application Summary, Recent
///                Recommendations, Pending Lab Trials, Quick Actions
///                — all read through repositories via ServiceLocator,
///                never SQLite directly. "Recent Analysis" is not
///                separately tracked (ColorProfile has no repository,
///                per SPR-DEP-008's Known Issues — image analysis
///                results are transient), so this screen surfaces
///                Recent Recommendations as the closest honest proxy
///                rather than fabricating a separate analysis feed —
///                flagged in the SPR-DEP-009 report.
/// Change History:
///   1.0.0 - SPR-DEP-001 - Initial creation. Standalone placeholder
///           screen with its own Scaffold/AppBar.
///   2.0.0 - SPR-DEP-002 - Converted to shell tab content (body-only).
///           Added quick-start card wired to real tab navigation.
///   3.0.0 - SPR-DEP-009 - Full Home Screen: Application Summary,
///           Recent Recommendations, Pending Lab Trials, Quick
///           Actions, all repository-backed.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/di/service_locator.dart';
import '../core/services/navigation_provider.dart';
import '../models/recommendation_history_model.dart';
import '../models/trial_formula_model.dart';
import '../models/trial_status.dart';
import '../repositories/product_repository.dart';
import '../repositories/recommendation_history_repository.dart';
import '../repositories/repository_exception.dart';
import '../repositories/shade_repository.dart';
import '../repositories/trial_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/trial_status_chip.dart';

class _HomeSummary {
  const _HomeSummary({
    required this.productCount,
    required this.shadeCount,
    required this.pendingTrials,
    required this.recentRecommendations,
  });

  final int productCount;
  final int shadeCount;
  final List<TrialFormulaModel> pendingTrials;
  final List<RecommendationHistoryModel> recentRecommendations;
}

/// Home tab: application summary, recent activity, and quick actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<_HomeSummary> _loadSummary() async {
    final ProductRepository productRepository = ServiceLocator.instance
        .get<ProductRepository>();
    final ShadeRepository shadeRepository = ServiceLocator.instance
        .get<ShadeRepository>();
    final TrialRepository trialRepository = ServiceLocator.instance
        .get<TrialRepository>();
    final RecommendationHistoryRepository historyRepository =
        ServiceLocator.instance.get<RecommendationHistoryRepository>();

    try {
      final results = await Future.wait<Object>(<Future<Object>>[
        productRepository.count(),
        shadeRepository.count(),
        trialRepository.filter(<String, Object?>{
          'status': TrialStatus.readyForLab.storageKey,
        }),
        trialRepository.filter(<String, Object?>{
          'status': TrialStatus.labTesting.storageKey,
        }),
        historyRepository.recent(limit: 5),
      ]);

      final List<TrialFormulaModel> readyForLab =
          results[2] as List<TrialFormulaModel>;
      final List<TrialFormulaModel> labTesting =
          results[3] as List<TrialFormulaModel>;

      return _HomeSummary(
        productCount: results[0] as int,
        shadeCount: results[1] as int,
        pendingTrials: <TrialFormulaModel>[...readyForLab, ...labTesting],
        recentRecommendations:
            results[4] as List<RecommendationHistoryModel>,
      );
    } on RepositoryException {
      return const _HomeSummary(
        productCount: 0,
        shadeCount: 0,
        pendingTrials: <TrialFormulaModel>[],
        recentRecommendations: <RecommendationHistoryModel>[],
      );
    }
  }

  void _refresh() {
    setState(() => _summaryFuture = _loadSummary());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: FutureBuilder<_HomeSummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          final _HomeSummary summary =
              snapshot.data ??
              const _HomeSummary(
                productCount: 0,
                shadeCount: 0,
                pendingTrials: <TrialFormulaModel>[],
                recentRecommendations: <RecommendationHistoryModel>[],
              );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              // Application Summary
              Text(
                'Hue Muse Shade AI',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Offline cosmetic colour shade development.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      label: 'Products',
                      value: '${summary.productCount}',
                      icon: Icons.category_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Shades',
                      value: '${summary.shadeCount}',
                      icon: Icons.palette_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Pending',
                      value: '${summary.pendingTrials.length}',
                      icon: Icons.science_outlined,
                    ),
                  ),
                ],
              ),

              // Quick Actions
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  AppButton(
                    label: 'New Shade',
                    icon: Icons.add_photo_alternate_outlined,
                    onPressed: () => context.read<NavigationProvider>()
                        .selectTab(AppTab.newShade),
                  ),
                  AppButton(
                    label: 'Search',
                    icon: Icons.search,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.read<NavigationProvider>()
                        .selectTab(AppTab.search),
                  ),
                  AppButton(
                    label: 'Knowledge',
                    icon: Icons.menu_book_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.read<NavigationProvider>()
                        .selectTab(AppTab.knowledgeBase),
                  ),
                ],
              ),

              // Pending Lab Trials
              const SizedBox(height: 24),
              Text(
                'Pending Lab Trials',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (summary.pendingTrials.isEmpty)
                const AppCard(child: Text('No trials pending lab work.'))
              else
                for (final trial in summary.pendingTrials)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text(trial.name)),
                          TrialStatusChip(
                            status:
                                TrialStatus.fromStorageKey(trial.status) ??
                                TrialStatus.draft,
                          ),
                        ],
                      ),
                    ),
                  ),

              // Recent Recommendations
              const SizedBox(height: 24),
              Text(
                'Recent Recommendations',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (summary.recentRecommendations.isEmpty)
                const AppCard(child: Text('No recommendations generated yet.'))
              else
                for (final entry in summary.recentRecommendations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AppCard(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.insights,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  entry.reasonText ??
                                      'Trial #${entry.selectedTrialFormulaId}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (entry.confidenceScore != null)
                                  Text(
                                    '${(entry.confidenceScore! * 100).toStringAsFixed(0)}% confidence',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        children: <Widget>[
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
