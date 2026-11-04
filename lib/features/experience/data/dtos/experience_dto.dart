import 'package:json_annotation/json_annotation.dart';

part 'experience_dto.g.dart';

/// `assets/content/experience.json`: data shared by every language.
@JsonSerializable()
class ExperienceFileDto {
  const ExperienceFileDto({required this.entries});

  factory ExperienceFileDto.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFileDtoFromJson(json);

  final List<ExperienceDto> entries;
}

@JsonSerializable()
class ExperienceDto {
  const ExperienceDto({
    required this.id,
    required this.order,
    required this.company,
    this.startYear,
    this.endYear,
  });

  factory ExperienceDto.fromJson(Map<String, dynamic> json) =>
      _$ExperienceDtoFromJson(json);

  final String id;
  final int order;
  final String company;
  final int? startYear;
  final int? endYear;
}

/// `assets/content/<lang>/experience.json`: texts keyed by entry id.
@JsonSerializable()
class ExperienceTextsFileDto {
  const ExperienceTextsFileDto({required this.entries});

  factory ExperienceTextsFileDto.fromJson(Map<String, dynamic> json) =>
      _$ExperienceTextsFileDtoFromJson(json);

  final Map<String, ExperienceTextsDto> entries;
}

@JsonSerializable()
class ExperienceTextsDto {
  const ExperienceTextsDto({required this.role, required this.highlights});

  factory ExperienceTextsDto.fromJson(Map<String, dynamic> json) =>
      _$ExperienceTextsDtoFromJson(json);

  final String role;
  final List<String> highlights;
}
