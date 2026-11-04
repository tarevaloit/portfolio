import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/theme/app_theme.dart';
import 'package:portfolio/core/l10n/language_switch.dart';

import '../../helpers/pump_app.dart';

void main() {
  Finder inSwitch(Finder finder) =>
      find.descendant(of: find.byType(LanguageSwitch), matching: finder);

  testWidgets('in Spanish, ES is highlighted and EN is the link', (
    tester,
  ) async {
    await tester.pumpPortfolio();

    expect(inSwitch(find.widgetWithText(TextButton, 'ES')), findsNothing);
    expect(inSwitch(find.widgetWithText(TextButton, 'EN')), findsOneWidget);
    expect(
      tester.widget<Text>(inSwitch(find.text('ES'))).style?.color,
      AppTheme.dark().colorScheme.primary,
    );
  });

  testWidgets('in English, EN is highlighted and ES is the link', (
    tester,
  ) async {
    await tester.pumpPortfolio(location: '/en');

    expect(inSwitch(find.widgetWithText(TextButton, 'EN')), findsNothing);
    expect(inSwitch(find.widgetWithText(TextButton, 'ES')), findsOneWidget);
  });

  testWidgets('the current language is announced as selected', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpPortfolio();

    expect(
      tester.getSemantics(inSwitch(find.text('ES'))),
      matchesSemantics(label: 'ES', isSelected: true, hasSelectedState: true),
    );
    semantics.dispose();
  });
}
