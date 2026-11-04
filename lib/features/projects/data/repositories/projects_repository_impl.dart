import 'dart:async';

import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/data/datasources/projects_local_data_source.dart';
import 'package:portfolio/features/projects/data/dtos/project_dto.dart';
import 'package:portfolio/features/projects/data/dtos/project_texts_dto.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';

/// [ProjectsRepository] over the local content files.
///
/// Texts missing in the requested language fall back to
/// [ContentLanguage.fallback]. Results are cached per language; content is
/// bundled with the app, so it never changes while it runs.
class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(this._source);

  final ProjectsLocalDataSource _source;
  final Map<ContentLanguage, Future<List<Project>>> _cache = {};

  @override
  Future<List<Project>> getProjects(ContentLanguage language) async {
    final cached = _cache[language];
    if (cached != null) return cached;

    final loading = _load(language);
    _cache[language] = loading;
    try {
      return await loading;
    } catch (_) {
      // Do not cache failures, so a retry can succeed. The removed future
      // is the one already being awaited above.
      unawaited(_cache.remove(language));
      rethrow;
    }
  }

  @override
  Future<Project> getProjectBySlug(
    String slug,
    ContentLanguage language,
  ) async {
    final projects = await getProjects(language);
    for (final project in projects) {
      if (project.slug == slug) return project;
    }
    throw ContentNotFound('Project "$slug" not found');
  }

  Future<List<Project>> _load(ContentLanguage language) async {
    final slugs = await _source.slugs();
    return Future.wait([for (final slug in slugs) _project(slug, language)]);
  }

  Future<Project> _project(String slug, ContentLanguage language) async {
    final shared = await _source.shared(slug);
    final texts =
        await _source.texts(slug, language) ??
        await _source.texts(slug, ContentLanguage.fallback);
    if (texts == null) {
      throw InvalidContent(
        'projects/$slug.json',
        'no texts in "${language.code}" nor in '
            '"${ContentLanguage.fallback.code}"',
      );
    }
    final body =
        await _source.body(slug, language) ??
        await _source.body(slug, ContentLanguage.fallback);
    final snippetCode = shared.snippet == null
        ? null
        : await _source.snippet(slug);

    return _toEntity(slug, shared, texts, body, snippetCode);
  }
}

Project _toEntity(
  String slug,
  ProjectDto shared,
  ProjectTextsDto texts,
  String? body,
  String? snippetCode,
) {
  final snippet = shared.snippet;
  return Project(
    slug: slug,
    order: shared.order,
    name: texts.name,
    monogram: shared.monogram,
    color: shared.color,
    category: texts.category,
    badge: texts.badge,
    summary: texts.summary,
    description: texts.description,
    role: texts.role,
    status: texts.status,
    platforms: List.unmodifiable(shared.platforms),
    stack: List.unmodifiable(shared.stack),
    links: ProjectLinks(
      appStore: shared.links.appStore,
      playStore: shared.links.playStore,
      testFlight: shared.links.testFlight,
      github: shared.links.github,
      website: shared.links.website,
    ),
    architecture: ProjectArchitecture(
      feature: shared.architecture.feature,
      presentation: LayerDetail(
        classes: List.unmodifiable(shared.architecture.presentation),
        description: texts.architecture.presentation,
      ),
      domain: LayerDetail(
        classes: List.unmodifiable(shared.architecture.domain),
        description: texts.architecture.domain,
      ),
      data: LayerDetail(
        classes: List.unmodifiable(shared.architecture.data),
        description: texts.architecture.data,
      ),
    ),
    decisions: List.unmodifiable([
      for (final decision in texts.decisions)
        TechDecision(title: decision.title, body: decision.body),
    ]),
    body: body,
    snippet: snippet == null || snippetCode == null
        ? null
        : CodeSnippet(
            path: snippet.path,
            language: snippet.language,
            code: snippetCode,
          ),
  );
}
