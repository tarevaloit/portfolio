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
    testWidgets('a complete expense is logged after "typing…"', (tester) async {
      await tester.pumpLocalized(
        phone(const FundidoDemo()),
        scrollable: false,
        reduceMotion: false,
      );
      expect(find.text('Fundi'), findsOneWidget);
      const ask = r'Ayer pizza y birra con los pibes, $4.500';

      await tester.tap(find.widgetWithText(ActionChip, ask));
      await tester.pump();

      expect(find.widgetWithText(ActionChip, ask), findsNothing);
      expect(find.text(ask), findsOneWidget);
      expect(find.text('escribiendo…'), findsOneWidget);

      await tester.pump(FundidoDemo.replyDelay);

      expect(find.text('escribiendo…'), findsNothing);
      expect(
        find.text(r'Listo, gasto anotado: $4.500 en comida, de ayer.'),
        findsOneWidget,
      );
    });

    testWidgets('a message missing data gets a question, not "logged"', (
      tester,
    ) async {
      await tester.pumpLocalized(phone(const FundidoDemo()), scrollable: false);

      await tester.tap(find.widgetWithText(ActionChip, 'Cargué nafta'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump();

      expect(
        find.text('Dale, pero no me dijiste cuánto fue ni cuándo.'),
        findsOneWidget,
      );
      expect(find.textContaining('anotado'), findsNothing);
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
        find.text(r'Logged: $18,000 in utilities, from today.'),
        findsOneWidget,
      );
    });
  });

  group('LaburitoDemo', () {
    testWidgets('follows the real flow: what → where → when → posted', (
      tester,
    ) async {
      await tester.pumpLocalized(
        phone(const LaburitoDemo()),
        scrollable: false,
      );
      expect(find.text('¿Qué necesitás?'), findsOneWidget);

      await tester.tap(find.text('Electricidad'));
      await tester.pump();
      expect(find.text('¿Dónde?'), findsOneWidget);
      expect(find.text('[Dirección del pedido]'), findsOneWidget);

      await tester.tap(find.byTooltip('Atrás'));
      await tester.pump();
      expect(find.text('¿Qué necesitás?'), findsOneWidget);

      await tester.tap(find.text('Electricidad'));
      await tester.pump();
      await tester.tap(find.text('Usar esta ubicación'));
      await tester.pump();
      expect(find.text('¿Para cuándo?'), findsOneWidget);
      // The urgency labels of PedidoUrgencia in the real app.
      expect(find.text('Puede esperar'), findsOneWidget);
      expect(find.text('Esta semana'), findsOneWidget);

      await tester.tap(find.text('Es urgente'));
      await tester.pump();
      expect(
        find.text(
          '¡Pedido publicado! Los profesionales de Electricidad cerca tuyo '
          'ya lo pueden ver.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Empezar de nuevo'));
      await tester.pump();
      expect(find.text('¿Qué necesitás?'), findsOneWidget);
    });

    testWidgets('is translated', (tester) async {
      await tester.pumpLocalized(
        phone(const LaburitoDemo()),
        scrollable: false,
        locale: AppLocale.en,
      );

      await tester.tap(find.text('Plumbing'));
      await tester.pump();
      await tester.tap(find.text('Use this location'));
      await tester.pump();

      expect(find.text('It can wait'), findsOneWidget);
    });
  });
}
