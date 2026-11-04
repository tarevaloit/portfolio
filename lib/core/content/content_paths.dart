import 'package:portfolio/core/domain/domain.dart';

/// Layout of `assets/content/`.
///
/// ```text
/// assets/content/
///   <collection>/<id>.json        data shared by every language
///   <lang>/<collection>/<id>.json texts for one language
///   <lang>/<collection>/<id>.md   optional long body (Markdown)
///   <name>.json                   shared single file (experience, contact)
///   <lang>/<name>.json            texts for a shared single file
/// ```
class ContentPaths {
  const ContentPaths({this.root = 'assets/content'});

  final String root;

  String sharedDirectory(String collection) => '$root/$collection/';

  String localizedDirectory(String collection, ContentLanguage language) =>
      '$root/${language.code}/$collection/';

  String sharedFile(String name) => '$root/$name';

  String localizedFile(String name, ContentLanguage language) =>
      '$root/${language.code}/$name';
}
