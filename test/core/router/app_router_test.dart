import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppRouter', () {
    testWidgets('/ renders the home in Spanish', (tester) async {
      await tester.pumpPortfolio();

      expect(
        find.text('Apps Flutter con arquitectura que aguanta.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(OutlinedButton, 'English'), findsOneWidget);
    });

    testWidgets('/en renders the home in English', (tester) async {
      await tester.pumpPortfolio(location: '/en');

      expect(
        find.text('Flutter apps with architecture that holds up.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(OutlinedButton, 'Español'), findsOneWidget);
    });

    testWidgets('the language switch changes the URL and the language', (
      tester,
    ) async {
      final router = await tester.pumpPortfolio();

      await tester.tapVisible(find.widgetWithText(OutlinedButton, 'English'));
      await tester.pumpNavigation();

      expect(router.routeInformationProvider.value.uri.path, '/en');
      expect(
        find.text('Flutter apps with architecture that holds up.'),
        findsOneWidget,
      );

      await tester.tapVisible(find.widgetWithText(OutlinedButton, 'Español'));
      await tester.pumpNavigation();

      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(
        find.text('Apps Flutter con arquitectura que aguanta.'),
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
        find.text('Flutter apps with architecture that holds up.'),
        findsOneWidget,
      );
    });
  });
}
