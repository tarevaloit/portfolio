import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_showcase.dart';

import '../../helpers/pump_app.dart';

/// PLAN.md: the site must look right from 360 to 1440 px with no
/// horizontal scroll. Uses the real content, fonts and both languages.
void main() {
  const sizes = [
    Size(360, 800),
    Size(768, 1024),
    Size(1280, 800),
    Size(1440, 900),
  ];

  for (final locale in AppLocale.values) {
    for (final size in sizes) {
      testWidgets(
        'home at ${size.width.toInt()} px (${locale.name}) has no overflow',
        (tester) async {
          await tester.pumpPortfolio(location: locale.homePath, size: size);

          expect(tester.takeException(), isNull);
          expect(find.byType(ProjectCard), findsNWidgets(4));

          final page = tester.getRect(find.byType(HomePage));
          expect(page.width, size.width);

          // The only horizontal scrollable is the marquee, and the user
          // cannot drag it.
          final horizontal = tester
              .widgetList<Scrollable>(find.byType(Scrollable))
              .where((s) => s.axisDirection == AxisDirection.right)
              .toList();
          expect(horizontal, hasLength(1));
          expect(
            horizontal.single.physics,
            isA<NeverScrollableScrollPhysics>(),
          );

          // The hero title never breaks a word: the phone moves under the
          // copy when the column would get too narrow.
          final titleFinder = find.textContaining(
            locale == AppLocale.es ? 'Apps mobile y web' : 'Mobile and web',
          );
          final title = tester.getRect(titleFinder);
          final phone = tester.getRect(find.byType(ProjectsShowcase));
          expect(
            phone.left >= title.right || phone.top >= title.bottom,
            isTrue,
            reason: 'the phone overlaps the title',
          );
          expect(
            title.width,
            greaterThanOrEqualTo(_longestWordWidth(tester, titleFinder)),
            reason: 'a word of the hero title is wider than its column',
          );
        },
      );
    }
  }
}

/// Width of the longest word of the text found by [finder], at its style.
double _longestWordWidth(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(
    find.descendant(of: finder, matching: find.byType(RichText)),
  );
  var longest = 0.0;
  for (final word in paragraph.text.toPlainText().split(RegExp(r'\s+'))) {
    final painter = TextPainter(
      text: TextSpan(text: word, style: paragraph.text.style),
      textDirection: TextDirection.ltr,
      textScaler: paragraph.textScaler,
    )..layout();
    if (painter.width > longest) longest = painter.width;
    painter.dispose();
  }
  return longest;
}
