import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';

void main() {
  group('decodeContent', () {
    String readName(Map<String, dynamic> json) => json['name'] as String;

    test('decodes a JSON object with the given fromJson', () {
      expect(decodeContent('{"name": "Fishar"}', 'a.json', readName), 'Fishar');
    });

    test('invalid JSON becomes InvalidContent naming the file', () {
      expect(
        () => decodeContent('{"name": ', 'broken.json', readName),
        throwsA(
          isA<InvalidContent>().having(
            (e) => e.source,
            'source',
            'broken.json',
          ),
        ),
      );
    });

    test('a top-level array becomes InvalidContent', () {
      expect(
        () => decodeContent('[]', 'list.json', readName),
        throwsA(isA<InvalidContent>()),
      );
    });
  });

  group('HexColorConverter', () {
    const converter = HexColorConverter();

    test('parses #RRGGBB as opaque ARGB', () {
      expect(converter.fromJson('#5EEAD4'), 0xFF5EEAD4);
      expect(converter.fromJson('#c6f432'), 0xFFC6F432);
    });

    test('parses #AARRGGBB as is', () {
      expect(converter.fromJson('#805EEAD4'), 0x805EEAD4);
    });

    test('rejects other formats', () {
      expect(() => converter.fromJson('5EEAD4'), throwsFormatException);
      expect(() => converter.fromJson('#FFF'), throwsFormatException);
      expect(() => converter.fromJson('teal'), throwsFormatException);
    });

    test('toJson writes #AARRGGBB', () {
      expect(converter.toJson(0xFF5EEAD4), '#FF5EEAD4');
    });
  });
}
