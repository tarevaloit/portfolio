import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/phone_frame.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_heroes.dart';

import '../../../helpers/pump_app.dart';

/// Every project detail, in both languages, from 360 to 1440 px: no
/// overflow, and the giant title never splits a word.
void main() {
  const sizes = [
    Size(360, 800),
    Size(768, 1024),
    Size(1280, 800),
    Size(1440, 900),
  ];
  const slugs = ['fishar', 'laburito', 'fundido', 'portfolio'];

  for (final locale in AppLocale.values) {
    for (final slug in slugs) {
      for (final size in sizes) {
        testWidgets(
          '$slug at ${size.width.toInt()} px (${locale.name})',
          (tester) async {
            await tester.pumpPortfolio(
              location: AppLocale.values
                  .firstWhere((l) => l == locale)
                  .path('/projects/$slug'),
              size: size,
            );

            expect(tester.takeException(), isNull);
            expect(find.byType(ProjectDetailPage), findsOneWidget);

            // The first one is the page title; "Este portfolio" also has
            // the mini home, with its own cards, inside the phone.
            final title = find
                .descendant(
                  of: find.byType(ProjectNameHero),
                  matching: find.byType(RichText),
                )
                .first;
            final paragraph = tester.renderObject<RenderParagraph>(title);
            final width = tester.getSize(title).width;
            for (final word in paragraph.text.toPlainText().split(' ')) {
              final painter = TextPainter(
                text: TextSpan(text: word, style: paragraph.text.style),
                textDirection: TextDirection.ltr,
                textScaler: paragraph.textScaler,
              )..layout();
              expect(
                painter.width,
                lessThanOrEqualTo(width + 0.5),
                reason: '"$word" does not fit the title column',
              );
              painter.dispose();
            }

            final phone = tester.getRect(find.byType(PhoneFrame).first);
            expect(phone.right, lessThanOrEqualTo(size.width));
          },
        );
      }
    }
  }
}
