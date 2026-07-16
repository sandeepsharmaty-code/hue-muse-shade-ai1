/// Purpose      : Centralized route dispatcher for Hue Muse Shade AI.
/// Author       : HMEOS Engineering
/// Version      : 2.0.0
/// Dependencies : flutter/material.dart, app_routes.dart,
///                screens/splash_screen.dart,
///                screens/root_shell_screen.dart,
///                screens/trial_screen.dart
/// Description  : Single onGenerateRoute implementation used by
///                MaterialApp so navigation is centralized rather
///                than scattered across screens with inline
///                MaterialPageRoute construction. Unknown route names
///                resolve to a simple "route not found" screen
///                instead of crashing, per the "never crash
///                application" error-handling rule.
/// Change History:
///   1.0.0 - SPR-DEP-002 - Initial creation.
///   2.0.0 - SPR-DEP-009 - Added AppRoutes.trial dispatch. Falls back
///           to the "not found" screen if TrialScreenArgs weren't
///           supplied correctly, rather than crashing on a bad cast.
library;

import 'package:flutter/material.dart';

import '../../screens/root_shell_screen.dart';
import '../../screens/splash_screen.dart';
import '../../screens/trial_screen.dart';
import 'app_routes.dart';

/// Resolves route names to concrete screens for the app's
/// [MaterialApp.onGenerateRoute].
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute<void>(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.shell:
        return MaterialPageRoute<void>(
          builder: (_) => const RootShellScreen(),
          settings: settings,
        );

      case AppRoutes.trial:
        final Object? args = settings.arguments;
        if (args is! TrialScreenArgs) {
          return MaterialPageRoute<void>(
            builder: (_) => const _UnknownRouteScreen(
              routeName: '${AppRoutes.trial} (missing arguments)',
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (_) => TrialScreen(args: args),
          settings: settings,
        );

      default:
        return MaterialPageRoute<void>(
          builder: (_) => _UnknownRouteScreen(routeName: settings.name),
          settings: settings,
        );
    }
  }
}

/// Fallback screen shown when navigation is requested to an
/// unregistered route name. Prevents an unhandled-route crash.
class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen({required this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Not Found')),
      body: Center(
        child: Text('No screen registered for route "${routeName ?? ''}".'),
      ),
    );
  }
}
