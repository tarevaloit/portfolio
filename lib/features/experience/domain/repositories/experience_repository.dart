import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';

/// Source of experience entries. Implemented in the data layer.
abstract interface class ExperienceRepository {
  /// Every entry, in no particular order.
  ///
  /// Throws a [ContentFailure] if the content cannot be loaded.
  Future<List<Experience>> getExperience(ContentLanguage language);
}
