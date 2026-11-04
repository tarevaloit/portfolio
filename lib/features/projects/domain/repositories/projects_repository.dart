import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

/// Source of projects. Implemented in the data layer.
abstract interface class ProjectsRepository {
  /// Every project, in no particular order.
  ///
  /// Throws a [ContentFailure] if the content cannot be loaded.
  Future<List<Project>> getProjects(ContentLanguage language);

  /// The project with [slug].
  ///
  /// Throws [ContentNotFound] if there is none.
  Future<Project> getProjectBySlug(String slug, ContentLanguage language);
}
