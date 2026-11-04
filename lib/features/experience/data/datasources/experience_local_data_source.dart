import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/experience/data/dtos/experience_dto.dart';

/// Reads `experience.json` (shared) and `<lang>/experience.json` (texts).
class ExperienceLocalDataSource {
  const ExperienceLocalDataSource(
    this._reader, {
    this.paths = const ContentPaths(),
  });

  static const String fileName = 'experience.json';

  final ContentAssetReader _reader;
  final ContentPaths paths;

  /// Throws [ContentNotFound] if the shared file is missing.
  Future<ExperienceFileDto> shared() async {
    final path = paths.sharedFile(fileName);
    final source = await _reader.read(path);
    if (source == null) throw ContentNotFound('$path not found');
    return decodeContent(source, path, ExperienceFileDto.fromJson);
  }

  /// Texts in [language], or `null` if the file does not exist.
  Future<ExperienceTextsFileDto?> texts(ContentLanguage language) async {
    final path = paths.localizedFile(fileName, language);
    final source = await _reader.read(path);
    if (source == null) return null;
    return decodeContent(source, path, ExperienceTextsFileDto.fromJson);
  }
}
