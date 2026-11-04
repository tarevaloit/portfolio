import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/router/not_found_page.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';

/// Route names, one per locale (`home-es`, `home-en`).
abstract final class AppRoutes {
  static String home(AppLocale locale) => 'home-${locale.name}';
}

/// App-wide router. Tests override it to start at another location.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Builds the router.
///
/// Every locale gets its own [ShellRoute] that overrides the
/// [Localizations] of its subtree, so the language comes from the URL
/// (`/` → es, `/en` → en) instead of from global state.
GoRouter createAppRouter({String initialLocation = '/'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [for (final locale in AppLocale.values) _localeShell(locale)],
    errorBuilder: (context, state) => _withLocale(
      context,
      AppLocale.fromPath(state.uri.path),
      const NotFoundPage(),
    ),
  );
}

ShellRoute _localeShell(AppLocale locale) {
  return ShellRoute(
    builder: (context, state, child) => _withLocale(context, locale, child),
    routes: [
      GoRoute(
        path: locale.homePath,
        name: AppRoutes.home(locale),
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}

Widget _withLocale(BuildContext context, AppLocale locale, Widget child) {
  return Localizations.override(
    context: context,
    locale: locale.locale,
    child: child,
  );
}
