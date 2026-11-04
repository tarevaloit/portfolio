import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_info.freezed.dart';

/// Contact channels, resolved for one language. Every field can be missing
/// until the content is filled in.
@freezed
abstract class ContactInfo with _$ContactInfo {
  const factory ContactInfo({
    String? email,
    Uri? github,
    Uri? linkedin,

    /// Asset path of the CV PDF for the language (e.g. `assets/cv/cv_es.pdf`).
    String? cvAssetPath,
  }) = _ContactInfo;

  const ContactInfo._();

  /// `mailto:` link for [email], or `null`.
  Uri? get mailto => email == null ? null : Uri(scheme: 'mailto', path: email);
}
