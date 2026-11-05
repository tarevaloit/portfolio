@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';

import '../helpers/pump_app.dart';

// Regenerate on macOS with:
//   flutter test --tags golden --update-goldens
void main() {
  for (final (name, size) in [
    ('expanded', const Size(1440, 900)),
    ('compact', const Size(360, 1400)),
  ]) {
    testWidgets('Fishar detail, $name', (tester) async {
      await tester.pumpPortfolio(location: '/projects/fishar', size: size);
      await tester.settleImages();

      await expectLater(
        find.byType(ProjectDetailPage),
        matchesGoldenFile('goldens/detail_fishar_$name.png'),
      );
    });
  }
}
