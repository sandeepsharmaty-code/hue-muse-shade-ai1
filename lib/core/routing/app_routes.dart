/// Purpose      : Centralized route name constants for Hue Muse
///                Shade AI.
/// Author       : HMEOS Engineering
/// Version      : 2.0.0
/// Dependencies : none (pure Dart)
/// Description  : Single source of truth for named routes so no
///                screen hardcodes a route string.
/// Change History:
///   1.0.0 - SPR-DEP-002 - Initial creation.
///   2.0.0 - SPR-DEP-009 - Added `trial`, dispatched by AppRouter to
///           the new TrialScreen. Kept the 5-tab shell exactly as
///           approved (SPR-DEP-002) rather than adding a 6th bottom
///           tab — Trial is reached by push (from New Shade's
///           workflow or Home's "Pending Lab Trials"), not as a tab.
library;

/// Named route identifiers used throughout the app.
class AppRoutes {
  AppRoutes._();

  /// Splash screen — initial route, performs SQLite bootstrap.
  static const String splash = '/';

  /// Root application shell — bottom navigation host for Home,
  /// New Shade, Knowledge Base, Search, and Settings tabs.
  static const String shell = '/shell';

  /// Trial detail screen — pushed with a `productId` (int) and
  /// optional `shadeFamily` (String) as route arguments.
  static const String trial = '/trial';

  // Reserved for future module sprints. Not yet dispatched by
  // AppRouter; declared here so route names are agreed in advance
  // and future sprints don't invent ad hoc strings.
  static const String newShadeCapture = '/new-shade/capture';
  static const String knowledgeBaseDetail = '/knowledge-base/detail';
}
