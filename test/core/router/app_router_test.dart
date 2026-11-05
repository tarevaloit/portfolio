import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppRouter', () {
    testWidgets('/ renders the home in Spanish', (tester) async {
      await tester.pumpPortfolio();

      expect(
        find.text('Apps mobile, de la idea a las stores.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'EN'), findsOneWidget);
    });

    testWidgets('/en renders the home in English', (tester) async {
      await tester.pumpPortfolio(location: '/en');

      expect(
        find.text('Mobile apps, from the idea to the stores.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'ES'), findsOneWidget);
    });

    testWidgets('the language switch changes the URL and the language', (
      tester,
    ) async {
      final router = await tester.pumpPortfolio();

      await tester.tapVisible(find.widgetWithText(TextButton, 'EN'));
      await tester.pumpNavigation();

      expect(router.routeInformationProvider.value.uri.path, '/en');
      expect(
        find.text('Mobile apps, from the idea to the stores.'),
        findsOneWidget,
      );

      await tester.tapVisible(find.widgetWithText(TextButton, 'ES'));
      await tester.pumpNavigation();

      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(
        find.text('Apps mobile, de la idea a las stores.'),
        findsOneWidget,
      );
    });

    testWidgets('unknown paths show a 404 in Spanish', (tester) async {
      await tester.pumpPortfolio(location: '/no-existe');

      expect(find.text('Página no encontrada'), findsOneWidget);
    });

    testWidgets('unknown /en paths show a 404 in English and link home', (
      tester,
    ) async {
      final router = await tester.pumpPortfolio(location: '/en/missing');

      expect(find.text('Page not found'), findsOneWidget);

      await tester.tapVisible(find.text('Back to home'));
      await tester.pumpNavigation();

      expect(router.routeInformationProvider.value.uri.path, '/en');
      expect(
        find.text('Mobile apps, from the idea to the stores.'),
        findsOneWidget,
      );
    });
  });
}
