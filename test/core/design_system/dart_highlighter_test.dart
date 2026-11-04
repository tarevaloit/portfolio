import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/design_system/code/dart_highlighter.dart';

void main() {
  List<(CodeTokenKind, String)> nonPlain(String code) =>
      DartHighlighter.tokenize(
        code,
      ).where((t) => t.$1 != CodeTokenKind.plain).toList();

  test('tokens rebuild the original code exactly', () {
    const code = '''
// domain/usecases/get_nearby_spots.dart
class GetNearbySpots {
  final SpotsRepository _repo;
  Future<List<Spot>> call(double radiusKm = 10) => _repo.nearby('x', 2.5);
}
''';
    final rebuilt = DartHighlighter.tokenize(code).map((t) => t.$2).join();
    expect(rebuilt, code);
  });

  test('classifies keywords, types, numbers, strings and comments', () {
    expect(nonPlain("final Spot s = load('a b', 10); // done"), [
      (CodeTokenKind.keyword, 'final'),
      (CodeTokenKind.type, 'Spot'),
      (CodeTokenKind.string, "'a b'"),
      (CodeTokenKind.number, '10'),
      (CodeTokenKind.comment, '// done'),
    ]);
  });

  test('keywords inside identifiers, strings or comments are not keywords', () {
    expect(nonPlain('classic'), isEmpty);
    expect(nonPlain('"final class"'), [
      (CodeTokenKind.string, '"final class"'),
    ]);
    expect(nonPlain('/* return 1 */'), [
      (CodeTokenKind.comment, '/* return 1 */'),
    ]);
  });

  test('escaped quotes stay inside the string', () {
    expect(nonPlain(r"'it\'s'"), [(CodeTokenKind.string, r"'it\'s'")]);
  });
}
