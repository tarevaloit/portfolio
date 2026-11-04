import 'package:json_annotation/json_annotation.dart';

part 'contact_dto.g.dart';

/// `assets/content/contact.json`.
@JsonSerializable()
class ContactDto {
  const ContactDto({
    this.email,
    this.github,
    this.linkedin,
    this.cv = const {},
  });

  factory ContactDto.fromJson(Map<String, dynamic> json) =>
      _$ContactDtoFromJson(json);

  final String? email;
  final Uri? github;
  final Uri? linkedin;

  /// CV asset path per language code (`es`, `en`); values can be `null`.
  final Map<String, String?> cv;
}
