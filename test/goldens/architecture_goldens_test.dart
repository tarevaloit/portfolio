@Tags(['golden'])
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

import '../helpers/pump_app.dart';

// Regenerate on macOS with:
//   flutter test --tags golden --update-goldens
void main() {
  Future<void> turnOn(WidgetTester tester, Type page) async {
    ProviderScope.containerOf(
      tester.element(find.byType(page)),
    ).read(architectureModeProvider.notifier).toggle();
    await tester.pump();
  }

  testWidgets('home hero with architecture mode', (tester) async {
    await tester.pumpPortfolio();
    await turnOn(tester, HomePage);

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/architecture_home.png'),
    );
  });

  testWidgets('project card with architecture mode', (tester) async {
    await tester.pumpPortfolio();
    await turnOn(tester, HomePage);
    final card = find.widgetWithText(ProjectCard, 'Este portfolio');
    await tester.ensureVisible(card);
    await tester.pump();

    await expectLater(
      card,
      matchesGoldenFile('goldens/architecture_card.png'),
    );
  });

  testWidgets('detail with architecture mode', (tester) async {
    await tester.pumpPortfolio(location: '/projects/fundido');
    await turnOn(tester, ProjectDetailPage);

    await expectLater(
      find.byType(ProjectDetailPage),
      matchesGoldenFile('goldens/architecture_detail.png'),
    );
  });
}
