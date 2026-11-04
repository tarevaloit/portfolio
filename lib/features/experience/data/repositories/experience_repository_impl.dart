import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/experience/data/datasources/experience_local_data_source.dart';
import 'package:portfolio/features/experience/data/dtos/experience_dto.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/domain/repositories/experience_repository.dart';

/// [ExperienceRepository] over the local content files.
///
/// Each entry falls back to the Spanish texts when it is not translated.
class ExperienceRepositoryImpl implements ExperienceRepository {
  ExperienceRepositoryImpl(this._source);

  final ExperienceLocalDataSource _source;

  @override
  Future<List<Experience>> getExperience(ContentLanguage language) async {
    final shared = await _source.shared();
    final texts = await _source.texts(language);
    final fallback = language == ContentLanguage.fallback
        ? texts
        : await _source.texts(ContentLanguage.fallback);

    return [
      for (final entry in shared.entries)
        _toEntity(entry, _textsFor(entry.id, language, texts, fallback)),
    ];
  }

  ExperienceTextsDto _textsFor(
    String id,
    ContentLanguage language,
    ExperienceTextsFileDto? texts,
    ExperienceTextsFileDto? fallback,
  ) {
    final found = texts?.entries[id] ?? fallback?.entries[id];
    if (found != null) return found;
    throw InvalidContent(
      ExperienceLocalDataSource.fileName,
      'no texts for "$id" in "${language.code}" nor in '
      '"${ContentLanguage.fallback.code}"',
    );
  }
}

Experience _toEntity(ExperienceDto entry, ExperienceTextsDto texts) {
  return Experience(
    id: entry.id,
    order: entry.order,
    company: entry.company,
    role: texts.role,
    highlights: List.unmodifiable(texts.highlights),
    startYear: entry.startYear,
    endYear: entry.endYear,
  );
}
