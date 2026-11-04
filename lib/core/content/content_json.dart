import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:portfolio/core/domain/domain.dart';

/// Decodes the JSON object in [source] (read from [path]) and builds a DTO
/// with [fromJson]. Every content file is a JSON object at the top level.
///
/// Any parsing problem becomes an [InvalidContent] that names the file and,
/// when possible, the offending key.
T decodeContent<T>(
  String source,
  String path,
  T Function(Map<String, dynamic> json) fromJson,
) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (error) {
    throw InvalidContent(path, 'invalid JSON (${error.message})');
  }
  if (decoded is! Map<String, dynamic>) {
    throw InvalidContent(path, 'expected a JSON object at the top level');
  }
  try {
    return fromJson(decoded);
  } on CheckedFromJsonException catch (error) {
    final key = error.key == null ? '' : ' at "${error.key}"';
    throw InvalidContent(path, '${error.message ?? 'invalid value'}$key');
  } on UnrecognizedKeysException catch (error) {
    throw InvalidContent(path, error.message);
  }
}

/// Parses `#RRGGBB` or `#AARRGGBB` into an ARGB integer.
class HexColorConverter implements JsonConverter<int, String> {
  const HexColorConverter();

  static final RegExp _pattern = RegExp(r'^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  @override
  int fromJson(String json) {
    final match = _pattern.firstMatch(json);
    if (match == null) {
      throw FormatException('expected a color like "#5EEAD4", got "$json"');
    }
    final hex = match.group(1)!;
    final value = int.parse(hex, radix: 16);
    return hex.length == 6 ? 0xFF000000 | value : value;
  }

  @override
  String toJson(int object) =>
      '#${object.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}
