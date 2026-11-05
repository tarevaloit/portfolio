import 'package:portfolio/core/architecture_mode/layer_ref.dart';

/// What each badge of the architecture mode shows: the widget first, then
/// the chain it depends on down to the data layer.
///
/// Plain strings, so core does not import the features.
/// `test/architecture/architecture_map_test.dart` checks that every name is
/// declared in its file, so the badges cannot drift from the code.
abstract final class ArchitectureMap {
  static const _home = 'lib/features/home/presentation';
  static const _projects = 'lib/features/projects';
  static const _experience = 'lib/features/experience';
  static const _contact = 'lib/features/contact';

  static const _projectsProvider = LayerRef.presentation(
    'projectsProvider',
    '$_projects/presentation/providers/projects_providers.dart',
  );
  static const _getProjects = LayerRef.domain(
    'GetProjects',
    '$_projects/domain/usecases/get_projects.dart',
  );
  static const _projectsRepository = LayerRef.data(
    'ProjectsRepositoryImpl',
    '$_projects/data/repositories/projects_repository_impl.dart',
  );
  static const _contactProvider = LayerRef.presentation(
    'contactInfoProvider',
    '$_contact/presentation/providers/contact_providers.dart',
  );
  static const _getContactInfo = LayerRef.domain(
    'GetContactInfo',
    '$_contact/domain/usecases/get_contact_info.dart',
  );
  static const _contactRepository = LayerRef.data(
    'ContactRepositoryImpl',
    '$_contact/data/repositories/contact_repository_impl.dart',
  );

  static const List<LayerRef> navBar = [
    LayerRef.presentation('HomeNavBar', '$_home/widgets/home_nav_bar.dart'),
    LayerRef.presentation(
      'architectureModeProvider',
      'lib/core/architecture_mode/architecture_mode_controller.dart',
    ),
  ];

  static const List<LayerRef> hero = [
    LayerRef.presentation('HeroSection', '$_home/widgets/hero_section.dart'),
    LayerRef.presentation(
      'ProjectsShowcase',
      '$_projects/presentation/widgets/projects_showcase.dart',
    ),
    _projectsProvider,
    _getProjects,
    _projectsRepository,
  ];

  static const List<LayerRef> byto = [
    LayerRef.presentation('BytoSection', '$_home/widgets/byto_section.dart'),
    _projectsProvider,
    _getProjects,
    _projectsRepository,
  ];

  static const List<LayerRef> metrics = [
    LayerRef.presentation('MetricsRow', '$_home/widgets/metrics_row.dart'),
  ];

  static const List<LayerRef> marquee = [
    LayerRef.presentation(
      'Marquee',
      'lib/core/design_system/components/marquee.dart',
    ),
  ];

  static const List<LayerRef> projects = [
    LayerRef.presentation(
      'ProjectsSection',
      '$_projects/presentation/widgets/projects_section.dart',
    ),
    _projectsProvider,
    _getProjects,
    _projectsRepository,
    LayerRef.data(
      'ProjectsLocalDataSource',
      '$_projects/data/datasources/projects_local_data_source.dart',
    ),
  ];

  static const List<LayerRef> projectCard = [
    LayerRef.presentation(
      'ProjectCard',
      '$_projects/presentation/widgets/project_card.dart',
    ),
    LayerRef.domain('Project', '$_projects/domain/entities/project.dart'),
  ];

  static const List<LayerRef> about = [
    LayerRef.presentation(
      'AboutSection',
      'lib/features/about/presentation/widgets/about_section.dart',
    ),
    LayerRef.presentation(
      'aboutInfoProvider',
      'lib/features/about/presentation/providers/about_providers.dart',
    ),
    LayerRef.domain(
      'GetAboutInfo',
      'lib/features/about/domain/usecases/get_about_info.dart',
    ),
    LayerRef.data(
      'AboutRepositoryImpl',
      'lib/features/about/data/repositories/about_repository_impl.dart',
    ),
  ];

  static const List<LayerRef> experience = [
    LayerRef.presentation(
      'ExperienceSection',
      '$_experience/presentation/widgets/experience_section.dart',
    ),
    LayerRef.presentation(
      'experienceProvider',
      '$_experience/presentation/providers/experience_providers.dart',
    ),
    LayerRef.domain(
      'GetExperience',
      '$_experience/domain/usecases/get_experience.dart',
    ),
    LayerRef.data(
      'ExperienceRepositoryImpl',
      '$_experience/data/repositories/experience_repository_impl.dart',
    ),
  ];

  static const List<LayerRef> contact = [
    LayerRef.presentation(
      'ContactSection',
      '$_contact/presentation/widgets/contact_section.dart',
    ),
    _contactProvider,
    _getContactInfo,
    _contactRepository,
  ];

  static const List<LayerRef> projectDetail = [
    LayerRef.presentation(
      'ProjectDetailPage',
      '$_projects/presentation/pages/project_detail_page.dart',
    ),
    _projectsProvider,
    _getProjects,
    _projectsRepository,
  ];

  static const List<LayerRef> howItsBuilt = [
    LayerRef.presentation(
      'HowItsBuiltSection',
      '$_projects/presentation/widgets/detail/how_its_built_section.dart',
    ),
    LayerRef.domain(
      'ProjectArchitecture',
      '$_projects/domain/entities/project.dart',
    ),
  ];

  static const List<LayerRef> codeBlock = [
    LayerRef.presentation(
      'FeatureCode',
      '$_projects/presentation/widgets/detail/feature_code.dart',
    ),
    LayerRef.presentation(
      'CodeBlock',
      'lib/core/design_system/code/code_block.dart',
    ),
    LayerRef.presentation(
      'DartHighlighter',
      'lib/core/design_system/code/dart_highlighter.dart',
    ),
    LayerRef.domain('CodeSnippet', '$_projects/domain/entities/project.dart'),
  ];

  /// Real screenshots of the app, in the phone of the detail page.
  static const List<LayerRef> screenshots = [
    LayerRef.presentation(
      'MediaCarousel',
      '$_projects/presentation/widgets/detail/media_carousel.dart',
    ),
    LayerRef.domain('ProjectMedia', '$_projects/domain/entities/project.dart'),
  ];

  /// Screenshots of the web version, in a browser window.
  static const List<LayerRef> webMedia = [
    LayerRef.presentation(
      'WebMediaSection',
      '$_projects/presentation/widgets/detail/web_media_section.dart',
    ),
    LayerRef.presentation(
      'BrowserFrame',
      '$_projects/presentation/widgets/detail/browser_frame.dart',
    ),
    LayerRef.domain('ProjectMedia', '$_projects/domain/entities/project.dart'),
  ];

  /// The phone demo of a project without screenshots (a hand-made mock,
  /// not the app's code).
  static List<LayerRef> demo(String slug) => switch (slug) {
    'portfolio' => const [
      LayerRef.presentation('HomePreview', '$_home/widgets/home_preview.dart'),
    ],
    _ => const [],
  };

  /// Every chain, for the consistency test.
  static List<List<LayerRef>> get all => [
    navBar,
    hero,
    byto,
    metrics,
    marquee,
    projects,
    projectCard,
    about,
    experience,
    contact,
    projectDetail,
    howItsBuilt,
    codeBlock,
    screenshots,
    webMedia,
    demo('portfolio'),
  ];
}
