import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/app/di/repository_overrides.dart';
import 'package:portfolio/core/router/app_router.dart';
import 'package:portfolio/core/shaders/blueprint_background.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';

extension PumpPortfolio on WidgetTester {
  /// Pumps the whole app starting at [location] and returns its router.
  ///
  /// The view defaults to a 1440×900 desktop, the widest size in PLAN.md.
  /// Motion is reduced by default so entrance and reveal animations do not
  /// leave timers behind; pass `reduceMotion: false` to test them.
  Future<GoRouter> pumpPortfolio({
    String location = '/',
    Size size = const Size(1440, 900),
    bool reduceMotion = true,
    ContactRepository? contactRepository,
    ProjectsRepository? projectsRepository,
    List<Override> overrides = const [],
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
    if (reduceMotion) {
      platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(platformDispatcher.clearAccessibilityFeaturesTestValue);
    }

    // As in main.dart: the deferred detail is fetched before it is needed.
    await runAsync(preloadDeferredRoutes);
    final router = createAppRouter(initialLocation: location);
    addTearDown(router.dispose);
    await pumpWidget(
      ProviderScope(
        overrides: [
          ...repositoryOverrides(
            contact: contactRepository,
            projects: projectsRepository,
          ),
          appRouterProvider.overrideWithValue(router),
          // Goldens and layout tests must not depend on the GPU shader.
          backgroundEffectsEnabledProvider.overrideWithValue(false),
          ...overrides,
        ],
        child: const PortfolioApp(),
      ),
    );
    // Content is read from the asset bundle, which completes outside the
    // fake clock. Twice: some content waits for other content (the contact
    // email of the detail page).
    for (var i = 0; i < 2; i++) {
      await runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await pump();
    }
    return router;
  }

  /// Lets asset images (logos, screenshots) decode, which happens outside
  /// the fake clock, so goldens and captures show them.
  Future<void> settleImages() async {
    for (var i = 0; i < 3; i++) {
      await runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await pump();
    }
  }

  /// Lets a navigation and its page transition finish, including content
  /// that a new route loads from the asset bundle. `pumpAndSettle` cannot
  /// be used because the logo cursor blinks forever.
  Future<void> pumpNavigation() async {
    await pump();
    await runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await pump(const Duration(seconds: 1));
  }

  /// Scrolls [finder] into view and taps it.
  Future<void> tapVisible(Finder finder) async {
    await ensureVisible(finder);
    await pump();
    await tap(finder);
  }
}
