import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_showcase.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  Finder chip(String name) => find.descendant(
    of: find.byType(ProjectsShowcase),
    matching: find.bySemanticsLabel(name),
  );

  testWidgets('shows the apps with screenshots and opens the one picked', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpPortfolio();

    // Fishar, Laburito and Fundido have screens; the portfolio does not.
    expect(chip('Fishar'), findsOneWidget);
    expect(chip('Laburito'), findsOneWidget);
    expect(chip('Fundido'), findsOneWidget);
    expect(find.text('Ver Fishar →'), findsOneWidget);

    await tester.tap(chip('Laburito'));
    await tester.pump();
    expect(find.text('Ver Laburito →'), findsOneWidget);
    expect(find.bySemanticsLabel('Una pantalla de Laburito'), findsOneWidget);

    await tester.tap(find.text('Ver Laburito →'));
    await tester.pumpNavigation();
    expect(find.byType(ProjectDetailPage), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('with motion it rotates on its own', (tester) async {
    await tester.pumpPortfolio(reduceMotion: false);
    expect(find.text('Ver Fishar →'), findsOneWidget);

    await tester.pump(ProjectsShowcase.interval);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Ver Laburito →'), findsOneWidget);
  });

  testWidgets('with reduced motion it stays put', (tester) async {
    await tester.pumpPortfolio();

    await tester.pump(ProjectsShowcase.interval * 2);
    expect(find.text('Ver Fishar →'), findsOneWidget);
  });
}
