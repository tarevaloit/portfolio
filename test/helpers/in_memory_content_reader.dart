import 'dart:convert';

import 'package:portfolio/core/content/content.dart';

/// [ContentAssetReader] over an in-memory map of `path → contents`.
///
/// Values that are not strings are JSON-encoded, so tests can pass maps.
class InMemoryContentReader implements ContentAssetReader {
  InMemoryContentReader(Map<String, Object> files)
    : _files = {
        for (final MapEntry(:key, :value) in files.entries)
          key: value is String ? value : jsonEncode(value),
      };

  final Map<String, String> _files;

  /// Paths read so far, to assert on caching.
  final List<String> reads = [];

  @override
  Future<List<String>> list(String directory) async {
    return _files.keys
        .where(
          (path) =>
              path.startsWith(directory) &&
              !path.substring(directory.length).contains('/'),
        )
        .toList()
      ..sort();
  }

  @override
  Future<String?> read(String path) async {
    reads.add(path);
    return _files[path];
  }
}
