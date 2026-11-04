import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/theme/app_theme.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/shaders/blueprint_background.dart';

extension PumpLocalized on WidgetTester {
  /// Pumps [child] inside the app theme, localizations and a ProviderScope,
  /// in a scrollable page of [size]. Motion is reduced by default.
  Future<void> pumpLocalized(
    Widget child, {
    Size size = const Size(1440, 900),
    AppLocale locale = AppLocale.es,
    List<Override> overrides = const [],
    bool reduceMotion = true,
    bool scrollable = true,
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

    await pumpWidget(
      ProviderScope(
        overrides: [
          backgroundEffectsEnabledProvider.overrideWithValue(false),
          ...overrides,
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          locale: locale.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: scrollable ? SingleChildScrollView(child: child) : child,
          ),
        ),
      ),
    );
    await pump();
  }
}
