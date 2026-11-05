import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/data/datasources/about_local_data_source.dart';
import 'package:portfolio/features/about/domain/entities/about_info.dart';
import 'package:portfolio/features/about/domain/repositories/about_repository.dart';

/// [AboutRepository] over the local content files, falling back to the
/// Spanish texts when a translation is missing.
class AboutRepositoryImpl implements AboutRepository {
  AboutRepositoryImpl(this._source);

  final AboutLocalDataSource _source;

  @override
  Future<AboutInfo> getAboutInfo(ContentLanguage language) async {
    final shared = await _source.shared();
    final texts =
        await _source.texts(language) ??
        await _source.texts(ContentLanguage.fallback);
    if (texts == null) {
      throw const InvalidContent(
        AboutLocalDataSource.fileName,
        'no texts in any language',
      );
    }
    return AboutInfo(
      photo: shared.photo,
      paragraphs: List.unmodifiable(texts.paragraphs),
      facts: List.unmodifiable([
        for (final fact in texts.facts)
          AboutFact(label: fact.label, value: fact.value),
      ]),
    );
  }
}
