import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/domain/repositories/experience_repository.dart';

/// Experience timeline sorted by `order`.
class GetExperience {
  const GetExperience(this._repository);

  final ExperienceRepository _repository;

  Future<List<Experience>> call(ContentLanguage language) async {
    final entries = await _repository.getExperience(language);
    return [...entries]..sort((a, b) => a.order.compareTo(b.order));
  }
}
