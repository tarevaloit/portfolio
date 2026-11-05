@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/di/repository_overrides.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/features/home/presentation/widgets/hero_section.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/pump_localized.dart';

// Regenerate on macOS with:
//   flutter test --tags golden --update-goldens
void main() {
  const fishar = Project(
    slug: 'fishar',
    order: 1,
    name: 'Fishar',
    monogram: 'Fi',
    color: 0xFF5EEAD4,
    category: 'App social · Byto Apps',
    badge: 'Beta · TestFlight',
    summary:
        'Red social de pesca para Android e iOS. Marcá spots en el mapa, '
        'compartí capturas y seguí a otros pescadores.',
    description: '',
    role: '',
    status: '',
    platforms: ['iOS', 'Android'],
    stack: ['Flutter', 'Firebase', 'Maps'],
    links: ProjectLinks(),
    architecture: ProjectArchitecture(
      feature: 'spots',
      presentation: LayerDetail(classes: [], description: ''),
      domain: LayerDetail(classes: [], description: ''),
      data: LayerDetail(classes: [], description: ''),
    ),
  );

  Widget framed(Widget child, double width, double height) => ColoredBox(
    color: AppColors.background,
    child: Center(
      child: SizedBox(width: width, height: height, child: child),
    ),
  );

  testWidgets('ProjectCard, wide', (tester) async {
    await tester.pumpLocalized(
      framed(const ProjectCard(project: fishar), 580, 440),
      size: const Size(640, 500),
      scrollable: false,
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/project_card_wide.png'),
    );
  });

  testWidgets('ProjectCard, compact', (tester) async {
    await tester.pumpLocalized(
      framed(const ProjectCard(project: fishar), 320, 440),
      size: const Size(360, 500),
      scrollable: false,
    );

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/project_card_compact.png'),
    );
  });

  for (final (name, size) in [
    ('expanded', const Size(1440, 720)),
    ('compact', const Size(360, 1100)),
  ]) {
    testWidgets('HeroSection, $name', (tester) async {
      await tester.pumpLocalized(
        PageContainer(child: HeroSection(onSeeProjects: () {})),
        size: size,
        // The real projects, so the phone shows the real screens.
        overrides: repositoryOverrides(contact: FakeContactRepository()),
      );
      await tester.settleImages();

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/hero_$name.png'),
      );
    });
  }
}
