import 'package:json_annotation/json_annotation.dart';

part 'project_texts_dto.g.dart';

/// `assets/content/<lang>/projects/<slug>.json`: texts in one language.
@JsonSerializable()
class ProjectTextsDto {
  const ProjectTextsDto({
    required this.name,
    required this.category,
    required this.badge,
    required this.summary,
    required this.description,
    required this.role,
    required this.status,
    required this.architecture,
    this.decisions = const [],
  });

  factory ProjectTextsDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectTextsDtoFromJson(json);

  final String name;
  final String category;
  final String badge;
  final String summary;
  final String description;
  final String role;
  final String status;
  final LayerTextsDto architecture;
  final List<TechDecisionDto> decisions;
}

/// One-line explanation of each layer.
@JsonSerializable()
class LayerTextsDto {
  const LayerTextsDto({
    required this.presentation,
    required this.domain,
    required this.data,
  });

  factory LayerTextsDto.fromJson(Map<String, dynamic> json) =>
      _$LayerTextsDtoFromJson(json);

  final String presentation;
  final String domain;
  final String data;
}

@JsonSerializable()
class TechDecisionDto {
  const TechDecisionDto({required this.title, required this.body});

  factory TechDecisionDto.fromJson(Map<String, dynamic> json) =>
      _$TechDecisionDtoFromJson(json);

  final String title;
  final String body;
}
