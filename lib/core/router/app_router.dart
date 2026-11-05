import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/platform/document/document_language.dart';
import 'package:portfolio/core/router/deferred_page.dart';
import 'package:portfolio/core/router/not_found_page.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/home/presentation/widgets/home_preview.dart'
    deferred as preview;
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart'
    deferred as detail;

/// Route names, one per locale (`home-es`, `project-en`...).
abstract final class AppRoutes {
  static String home(AppLocale locale) => 'home-${locale.name}';
  static String project(AppLocale locale) => 'project-${locale.name}';

  /// URL of a project detail in [locale].
  static String projectPath(AppLocale locale, String slug) =>
      locale.path('/projects/$slug');
}

/// The project detail (with its demos, the code highlighter and the home
/// preview) is compiled apart from the home, so the first load is smaller.
final DeferredLibrary projectDetailLibrary = DeferredLibrary(
  () => Future.wait([detail.loadLibrary(), preview.loadLibrary()]),
);

/// Downloads the deferred routes in the background. Called after the first
/// frame, so a click on a card finds the detail ready (and the Hero flies).
Future<void> preloadDeferredRoutes() => projectDetailLibrary.load();

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
      NotFoundPage(path: state.uri.path),
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
        builder: (context, state) => Title(
          title: context.l10n.appTitle,
          color: AppColors.accentLime,
          child: const HomePage(),
        ),
        routes: [
          // Child of the home so the home stays below it: going back keeps
          // its scroll, and the card → detail Hero can fly.
          GoRoute(
            path: 'projects/:slug',
            name: AppRoutes.project(locale),
            pageBuilder: (context, state) => _fadePage(
              context,
              state,
              DeferredPage(
                library: projectDetailLibrary,
                builder: (context) => detail.ProjectDetailPage(
                  slug: state.pathParameters['slug']!,
                  extraDemos: {
                    'portfolio': (_) => preview.HomePreview(),
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Fade transition, so the Hero flights are the only movement. No
/// transition (and therefore no flight) with reduced motion.
Page<void> _fadePage(BuildContext context, GoRouterState state, Widget child) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 450);
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

Widget _withLocale(BuildContext context, AppLocale locale, Widget child) {
  return DocumentLanguage(
    languageCode: locale.locale.languageCode,
    child: Localizations.override(
      context: context,
      locale: locale.locale,
      child: child,
    ),
  );
}
