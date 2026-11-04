import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/contact/data/dtos/contact_dto.dart';

/// Reads `assets/content/contact.json`.
class ContactLocalDataSource {
  const ContactLocalDataSource(
    this._reader, {
    this.paths = const ContentPaths(),
  });

  static const String fileName = 'contact.json';

  final ContentAssetReader _reader;
  final ContentPaths paths;

  /// Throws [ContentNotFound] if the file is missing.
  Future<ContactDto> contact() async {
    final path = paths.sharedFile(fileName);
    final source = await _reader.read(path);
    if (source == null) throw ContentNotFound('$path not found');
    return decodeContent(source, path, ContactDto.fromJson);
  }
}
