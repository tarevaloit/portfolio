import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/features/contact/data/datasources/contact_local_data_source.dart';
import 'package:portfolio/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';
import 'package:portfolio/features/experience/data/datasources/experience_local_data_source.dart';
import 'package:portfolio/features/experience/data/repositories/experience_repository_impl.dart';
import 'package:portfolio/features/experience/presentation/providers/experience_providers.dart';
import 'package:portfolio/features/projects/data/datasources/projects_local_data_source.dart';
import 'package:portfolio/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';

/// Composition root: the only place that knows both the repository
/// contracts (declared by presentation) and their data implementations.
///
/// Pass a [reader] to run the app or its tests against other content.
List<Override> repositoryOverrides({ContentAssetReader? reader}) {
  final content = reader ?? BundleContentAssetReader(rootBundle);
  return [
    projectsRepositoryProvider.overrideWithValue(
      ProjectsRepositoryImpl(ProjectsLocalDataSource(content)),
    ),
    experienceRepositoryProvider.overrideWithValue(
      ExperienceRepositoryImpl(ExperienceLocalDataSource(content)),
    ),
    contactRepositoryProvider.overrideWithValue(
      ContactRepositoryImpl(ContactLocalDataSource(content)),
    ),
  ];
}
