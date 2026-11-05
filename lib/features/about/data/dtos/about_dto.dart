import 'package:json_annotation/json_annotation.dart';

part 'about_dto.g.dart';

/// `assets/content/about.json`: data shared by every language.
@JsonSerializable()
class AboutDto {
  const AboutDto({this.photo});

  factory AboutDto.fromJson(Map<String, dynamic> json) =>
      _$AboutDtoFromJson(json);

  final String? photo;
}

/// `assets/content/<lang>/about.json`: texts in one language.
@JsonSerializable()
class AboutTextsDto {
  const AboutTextsDto({required this.paragraphs, this.facts = const []});

  factory AboutTextsDto.fromJson(Map<String, dynamic> json) =>
      _$AboutTextsDtoFromJson(json);

  final List<String> paragraphs;
  final List<AboutFactDto> facts;
}

@JsonSerializable()
class AboutFactDto {
  const AboutFactDto({required this.label, required this.value});

  factory AboutFactDto.fromJson(Map<String, dynamic> json) =>
      _$AboutFactDtoFromJson(json);

  final String label;
  final String value;
}
