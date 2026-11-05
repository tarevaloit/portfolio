import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_toggle.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/experience/presentation/widgets/experience_section.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_section.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  double scrollOffset(WidgetTester tester) => tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byType(HomePage),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position
      .pixels;

  testWidgets('nav links scroll their section to the top', (tester) async {
    await tester.pumpPortfolio();
    expect(scrollOffset(tester), 0);

    await tester.tap(find.widgetWithText(TextButton, 'Experiencia'));
    await tester.pumpNavigation();

    expect(scrollOffset(tester), greaterThan(0));
    expect(tester.getTopLeft(find.byType(ExperienceSection)).dy, 0);
  });

  testWidgets('"Ver proyectos" scrolls to the projects', (tester) async {
    await tester.pumpPortfolio();

    await tester.tap(find.text('Ver proyectos →'));
    await tester.pumpNavigation();

    expect(tester.getTopLeft(find.byType(ProjectsSection)).dy, 0);
  });

  testWidgets('the architecture mode toggle flips its state', (tester) async {
    await tester.pumpPortfolio();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomePage)),
    );
    expect(container.read(architectureModeProvider), isFalse);

    await tester.tap(find.byType(ArchitectureModeToggle).first);
    await tester.pump();

    expect(container.read(architectureModeProvider), isTrue);
  });

  testWidgets('"Descargar CV" is disabled while there is no CV', (
    tester,
  ) async {
    await tester.pumpPortfolio(contactRepository: FakeContactRepository());
    await tester.pump();

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Descargar CV'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('"Descargar CV" opens the CV of the language', (tester) async {
    final opener = RecordingLinkOpener();
    await tester.pumpPortfolio(
      location: '/en',
      contactRepository: FakeContactRepository(
        const ContactInfo(cvAssetPath: 'assets/cv/cv_en.pdf'),
      ),
      overrides: [linkOpenerProvider.overrideWithValue(opener)],
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Download CV'));

    expect(opener.opened.single.path, endsWith('/assets/assets/cv/cv_en.pdf'));
  });

  testWidgets('compact nav keeps the logo, language and toggle only', (
    tester,
  ) async {
    await tester.pumpPortfolio(size: const Size(360, 800));

    expect(find.widgetWithText(TextButton, 'Proyectos'), findsNothing);
    expect(find.widgetWithText(TextButton, 'EN'), findsOneWidget);
    expect(find.byType(ArchitectureModeToggle), findsOneWidget);
  });

  testWidgets('with motion on, animations settle and leave no timers', (
    tester,
  ) async {
    await tester.pumpPortfolio(reduceMotion: false);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Ver proyectos →'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
