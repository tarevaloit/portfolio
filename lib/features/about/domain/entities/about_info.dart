import 'package:freezed_annotation/freezed_annotation.dart';

part 'about_info.freezed.dart';

/// "Sobre mí": who is behind the portfolio, resolved for one language.
@freezed
abstract class AboutInfo with _$AboutInfo {
  const factory AboutInfo({
    required List<String> paragraphs,
    required List<AboutFact> facts,

    /// Asset path of the photo.
    String? photo,
  }) = _AboutInfo;
}

/// A short labelled fact, such as "Educación: Ingeniería en Informática".
@freezed
abstract class AboutFact with _$AboutFact {
  const factory AboutFact({required String label, required String value}) =
      _AboutFact;
}
