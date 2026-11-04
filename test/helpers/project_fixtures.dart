import 'package:portfolio/features/projects/domain/entities/project.dart';

/// A valid [Project] with test values; override what the test cares about.
Project buildProject({
  String slug = 'demo',
  int order = 1,
  String name = 'Demo',
}) {
  return Project(
    slug: slug,
    order: order,
    name: name,
    monogram: 'De',
    color: 0xFF5EEAD4,
    category: 'Category',
    badge: 'Badge',
    summary: 'Summary',
    description: 'Description',
    role: 'Role',
    status: 'Status',
    platforms: const ['iOS'],
    stack: const ['Flutter'],
    links: const ProjectLinks(),
    architecture: const ProjectArchitecture(
      feature: 'feature',
      presentation: LayerDetail(classes: ['Page'], description: 'p'),
      domain: LayerDetail(classes: ['Entity'], description: 'd'),
      data: LayerDetail(classes: ['RepositoryImpl'], description: 'x'),
    ),
  );
}

/// Shared JSON (`projects/<slug>.json`) with test values.
Map<String, Object?> projectSharedJson({
  int order = 1,
  Map<String, Object?>? snippet,
  Map<String, Object?>? extra,
}) {
  return {
    'order': order,
    'monogram': 'Fi',
    'color': '#5EEAD4',
    'platforms': ['iOS', 'Android'],
    'stack': ['Flutter', 'Firebase'],
    'links': {'github': 'https://github.com/example/demo'},
    'architecture': {
      'feature': 'spots',
      'presentation': ['SpotsMapPage'],
      'domain': ['Spot', 'GetNearbySpots'],
      'data': ['SpotsRepositoryImpl'],
    },
    'snippet': ?snippet,
    ...?extra,
  };
}

/// Localized JSON (`<lang>/projects/<slug>.json`) with test values.
Map<String, Object?> projectTextsJson({String name = 'Demo'}) {
  return {
    'name': name,
    'category': 'App social',
    'badge': 'Beta',
    'summary': 'Resumen',
    'description': 'Descripción',
    'role': 'Rol',
    'status': 'Estado',
    'architecture': {
      'presentation': 'Widgets',
      'domain': 'Dart puro',
      'data': 'Implementa contratos',
    },
    'decisions': [
      {'title': 'Decisión', 'body': 'Porque sí'},
    ],
  };
}
