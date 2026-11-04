import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';

/// Projects for the home grid, sorted by `order` and then by name.
class GetProjects {
  const GetProjects(this._repository);

  final ProjectsRepository _repository;

  Future<List<Project>> call(ContentLanguage language) async {
    final projects = await _repository.getProjects(language);
    return [...projects]..sort(
      (a, b) => a.order != b.order
          ? a.order.compareTo(b.order)
          : a.name.compareTo(b.name),
    );
  }
}
