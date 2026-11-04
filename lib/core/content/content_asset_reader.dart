import 'package:flutter/services.dart';

/// Read access to the content files in `assets/content/`.
///
/// Data sources depend on this interface so they can be tested with an
/// in-memory implementation instead of the real asset bundle.
abstract interface class ContentAssetReader {
  /// Asset paths directly inside [directory] (not recursive), sorted.
  /// [directory] must end with `/`.
  Future<List<String>> list(String directory);

  /// Contents of the asset at [path], or `null` if it does not exist.
  Future<String?> read(String path);
}

/// [ContentAssetReader] backed by a Flutter [AssetBundle].
///
/// Uses the [AssetManifest] to list files, so new content files are picked
/// up without code changes as long as their folder is declared in
/// `pubspec.yaml`.
class BundleContentAssetReader implements ContentAssetReader {
  BundleContentAssetReader(this._bundle);

  final AssetBundle _bundle;
  Future<Set<String>>? _assets;

  Future<Set<String>> _loadAssets() {
    return _assets ??= AssetManifest.loadFromAssetBundle(
      _bundle,
    ).then((manifest) => manifest.listAssets().toSet());
  }

  @override
  Future<List<String>> list(String directory) async {
    assert(directory.endsWith('/'), 'directory must end with "/"');
    final assets = await _loadAssets();
    return assets
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
    final assets = await _loadAssets();
    if (!assets.contains(path)) return null;
    return _bundle.loadString(path, cache: false);
  }
}
