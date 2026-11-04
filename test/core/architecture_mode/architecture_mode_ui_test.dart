import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_toggle.dart';
import 'package:portfolio/core/architecture_mode/layer_badge.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/demos/piggy_avatar.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

import '../../helpers/pump_app.dart';
import '../../helpers/pump_localized.dart';

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

    expect(find.text('HeroSection'), findsOneWidget);
    expect(find.text('ProjectsSection'), findsOneWidget);
    expect(find.text('ExperienceSection'), findsOneWidget);
    expect(find.text('ContactSection'), findsOneWidget);
    expect(find.text('ProjectCard'), findsNWidgets(4));
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
    expect(find.text('ProjectDetailPage'), findsOneWidget);
    expect(find.text('FundidoDemo'), findsOneWidget);
    expect(find.text('maqueta'), findsOneWidget);
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

  group('PiggyAvatar', () {
    testWidgets('hops when a reply arrives and wiggles while talking', (
      tester,
    ) async {
      Widget piggy({bool talking = false, int celebrations = 0}) => Center(
        child: PiggyAvatar(talking: talking, celebrations: celebrations),
      );
      await tester.pumpLocalized(
        piggy(),
        scrollable: false,
        reduceMotion: false,
      );
      final rest = tester.getRect(find.byType(CustomPaint).last);

      await tester.pumpLocalized(
        piggy(celebrations: 1),
        scrollable: false,
        reduceMotion: false,
      );
      await tester.pump(const Duration(milliseconds: 260));
      final hopping = tester.getRect(find.byType(CustomPaint).last);
      expect(hopping.top, lessThan(rest.top));

      await tester.pumpLocalized(
        piggy(talking: true, celebrations: 1),
        scrollable: false,
        reduceMotion: false,
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('stays still with reduced motion', (tester) async {
      await tester.pumpLocalized(
        const Center(child: PiggyAvatar(talking: true)),
        scrollable: false,
      );
      await tester.pump();

      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  });
}
