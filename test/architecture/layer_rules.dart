import 'dart:io';

/// Clean-architecture import rules, checked by `layer_rules_test.dart`.
///
/// - `domain/` is pure Dart: only core `dart:` libraries, a few annotation
///   packages and other `domain/` files.
/// - `data/` implements domain contracts and never imports `presentation/`.
/// - `presentation/` never imports `data/`; it only knows `domain/`.
enum Layer { domain, data, presentation }

const String packageName = 'portfolio';

/// `dart:` libraries allowed in `domain/`.
const Set<String> allowedDomainDartLibraries = {
  'dart:async',
  'dart:collection',
  'dart:convert',
  'dart:core',
  'dart:math',
  'dart:typed_data',
};

/// External packages allowed in `domain/` (pure Dart, no I/O).
const Set<String> allowedDomainPackages = {
  'collection',
  'equatable',
  'freezed_annotation',
  'meta',
};

final RegExp _layerPattern = RegExp(
  '^lib/features/[^/]+/(domain|data|presentation)/',
);

final RegExp _directivePattern = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// Layer of a project-relative path such as
/// `lib/features/projects/domain/project.dart`, or `null` if it is not
/// inside a feature layer.
Layer? layerOf(String path) {
  final match = _layerPattern.firstMatch(path);
  if (match == null) return null;
  return Layer.values.byName(match.group(1)!);
}

/// URIs of every `import` and `export` directive in [source].
List<String> directivesOf(String source) => [
  for (final match in _directivePattern.allMatches(source)) match.group(1)!,
];

/// Returns a description for every directive in [imports] that breaks the
/// rules for [filePath] (project-relative, `lib/...`).
List<String> violationsFor(String filePath, List<String> imports) {
  final layer = layerOf(filePath);
  if (layer == null) return const [];

  final violations = <String>[];
  for (final uri in imports) {
    final reason = _check(layer, filePath, uri);
    if (reason != null) violations.add('$filePath → $uri: $reason');
  }
  return violations;
}

String? _check(Layer layer, String filePath, String uri) {
  final target = _resolveInternal(filePath, uri);

  switch (layer) {
    case Layer.domain:
      if (uri.startsWith('dart:')) {
        return allowedDomainDartLibraries.contains(uri)
            ? null
            : 'domain must be pure Dart';
      }
      if (target != null) {
        return layerOf(target) == Layer.domain
            ? null
            : 'domain can only import other domain files';
      }
      final package = _packageOf(uri);
      if (package != null && !allowedDomainPackages.contains(package)) {
        return 'domain must be pure Dart (package:$package is not allowed)';
      }
      return null;
    case Layer.data:
      if (target != null && layerOf(target) == Layer.presentation) {
        return 'data must not import presentation';
      }
      return null;
    case Layer.presentation:
      if (target != null && layerOf(target) == Layer.data) {
        return 'presentation must not import data';
      }
      return null;
  }
}

/// Resolves an import to a project-relative path when it points inside
/// this package; returns `null` for `dart:` and third-party packages.
String? _resolveInternal(String filePath, String uri) {
  const ownPrefix = 'package:$packageName/';
  if (uri.startsWith(ownPrefix)) {
    return 'lib/${uri.substring(ownPrefix.length)}';
  }
  if (uri.contains(':')) return null;
  return Uri.parse(filePath).resolve(uri).path;
}

String? _packageOf(String uri) {
  if (!uri.startsWith('package:')) return null;
  return uri.substring('package:'.length).split('/').first;
}

/// Scans every Dart file under `lib/features` and returns all violations.
List<String> scanFeatures({String root = 'lib/features'}) {
  final directory = Directory(root);
  if (!directory.existsSync()) return const [];

  final violations = <String>[];
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll(r'\', '/');
    violations.addAll(
      violationsFor(path, directivesOf(entity.readAsStringSync())),
    );
  }
  return violations;
}
