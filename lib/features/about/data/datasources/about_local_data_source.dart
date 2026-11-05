import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/data/dtos/about_dto.dart';

/// Reads `about.json` (shared) and `<lang>/about.json` (texts).
class AboutLocalDataSource {
  const AboutLocalDataSource(
    this._reader, {
    this.paths = const ContentPaths(),
  });

  static const String fileName = 'about.json';

  final ContentAssetReader _reader;
  final ContentPaths paths;

  /// Throws [ContentNotFound] if the shared file is missing.
  Future<AboutDto> shared() async {
    final path = paths.sharedFile(fileName);
    final source = await _reader.read(path);
    if (source == null) throw ContentNotFound('$path not found');
    return decodeContent(source, path, AboutDto.fromJson);
  }

  /// Texts in [language], or `null` if not translated.
  Future<AboutTextsDto?> texts(ContentLanguage language) async {
    final path = paths.localizedFile(fileName, language);
    final source = await _reader.read(path);
    if (source == null) return null;
    return decodeContent(source, path, AboutTextsDto.fromJson);
  }
}
