import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/app/app.dart';
import 'package:portfolio/core/router/app_router.dart';

extension PumpPortfolio on WidgetTester {
  /// Pumps the whole app starting at [location] and returns its router.
  ///
  /// The view defaults to a 1440×900 desktop, the widest size in PLAN.md.
  Future<GoRouter> pumpPortfolio({
    String location = '/',
    Size size = const Size(1440, 900),
  }) async {
    view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(view.reset);

    final router = createAppRouter(initialLocation: location);
    addTearDown(router.dispose);
    await pumpWidget(
      ProviderScope(
        overrides: [appRouterProvider.overrideWithValue(router)],
        child: const PortfolioApp(),
      ),
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
