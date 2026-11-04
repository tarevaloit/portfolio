import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/data/dtos/project_dto.dart';
import 'package:portfolio/features/projects/data/dtos/project_texts_dto.dart';

/// Reads project files from `assets/content/`.
///
/// ```text
/// projects/<slug>.json          ProjectDto (shared)
/// projects/<slug>.snippet       code sample (optional)
/// <lang>/projects/<slug>.json   ProjectTextsDto
/// <lang>/projects/<slug>.md     long body (optional)
/// ```
class ProjectsLocalDataSource {
  const ProjectsLocalDataSource(
    this._reader, {
    this.paths = const ContentPaths(),
  });

  static const String collection = 'projects';

  final ContentAssetReader _reader;
  final ContentPaths paths;

  /// Slugs of every project, taken from the shared JSON file names.
  Future<List<String>> slugs() async {
    final files = await _reader.list(paths.sharedDirectory(collection));
    return [
      for (final file in files)
        if (file.endsWith('.json'))
          file.substring(file.lastIndexOf('/') + 1, file.length - 5),
    ];
  }

  /// Shared data of [slug]. Throws [ContentNotFound] if the file is missing.
  Future<ProjectDto> shared(String slug) async {
    final path = '${paths.sharedDirectory(collection)}$slug.json';
    final source = await _reader.read(path);
    if (source == null) throw ContentNotFound('Project "$slug" not found');
    return decodeContent(source, path, ProjectDto.fromJson);
  }

  /// Texts of [slug] in [language], or `null` if not translated.
  Future<ProjectTextsDto?> texts(String slug, ContentLanguage language) async {
    final path = '${paths.localizedDirectory(collection, language)}$slug.json';
    final source = await _reader.read(path);
    if (source == null) return null;
    return decodeContent(source, path, ProjectTextsDto.fromJson);
  }

  /// Markdown body of [slug] in [language], or `null`.
  Future<String?> body(String slug, ContentLanguage language) {
    return _reader.read(
      '${paths.localizedDirectory(collection, language)}$slug.md',
    );
  }

  /// Code sample of [slug], or `null`.
  Future<String?> snippet(String slug) {
    return _reader.read('${paths.sharedDirectory(collection)}$slug.snippet');
  }
}
