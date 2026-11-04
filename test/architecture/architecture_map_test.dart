import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/architecture_mode/architecture_map.dart';
import 'package:portfolio/core/architecture_mode/layer_ref.dart';

/// The architecture mode shows real class names and links to their files.
/// This keeps every badge in sync with the code.
void main() {
  final refs = {
    for (final chain in ArchitectureMap.all) ...chain,
  };

  test('no chain is empty', () {
    for (final chain in ArchitectureMap.all) {
      expect(chain, isNotEmpty);
    }
  });

  for (final ref in refs) {
    test('${ref.name} is declared in ${ref.path}', () {
      final file = File(ref.path);
      expect(file.existsSync(), isTrue, reason: '${ref.path} does not exist');

      final declared = RegExp(
        '(class|typedef|enum|mixin|extension)\\s+${ref.name}\\b'
        '|\\b${ref.name}\\s*=',
      ).hasMatch(file.readAsStringSync());
      expect(declared, isTrue, reason: '${ref.name} not found in ${ref.path}');
    });

    test('${ref.name} is tagged with the layer of its folder', () {
      final expected = ref.path.contains('/domain/')
          ? ArchitectureLayer.domain
          : ref.path.contains('/data/')
          ? ArchitectureLayer.data
          : ArchitectureLayer.presentation;
      expect(ref.layer, expected);
    });
  }
}
