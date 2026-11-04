import 'package:flutter_riverpod/flutter_riverpod.dart';

/// URL of this repo on GitHub, used by the badges to link each class to
/// its file. `null` until the content has it (then badges are not links).
///
/// Core cannot read the projects content, so `lib/app/di/` overrides it.
final sourceRepositoryUrlProvider = FutureProvider<Uri?>(
  (ref) async => null,
  name: 'sourceRepositoryUrlProvider',
);

/// Link to [path] on the default branch of [repository].
Uri sourceFileUrl(Uri repository, String path) {
  final base = repository.toString().replaceFirst(RegExp(r'/+$'), '');
  return Uri.parse('$base/blob/main/$path');
}
