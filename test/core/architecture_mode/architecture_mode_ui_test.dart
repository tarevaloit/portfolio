import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_toggle.dart';
import 'package:portfolio/core/architecture_mode/layer_badge.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

import '../../helpers/pump_app.dart';

/// A class name in a badge. With the repo URL in the content it reads
/// "Name ↗" (a link); before it loads, just "Name".
Finder badge(String name) => find.textContaining(RegExp('^$name( ↗)?\$'));

void main() {
  ProviderContainer containerOf(WidgetTester tester, Type page) =>
      ProviderScope.containerOf(tester.element(find.byType(page)));

  testWidgets('the toggle is announced as a toggled switch', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpPortfolio();

    final toggle = find.byType(ArchitectureModeToggle);
    expect(
      tester.getSemantics(toggle),
      matchesSemantics(
        label: 'Modo arquitectura',
        hasToggledState: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
      ),
    );

    await tester.tap(toggle);
    await tester.pump();
    expect(
      tester.getSemantics(toggle).flagsCollection.isToggled.toBoolOrNull(),
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('on the home, every section gets its badge and cards show '
      'their layers', (tester) async {
    await tester.pumpPortfolio();
    containerOf(
      tester,
      HomePage,
    ).read(architectureModeProvider.notifier).toggle();
    await tester.pump();

    expect(badge('HeroSection'), findsOneWidget);
    expect(badge('ProjectsSection'), findsOneWidget);
    expect(badge('ExperienceSection'), findsOneWidget);
    expect(badge('ContactSection'), findsOneWidget);
    expect(badge('ProjectCard'), findsNWidgets(4));
    // The portfolio card lists the real classes from the content.
    expect(
      find.descendant(
        of: find.widgetWithText(ProjectCard, 'Este portfolio'),
        matching: find.textContaining('GetProjectBySlug'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the mode stays on when opening a project', (tester) async {
    final router = await tester.pumpPortfolio();
    containerOf(
      tester,
      HomePage,
    ).read(architectureModeProvider.notifier).toggle();
    router.go('/projects/fundido');
    await tester.pumpNavigation();

    expect(find.byType(ProjectDetailPage), findsOneWidget);
    expect(badge('ProjectDetailPage'), findsOneWidget);
    // Real screenshots, so not marked as a mock.
    expect(badge('MediaCarousel'), findsOneWidget);
    expect(find.text('maqueta'), findsNothing);
  });

  for (final size in const [Size(360, 800), Size(1440, 900)]) {
    testWidgets('mode on at ${size.width.toInt()} px: no overflow', (
      tester,
    ) async {
      final router = await tester.pumpPortfolio(size: size);
      containerOf(
        tester,
        HomePage,
      ).read(architectureModeProvider.notifier).toggle();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byType(LayerBadge), findsWidgets);

      router.go('/projects/portfolio');
      await tester.pumpNavigation();
      expect(tester.takeException(), isNull);
    });
  }
}
