import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:portfolio/core/content/content_retry.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';
import 'package:portfolio/features/projects/domain/usecases/get_project_by_slug.dart';
import 'package:portfolio/features/projects/domain/usecases/get_projects.dart';

/// Repository contract. Presentation does not know the implementation:
/// `lib/app/di/` overrides this provider with the data layer one.
final projectsRepositoryProvider = Provider<ProjectsRepository>(
  (ref) => throw UnimplementedError(
    'projectsRepositoryProvider must be overridden in lib/app/di.',
  ),
  name: 'projectsRepositoryProvider',
);

final getProjectsProvider = Provider<GetProjects>(
  (ref) => GetProjects(ref.watch(projectsRepositoryProvider)),
  name: 'getProjectsProvider',
);

final getProjectBySlugProvider = Provider<GetProjectBySlug>(
  (ref) => GetProjectBySlug(ref.watch(projectsRepositoryProvider)),
  name: 'getProjectBySlugProvider',
);

/// Sorted projects for the home grid.
final FutureProviderFamily<List<Project>, ContentLanguage> projectsProvider =
    FutureProvider.family<List<Project>, ContentLanguage>(
      (ref, language) => ref.watch(getProjectsProvider)(language),
      retry: contentRetry,
      name: 'projectsProvider',
    );

/// Arguments of [projectBySlugProvider].
typedef ProjectBySlugArgs = ({String slug, ContentLanguage language});

/// A single project for its detail page.
final FutureProviderFamily<Project, ProjectBySlugArgs> projectBySlugProvider =
    FutureProvider.family<Project, ProjectBySlugArgs>(
      (ref, args) =>
          ref.watch(getProjectBySlugProvider)(args.slug, args.language),
      retry: contentRetry,
      name: 'projectBySlugProvider',
    );
