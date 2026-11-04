import 'package:flutter/painting.dart';

/// Colors of each token kind.
class CodePalette {
  const CodePalette({
    required this.plain,
    required this.keyword,
    required this.string,
    required this.number,
    required this.comment,
    required this.type,
  });

  final Color plain;
  final Color keyword;
  final Color string;
  final Color number;
  final Color comment;
  final Color type;
}

enum CodeTokenKind { plain, keyword, string, number, comment, type }

/// Minimal Dart tokenizer for code samples: keywords, strings, comments,
/// numbers and capitalized identifiers (types). Not a parser; good enough
/// for short, valid snippets and fully deterministic.
abstract final class DartHighlighter {
  static const Set<String> keywords = {
    'abstract',
    'as',
    'assert',
    'async',
    'await',
    'base',
    'bool',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'covariant',
    'default',
    'deferred',
    'do',
    'double',
    'dynamic',
    'else',
    'enum',
    'export',
    'extends',
    'extension',
    'external',
    'factory',
    'false',
    'final',
    'finally',
    'for',
    'get',
    'hide',
    'if',
    'implements',
    'import',
    'in',
    'int',
    'interface',
    'is',
    'late',
    'library',
    'mixin',
    'new',
    'null',
    'num',
    'on',
    'operator',
    'part',
    'required',
    'rethrow',
    'return',
    'sealed',
    'set',
    'show',
    'static',
    'super',
    'switch',
    'sync',
    'this',
    'throw',
    'true',
    'try',
    'typedef',
    'var',
    'void',
    'when',
    'while',
    'with',
    'yield',
  };

  static final RegExp _token = RegExp(
    r'(?<comment>//[^\n]*|/\*[\s\S]*?\*/)'
    r"|(?<string>'(?:\\.|[^'\\\n])*'|"
    r'"(?:\\.|[^"\\\n])*")'
    r'|(?<number>\b\d+(?:\.\d+)?\b)'
    r'|(?<word>\b[A-Za-z_$][A-Za-z0-9_$]*\b)',
  );

  /// Splits [code] into `(kind, text)` tokens that together rebuild it.
  static List<(CodeTokenKind, String)> tokenize(String code) {
    final tokens = <(CodeTokenKind, String)>[];
    var last = 0;
    for (final match in _token.allMatches(code)) {
      final kind = _kindOf(match);
      if (kind == CodeTokenKind.plain) continue;
      if (match.start > last) {
        tokens.add((CodeTokenKind.plain, code.substring(last, match.start)));
      }
      tokens.add((kind, match.group(0)!));
      last = match.end;
    }
    if (last < code.length) {
      tokens.add((CodeTokenKind.plain, code.substring(last)));
    }
    return tokens;
  }

  static CodeTokenKind _kindOf(RegExpMatch match) {
    if (match.namedGroup('comment') != null) return CodeTokenKind.comment;
    if (match.namedGroup('string') != null) return CodeTokenKind.string;
    if (match.namedGroup('number') != null) return CodeTokenKind.number;
    final word = match.namedGroup('word')!;
    if (keywords.contains(word)) return CodeTokenKind.keyword;
    if (word.startsWith(RegExp('[A-Z]'))) return CodeTokenKind.type;
    return CodeTokenKind.plain;
  }

  /// [code] as colored spans on top of [base].
  static TextSpan highlight(String code, TextStyle base, CodePalette palette) {
    return TextSpan(
      style: base.copyWith(color: palette.plain),
      children: [
        for (final (kind, text) in tokenize(code))
          TextSpan(
            text: text,
            style: switch (kind) {
              CodeTokenKind.plain => null,
              CodeTokenKind.keyword => TextStyle(color: palette.keyword),
              CodeTokenKind.string => TextStyle(color: palette.string),
              CodeTokenKind.number => TextStyle(color: palette.number),
              CodeTokenKind.comment => TextStyle(
                color: palette.comment,
                fontStyle: FontStyle.italic,
              ),
              CodeTokenKind.type => TextStyle(color: palette.type),
            },
          ),
      ],
    );
  }
}
