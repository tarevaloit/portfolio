import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';
import 'package:portfolio/features/projects/domain/usecases/get_project_by_slug.dart';
import 'package:portfolio/features/projects/domain/usecases/get_projects.dart';

import '../../../helpers/project_fixtures.dart';

class FakeProjectsRepository implements ProjectsRepository {
  FakeProjectsRepository(this.projects);

  final List<Project> projects;
  final List<(String, ContentLanguage)> slugRequests = [];
  ContentLanguage? lastLanguage;

  @override
  Future<List<Project>> getProjects(ContentLanguage language) async {
    lastLanguage = language;
    return projects;
  }

  @override
  Future<Project> getProjectBySlug(String slug, ContentLanguage language) {
    slugRequests.add((slug, language));
    return Future.value(projects.firstWhere((p) => p.slug == slug));
  }
}

void main() {
  group('GetProjects', () {
    test('sorts by order and then by name', () async {
      final repository = FakeProjectsRepository([
        buildProject(slug: 'c', order: 2, name: 'Zeta'),
        buildProject(slug: 'b', order: 2, name: 'Alfa'),
        buildProject(slug: 'a', name: 'Omega'),
      ]);

      final projects = await GetProjects(repository)(ContentLanguage.es);

      expect(projects.map((p) => p.slug), ['a', 'b', 'c']);
    });

    test('asks the repository for the requested language', () async {
      final repository = FakeProjectsRepository([]);

      await GetProjects(repository)(ContentLanguage.en);

      expect(repository.lastLanguage, ContentLanguage.en);
    });

    test('does not mutate the list returned by the repository', () async {
      final original = [
        buildProject(slug: 'b', order: 2),
        buildProject(slug: 'a'),
      ];
      final repository = FakeProjectsRepository(List.unmodifiable(original));

      await GetProjects(repository)(ContentLanguage.es);

      expect(repository.projects.map((p) => p.slug), ['b', 'a']);
    });
  });

  group('GetProjectBySlug', () {
    test('normalizes the slug from the URL', () async {
      final repository = FakeProjectsRepository([buildProject(slug: 'fishar')]);

      final project = await GetProjectBySlug(repository)(
        '  Fishar ',
        ContentLanguage.en,
      );

      expect(project.slug, 'fishar');
      expect(repository.slugRequests.single, ('fishar', ContentLanguage.en));
    });

    test('an empty slug is ContentNotFound', () {
      final repository = FakeProjectsRepository([]);

      expect(
        () => GetProjectBySlug(repository)('  ', ContentLanguage.es),
        throwsA(isA<ContentNotFound>()),
      );
      expect(repository.slugRequests, isEmpty);
    });
  });
}
