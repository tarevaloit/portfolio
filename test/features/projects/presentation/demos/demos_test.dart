import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/presentation/demos/fishar_demo.dart';
import 'package:portfolio/features/projects/presentation/demos/fundido_demo.dart';
import 'package:portfolio/features/projects/presentation/demos/laburito_demo.dart';

import '../../../../helpers/pump_localized.dart';

/// Demos are drawn in a phone-sized screen.
Widget phone(Widget demo) => Center(
  child: SizedBox(width: 280, height: 598, child: demo),
);

void main() {
  group('FisharDemo', () {
    testWidgets('starts with a spot open and closes on the map', (
      tester,
    ) async {
      await tester.pumpLocalized(phone(const FisharDemo()), scrollable: false);

      expect(find.text('[Nombre del spot]'), findsOneWidget);
      expect(find.text('Tocá un spot del mapa'), findsNothing);

      await tester.tapAt(
        tester.getTopLeft(find.byType(FisharDemo)) + const Offset(20, 120),
      );
      await tester.pump();

      expect(find.text('Tocá un spot del mapa'), findsOneWidget);
      final sheet = tester.getTopLeft(find.text('[Nombre del spot]'));
      expect(
        sheet.dy,
        greaterThan(tester.getBottomLeft(find.byType(FisharDemo)).dy),
      );
    });

    testWidgets('tapping a spot selects it and opens the sheet', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpLocalized(phone(const FisharDemo()), scrollable: false);

      await tester.tap(find.byKey(const ValueKey('fishar-spot-0')));
      await tester.pump();

      expect(
        tester.getSemantics(find.byKey(const ValueKey('fishar-spot-0'))),
        matchesSemantics(
          label: 'Spot 1',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasTapAction: true,
        ),
      );
      expect(find.text('Tocá un spot del mapa'), findsNothing);
      semantics.dispose();
    });
  });

  group('FundidoDemo', () {
    testWidgets('a suggestion is sent and the piggy answers', (tester) async {
      await tester.pumpLocalized(
        phone(const FundidoDemo()),
        scrollable: false,
        reduceMotion: false,
      );
      expect(
        find.text('¡Hola! Contame qué gastaste o cobraste y lo anoto por vos.'),
        findsOneWidget,
      );

      await tester.tap(
        find.widgetWithText(ActionChip, r'Gasté $3.500 en el súper'),
      );
      await tester.pump();

      expect(
        find.widgetWithText(ActionChip, r'Gasté $3.500 en el súper'),
        findsNothing,
      );
      expect(find.text(r'Gasté $3.500 en el súper'), findsOneWidget);
      expect(find.text('escribiendo…'), findsOneWidget);

      await tester.pump(FundidoDemo.replyDelay);

      expect(find.text('escribiendo…'), findsNothing);
      expect(find.textContaining(r'Anotado: $3.500'), findsOneWidget);
    });

    testWidgets('all suggestions can be used once', (tester) async {
      await tester.pumpLocalized(
        phone(const FundidoDemo()),
        scrollable: false,
        locale: AppLocale.en,
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byType(ActionChip).first);
        await tester.pump();
        // The reply timer (zero with reduced motion), then its frame.
        await tester.pump(const Duration(milliseconds: 10));
        await tester.pump();
      }

      expect(find.byType(ActionChip), findsNothing);
      expect(
        find.text(
          r'You have $12,000 left for going out until the end of the month.',
        ),
        findsOneWidget,
      );
    });
  });

  group('LaburitoDemo', () {
    testWidgets('goes trade → professional → confirm → done and back', (
      tester,
    ) async {
      await tester.pumpLocalized(
        phone(const LaburitoDemo()),
        scrollable: false,
      );
      expect(find.text('¿Qué necesitás?'), findsOneWidget);

      await tester.tap(find.text('Electricidad'));
      await tester.pump();
      expect(find.text('Elegí un profesional'), findsOneWidget);
      expect(find.text('4,9 · 1,2 km'), findsOneWidget);

      await tester.tap(find.text('Lucía R.'));
      await tester.pump();
      expect(find.text('Electricidad con Lucía R.'), findsOneWidget);

      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump();
      expect(find.text('Elegí un profesional'), findsOneWidget);

      await tester.tap(find.text('Lucía R.'));
      await tester.pump();
      await tester.tap(find.text('Pagar con Mercado Pago'));
      await tester.pump();
      expect(find.text('¡Listo! Lucía R. va en camino.'), findsOneWidget);

      await tester.tap(find.text('Empezar de nuevo'));
      await tester.pump();
      expect(find.text('¿Qué necesitás?'), findsOneWidget);
    });

    testWidgets('formats numbers for the language', (tester) async {
      await tester.pumpLocalized(
        phone(const LaburitoDemo()),
        scrollable: false,
        locale: AppLocale.en,
      );

      await tester.tap(find.text('Plumbing'));
      await tester.pump();

      expect(find.text('4.9 · 1.2 km'), findsOneWidget);
    });
  });
}
