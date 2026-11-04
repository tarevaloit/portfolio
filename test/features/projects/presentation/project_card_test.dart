import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

import '../../../helpers/project_fixtures.dart';
import '../../../helpers/pump_localized.dart';

void main() {
  final project = buildProject(slug: 'fishar', name: 'Fishar');

  Widget card() => SizedBox(
    width: 560,
    height: 460,
    child: ProjectCard(project: project, onTap: () {}),
  );

  testWidgets('shows monogram, badge, name, category, summary and stack', (
    tester,
  ) async {
    await tester.pumpLocalized(card());

    expect(find.text('De'), findsOneWidget);
    expect(find.text('Badge'), findsOneWidget);
    expect(find.text('Fishar'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.widgetWithText(TagChip, 'Flutter'), findsOneWidget);
  });

  Future<double> liftOnHover(WidgetTester tester) async {
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(ProjectCard)));
    await tester.pump(const Duration(milliseconds: 300));

    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(ProjectCard),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return container.transform!.getTranslation().y;
  }

  testWidgets('lifts on hover', (tester) async {
    await tester.pumpLocalized(card(), reduceMotion: false);

    expect(await liftOnHover(tester), -6);
  });

  testWidgets('does not move on hover with reduced motion', (tester) async {
    await tester.pumpLocalized(card());

    expect(await liftOnHover(tester), 0);
  });
}
