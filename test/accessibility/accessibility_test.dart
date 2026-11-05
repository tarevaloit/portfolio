import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_section.dart';

import '../helpers/pump_app.dart';

/// WCAG 2.2 target size (minimum, AA): 24×24 CSS px.
const _wcagTargetSize = MinimumTapTargetGuideline(
  size: Size(24, 24),
  link: 'https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum',
);

void main() {
  group('keyboard', () {
    testWidgets('the first Tab shows the skip link, which jumps to the '
        'projects', (tester) async {
      await tester.pumpPortfolio();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final link = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(SkipLink),
          matching: find.byType(Opacity),
        ),
      );
      expect(link.opacity, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpNavigation();
      expect(tester.getTopLeft(find.byType(ProjectsSection)).dy, 0);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus!.context!;
      expect(
        find.ancestor(
          of: find.byElementPredicate((e) => e == focused),
          matching: find.byType(ProjectCard),
        ),
        findsOneWidget,
        reason: 'after skipping, Tab reaches the first project card',
      );
    });

    testWidgets('the skip link is hidden until focused', (tester) async {
      await tester.pumpPortfolio();

      final link = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(SkipLink),
          matching: find.byType(Opacity),
        ),
      );
      expect(link.opacity, 0);
    });
  });

  for (final (name, location) in [
    ('home', '/'),
    ('Laburito detail', '/projects/laburito'),
    ('Fundido detail', '/projects/fundido'),
    ('Fishar detail', '/en/projects/fishar'),
  ]) {
    group('guidelines on the $name', () {
      testWidgets('text contrast', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpPortfolio(location: location);
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        semantics.dispose();
      });

      testWidgets('tappable things are labelled', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpPortfolio(location: location);
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
      });

      testWidgets('targets are at least 24×24 (WCAG 2.2)', (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpPortfolio(location: location);
        await expectLater(tester, meetsGuideline(_wcagTargetSize));
        semantics.dispose();
      });

      testWidgets('reduced motion leaves nothing animating', (tester) async {
        await tester.pumpPortfolio(location: location);
        await tester.pump(const Duration(seconds: 2));

        expect(tester.binding.hasScheduledFrame, isFalse);
      });
    });
  }
}
