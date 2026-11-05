import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';

/// A single project for its detail page (`/projects/:slug`).
class GetProjectBySlug {
  const GetProjectBySlug(this._repository);

  final ProjectsRepository _repository;

  /// Slugs come from the URL, so they are trimmed and lowercased first.
  Future<Project> call(String slug, ContentLanguage language) {
    final normalized = slug.trim().toLowerCase();
    if (normalized.isEmpty) {
      throw const ContentNotFound('Project slug is empty');
    }
    return _repository.getProjectBySlug(normalized, language);
  }
}
