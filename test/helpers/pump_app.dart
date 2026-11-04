import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/app/di/repository_overrides.dart';
import 'package:portfolio/core/router/app_router.dart';

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

    final router = createAppRouter(initialLocation: location);
    addTearDown(router.dispose);
    await pumpWidget(
      ProviderScope(
        overrides: [
          ...repositoryOverrides(),
          appRouterProvider.overrideWithValue(router),
          ...overrides,
        ],
        child: const PortfolioApp(),
      ),
    );
    // Content is read from the asset bundle, which completes outside the
    // fake clock.
    await runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await pump();
    return router;
  }

  /// Lets a navigation and its page transition finish. `pumpAndSettle`
  /// cannot be used because the logo cursor blinks forever.
  Future<void> pumpNavigation() => pump(const Duration(seconds: 1));

  /// Scrolls [finder] into view and taps it.
  Future<void> tapVisible(Finder finder) async {
    await ensureVisible(finder);
    await pump();
    await tap(finder);
  }
}
