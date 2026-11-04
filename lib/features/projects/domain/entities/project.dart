import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';

/// A portfolio project, already resolved for one language.
@freezed
abstract class Project with _$Project {
  const factory Project({
    /// URL id, e.g. `fishar` → `/projects/fishar`.
    required String slug,

    /// Position in the projects grid (ascending).
    required int order,
    required String name,

    /// Two-letter mark shown on the card (`Fi`, `La`...).
    required String monogram,

    /// Card color as ARGB (`0xFF5EEAD4`). An int keeps the domain free of
    /// Flutter's `Color`.
    required int color,

    /// Short label under the name, e.g. "App social · Byto Apps".
    required String category,

    /// Pill on the card, e.g. "Beta · TestFlight".
    required String badge,

    /// One or two sentences for the card.
    required String summary,

    /// Lead paragraph of the detail page.
    required String description,
    required String role,
    required String status,
    required List<String> platforms,
    required List<String> stack,
    required ProjectLinks links,
    required ProjectArchitecture architecture,
    @Default(<TechDecision>[]) List<TechDecision> decisions,

    /// Optional long-form body in Markdown.
    String? body,

    /// Optional code sample for "Cómo está hecho".
    CodeSnippet? snippet,
  }) = _Project;
}

/// External links of a project. Any of them can be missing.
@freezed
abstract class ProjectLinks with _$ProjectLinks {
  const factory ProjectLinks({
    Uri? appStore,
    Uri? playStore,
    Uri? testFlight,
    Uri? github,
    Uri? website,
  }) = _ProjectLinks;

  const ProjectLinks._();

  bool get isEmpty =>
      appStore == null &&
      playStore == null &&
      testFlight == null &&
      github == null &&
      website == null;
}

/// How one feature of the project is split across the three layers.
@freezed
abstract class ProjectArchitecture with _$ProjectArchitecture {
  const factory ProjectArchitecture({
    /// Feature shown in "Cómo está hecho", e.g. `spots`.
    required String feature,
    required LayerDetail presentation,
    required LayerDetail domain,
    required LayerDetail data,
  }) = _ProjectArchitecture;
}

/// Real class names in one layer and a short explanation of its role.
@freezed
abstract class LayerDetail with _$LayerDetail {
  const factory LayerDetail({
    required List<String> classes,
    required String description,
  }) = _LayerDetail;
}

/// A technical decision explained on the detail page.
@freezed
abstract class TechDecision with _$TechDecision {
  const factory TechDecision({required String title, required String body}) =
      _TechDecision;
}

/// A code excerpt with the path it comes from.
@freezed
abstract class CodeSnippet with _$CodeSnippet {
  const factory CodeSnippet({
    required String path,
    required String language,
    required String code,
  }) = _CodeSnippet;
}
