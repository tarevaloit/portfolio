import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/home/presentation/widgets/ai_section.dart';
import 'package:portfolio/features/projects/presentation/pages/project_detail_page.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  testWidgets('shows the AI work and links the portfolio repo', (
    tester,
  ) async {
    final opener = RecordingLinkOpener();
    await tester.pumpPortfolio(
      overrides: [linkOpenerProvider.overrideWithValue(opener)],
    );
    await tester.ensureVisible(find.byType(AiSection));
    await tester.pump();

    expect(find.text('IA que llega a producción'), findsOneWidget);
    expect(find.text("What's New generado con IA"), findsOneWidget);
    expect(find.text('Gastos por chat'), findsOneWidget);
    expect(find.text('Desarrollo con agentes'), findsOneWidget);

    await tester.tap(find.text('Ver el repo ↗'));
    expect(
      opener.opened.single,
      Uri.parse('https://github.com/tarevaloit/portfolio'),
    );
  });

  testWidgets('"Ver proyecto" opens Fundido', (tester) async {
    await tester.pumpPortfolio();
    await tester.ensureVisible(find.text('Ver proyecto →'));
    await tester.pump();

    await tester.tap(find.text('Ver proyecto →'));
    await tester.pumpNavigation();

    expect(find.byType(ProjectDetailPage), findsOneWidget);
    expect(find.text('Fundido'), findsWidgets);
  });
}
