import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';

import '../../../helpers/project_fixtures.dart';

class _CountingRepository implements ProjectsRepository {
  _CountingRepository(this.projects);

  final List<Project> projects;
  int bySlugCalls = 0;

  @override
  Future<List<Project>> getProjects(ContentLanguage language) async => projects;

  @override
  Future<Project> getProjectBySlug(String slug, ContentLanguage language) {
    bySlugCalls++;
    return Future.error(ContentNotFound(slug));
  }
}

void main() {
  ProviderContainer containerWith(ProjectsRepository repository) {
    final container = ProviderContainer(
      overrides: [projectsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('projectsProvider returns the sorted projects', () async {
    final container = containerWith(
      _CountingRepository([
        buildProject(slug: 'b', order: 2),
        buildProject(slug: 'a'),
      ]),
    );

    final projects = await container.read(
      projectsProvider(ContentLanguage.es).future,
    );

    expect(projects.map((p) => p.slug), ['a', 'b']);
  });

  test('a missing project is an error and is not retried', () async {
    final repository = _CountingRepository([]);
    final container = containerWith(repository);
    const args = (slug: 'nope', language: ContentLanguage.es);

    await expectLater(
      container.read(projectBySlugProvider(args).future),
      throwsA(isA<ContentNotFound>()),
    );
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(repository.bySlugCalls, 1);
  });

  test('the repository must be provided by the composition root', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(projectsRepositoryProvider),
      throwsA(anything),
    );
  });
}
