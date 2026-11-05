import 'package:json_annotation/json_annotation.dart';
import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

part 'project_dto.g.dart';

/// `assets/content/projects/<slug>.json`: data shared by every language.
@JsonSerializable()
class ProjectDto {
  const ProjectDto({
    required this.order,
    required this.monogram,
    required this.color,
    required this.platforms,
    required this.stack,
    required this.architecture,
    this.links = const ProjectLinksDto(),
    this.snippet,
    this.logo,
    this.media = const [],
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);

  final int order;
  final String monogram;
  @HexColorConverter()
  final int color;
  final List<String> platforms;
  final List<String> stack;
  final ProjectLinksDto links;
  final ProjectArchitectureDto architecture;
  final CodeSnippetDto? snippet;

  /// Asset path of the app icon.
  final String? logo;
  final List<ProjectMediaDto> media;
}

/// An image; its caption lives in the texts of each language, by [id].
@JsonSerializable()
class ProjectMediaDto {
  const ProjectMediaDto({
    required this.id,
    required this.asset,
    this.kind = ProjectMediaKind.figure,
  });

  factory ProjectMediaDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectMediaDtoFromJson(json);

  final String id;
  final String asset;

  /// `phone`, `web` or `figure` (the default).
  final ProjectMediaKind kind;
}

@JsonSerializable()
class ProjectLinksDto {
  const ProjectLinksDto({
    this.appStore,
    this.playStore,
    this.testFlight,
    this.github,
    this.website,
  });

  factory ProjectLinksDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectLinksDtoFromJson(json);

  final Uri? appStore;
  final Uri? playStore;
  final Uri? testFlight;
  final Uri? github;
  final Uri? website;
}

/// Class names per layer (shared, not translated).
@JsonSerializable()
class ProjectArchitectureDto {
  const ProjectArchitectureDto({
    required this.feature,
    required this.presentation,
    required this.domain,
    required this.data,
  });

  factory ProjectArchitectureDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectArchitectureDtoFromJson(json);

  final String feature;
  final List<String> presentation;
  final List<String> domain;
  final List<String> data;
}

/// Where the code sample comes from. The code itself lives next to the
/// JSON in `<slug>.snippet`.
@JsonSerializable()
class CodeSnippetDto {
  const CodeSnippetDto({required this.path, this.language = 'dart'});

  factory CodeSnippetDto.fromJson(Map<String, dynamic> json) =>
      _$CodeSnippetDtoFromJson(json);

  final String path;
  final String language;
}
