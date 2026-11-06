import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/browser_frame.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/feature_code.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/how_its_built_section.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/media_carousel.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/phone_frame.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/web_media_section.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/project_fixtures.dart';
import '../../../helpers/pump_app.dart';

void main() {
  group('ProjectDetailPage with the real content', () {
    testWidgets('shows metadata, counter and the layers of the feature', (
      tester,
    ) async {
      await tester.pumpPortfolio(location: '/projects/fishar');

      expect(find.byType(ProjectDetailPage), findsOneWidget);
      expect(find.text('01 / 04'), findsOneWidget);
      expect(
        find.text('App social · Byto Apps · Beta · TestFlight'),
        findsOneWidget,
      );
      expect(find.text('Founder · diseño, desarrollo y publicación'), findsOneWidget);
      expect(find.text('iOS · Android'), findsOneWidget);
      expect(find.text('feature: spots'), findsOneWidget);
      expect(find.byType(LayerCard), findsNWidgets(3));
      expect(find.text('GetSpotsUseCase'), findsOneWidget);
      // The real use case, copied from the Fishar repo.
      expect(find.byType(CodeBlock), findsOneWidget);
      // Fishar has no images besides its icon.
      expect(find.text('Del proyecto'), findsNothing);
    });

    testWidgets('"Este portfolio" shows its real snippet and decisions', (
      tester,
    ) async {
      await tester.pumpPortfolio(location: '/en/projects/portfolio');

      expect(find.text('04 / 04'), findsOneWidget);
      expect(find.byType(CodeBlock), findsOneWidget);
      expect(find.text('Technical decisions'), findsOneWidget);
      expect(find.text('The language comes from the URL'), findsOneWidget);
    });

    testWidgets('the eyebrow does not repeat the badge', (tester) async {
      await tester.pumpPortfolio(location: '/projects/laburito');

      expect(find.text('Proyecto final · USAL'), findsOneWidget);
    });

    testWidgets('shows the app icon and the real images with captions', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpPortfolio(location: '/projects/laburito');

      final icon = find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName ==
                'assets/projects/laburito-logo.webp',
      );
      expect(icon, findsOneWidget);
      expect(find.text('Del proyecto'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Burndown del proyecto al cierre del Sprint 3: ideal, planificada '
          'y real.',
        ),
        findsOneWidget,
      );
      semantics.dispose();
    });

    testWidgets('the phone shows the real screens; the web its own section', (
      tester,
    ) async {
      await tester.pumpPortfolio(location: '/projects/laburito');

      final phone = find.ancestor(
        of: find.byType(PhoneFrame),
        matching: find.byType(MediaCarousel),
      );
      expect(phone, findsOneWidget);
      expect(
        find.textContaining('Billetera de tokens', findRichText: true),
        findsOneWidget,
      );
      expect(find.byType(WebMediaSection), findsOneWidget);
      expect(find.text('Versión web'), findsOneWidget);
      expect(find.byType(BrowserFrame), findsOneWidget);
    });

    testWidgets('a project without a web version has no web section', (
      tester,
    ) async {
      await tester.pumpPortfolio(location: '/projects/fishar');

      expect(find.byType(MediaCarousel), findsOneWidget);
      expect(find.byType(WebMediaSection), findsNothing);
    });

    testWidgets('a private repo asks for access by mail', (tester) async {
      final opener = RecordingLinkOpener();
      await tester.pumpPortfolio(
        location: '/projects/fishar',
        overrides: [linkOpenerProvider.overrideWithValue(opener)],
      );

      expect(find.widgetWithText(OutlinedButton, 'Código ↗'), findsNothing);
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Repo privado · pedir acceso'),
      );

      expect(
        opener.opened.single.toString(),
        'mailto:bytoapps@gmail.com'
        '?subject=Acceso%20al%20c%C3%B3digo%20de%20Fishar',
      );
    });

    testWidgets('the code shows one file at a time, from tabs or the tree', (
      tester,
    ) async {
      await tester.pumpPortfolio(location: '/projects/laburito');
      final code = find.byType(FeatureCode);
      await tester.ensureVisible(code);
      await tester.pump();

      // Opens on the first excerpt (presentation).
      expect(
        find.textContaining('Future<bool> confirmar()', findRichText: true),
        findsOneWidget,
      );

      await tester.tap(
        find
            .descendant(
              of: code,
              matching: find.text('pedidos_repository.dart'),
            )
            .first,
      );
      await tester.pump();
      expect(
        find.textContaining('Future<Pedido> crearPedido(', findRichText: true),
        findsOneWidget,
      );

      // The tree opens the files that have an excerpt.
      await tester.tap(find.bySemanticsLabel('Ver pedido_estado.dart'));
      await tester.pump();
      expect(
        find.textContaining('enum PedidoEstado', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('Archivos del feature'), findsOneWidget);
      expect(find.text('test/'), findsOneWidget);
    });

    testWidgets('"Ver cómo está hecho" scrolls to the layers', (tester) async {
      await tester.pumpPortfolio(location: '/projects/fishar');

      final before = tester.getTopLeft(find.byType(HowItsBuiltSection)).dy;
      await tester.tap(find.text('Ver cómo está hecho ↓'));
      await tester.pumpNavigation();

      // Scrolled as far as the page allows: to the top, or to the end when
      // the rest of the page is shorter than the viewport.
      final after = tester.getTopLeft(find.byType(HowItsBuiltSection)).dy;
      expect(after, lessThan(before));
      expect(after, lessThan(900 / 2));
    });

    testWidgets('an unknown slug shows the 404', (tester) async {
      await tester.pumpPortfolio(location: '/en/projects/nope');

      expect(find.text('Page not found'), findsOneWidget);
    });
  });

  group('navigation from the home', () {
    Future<void> openFishar(WidgetTester tester) async {
      final card = find.widgetWithText(ProjectCard, 'Fishar');
      await tester.ensureVisible(card);
      await tester.pump();
      await tester.tap(card);
    }

    testWidgets('a card opens its detail and "volver" goes back', (
      tester,
    ) async {
      final router = await tester.pumpPortfolio();

      await openFishar(tester);
      await tester.pumpNavigation();
      expect(
        router.routeInformationProvider.value.uri.path,
        '/projects/fishar',
      );
      expect(find.byType(ProjectDetailPage), findsOneWidget);

      await tester.tap(find.text('← volver a proyectos'));
      await tester.pumpNavigation();
      expect(router.routeInformationProvider.value.uri.path, '/');
      expect(find.byType(ProjectDetailPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('with motion, the name and cover fly as Heroes', (
      tester,
    ) async {
      await tester.pumpPortfolio(reduceMotion: false);
      await tester.pump(const Duration(seconds: 2));

      await openFishar(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      // During the flight the big title is drawn scaled in the overlay.
      expect(
        find.descendant(
          of: find.byType(FittedBox),
          matching: find.text('Fishar'),
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(ProjectDetailPage), findsOneWidget);
    });

    testWidgets('with reduced motion there is no flight', (tester) async {
      await tester.pumpPortfolio();

      await openFishar(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(
        find.descendant(
          of: find.byType(FittedBox),
          matching: find.text('Fishar'),
        ),
        findsNothing,
      );
    });

    testWidgets('a focused card opens with Enter', (tester) async {
      final router = await tester.pumpPortfolio();
      final card = find.widgetWithText(ProjectCard, 'Laburito');
      await tester.ensureVisible(card);
      await tester.pump();

      Focus.of(
        tester.element(
          find
              .descendant(of: card, matching: find.byType(GestureDetector))
              .first,
        ),
      ).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpNavigation();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/projects/laburito',
      );
    });

    testWidgets('the language switch keeps the project', (tester) async {
      final router = await tester.pumpPortfolio(location: '/projects/fundido');

      await tester.tap(find.widgetWithText(TextButton, 'EN'));
      await tester.pumpNavigation();

      expect(
        router.routeInformationProvider.value.uri.path,
        '/en/projects/fundido',
      );
      expect(find.text('Technical decisions'), findsOneWidget);
    });
  });

  testWidgets('"Código" opens the GitHub link when there is one', (
    tester,
  ) async {
    // Not through the real content: no project has a GitHub link yet.
    final opener = RecordingLinkOpener();
    await tester.pumpPortfolio(
      location: '/projects/fishar',
      overrides: [linkOpenerProvider.overrideWithValue(opener)],
      projectsRepository: FakeProjectsRepository([
        fisharWithGithub,
      ]),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Código ↗'));

    expect(
      opener.opened.single,
      Uri.parse('https://github.com/example/fishar'),
    );
  });
}
