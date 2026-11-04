import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_section.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/project_fixtures.dart';
import '../../../helpers/pump_localized.dart';

void main() {
  final projects = [
    buildProject(slug: 'fishar', name: 'Fishar'),
    buildProject(slug: 'laburito', order: 2, name: 'Laburito'),
    buildProject(slug: 'fundido', order: 3, name: 'Fundido'),
  ];

  testWidgets('shows one card per project and the zero-padded count', (
    tester,
  ) async {
    await tester.pumpLocalized(
      const ProjectsSection(),
      overrides: [
        projectsRepositoryProvider.overrideWithValue(
          FakeProjectsRepository(projects),
        ),
      ],
    );

    expect(find.byType(ProjectCard), findsNWidgets(3));
    expect(find.text('Proyectos (03)'), findsOneWidget);
    expect(
      find.text('Tip: activá el modo arquitectura arriba a la derecha.'),
      findsOneWidget,
    );
  });

  testWidgets('uses two columns from 768 px and one below', (tester) async {
    final overrides = [
      projectsRepositoryProvider.overrideWithValue(
        FakeProjectsRepository(projects),
      ),
    ];

    await tester.pumpLocalized(
      const ProjectsSection(),
      size: const Size(768, 1024),
      overrides: overrides,
    );
    final first = tester.getTopLeft(find.byType(ProjectCard).at(0));
    final second = tester.getTopLeft(find.byType(ProjectCard).at(1));
    expect(first.dy, second.dy);

    await tester.pumpLocalized(
      const ProjectsSection(),
      size: const Size(360, 800),
      overrides: overrides,
    );
    final firstCompact = tester.getTopLeft(find.byType(ProjectCard).at(0));
    final secondCompact = tester.getTopLeft(find.byType(ProjectCard).at(1));
    expect(firstCompact.dx, secondCompact.dx);
    expect(secondCompact.dy, greaterThan(firstCompact.dy));
  });

  testWidgets('shows skeletons while loading', (tester) async {
    await tester.pumpLocalized(
      const ProjectsSection(),
      overrides: [
        projectsRepositoryProvider.overrideWithValue(
          FakeProjectsRepository.loading(),
        ),
      ],
    );

    expect(find.byType(SkeletonBox), findsNWidgets(4));
    expect(find.text('Proyectos'), findsOneWidget);
  });

  testWidgets('shows an error message when content fails', (tester) async {
    await tester.pumpLocalized(
      const ProjectsSection(),
      locale: AppLocale.en,
      overrides: [
        projectsRepositoryProvider.overrideWithValue(
          FakeProjectsRepository.failing(),
        ),
      ],
    );
    await tester.pump();

    expect(find.text('Projects could not be loaded.'), findsOneWidget);
  });
}
