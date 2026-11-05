import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:portfolio/core/architecture_mode/source_repository.dart';
import 'package:portfolio/core/contact/contact_email.dart';
import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/data/datasources/about_local_data_source.dart';
import 'package:portfolio/features/about/data/repositories/about_repository_impl.dart';
import 'package:portfolio/features/about/domain/repositories/about_repository.dart';
import 'package:portfolio/features/about/presentation/providers/about_providers.dart';
import 'package:portfolio/features/contact/data/datasources/contact_local_data_source.dart';
import 'package:portfolio/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';
import 'package:portfolio/features/experience/data/datasources/experience_local_data_source.dart';
import 'package:portfolio/features/experience/data/repositories/experience_repository_impl.dart';
import 'package:portfolio/features/experience/domain/repositories/experience_repository.dart';
import 'package:portfolio/features/experience/presentation/providers/experience_providers.dart';
import 'package:portfolio/features/projects/data/datasources/projects_local_data_source.dart';
import 'package:portfolio/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';

/// Composition root: the only place that knows both the repository
/// contracts (declared by presentation) and their data implementations.
///
/// Pass a [reader] to run the app against other content, or a specific
/// repository to replace just that one (tests).
List<Override> repositoryOverrides({
  ContentAssetReader? reader,
  ProjectsRepository? projects,
  ExperienceRepository? experience,
  ContactRepository? contact,
  AboutRepository? about,
}) {
  final content = reader ?? BundleContentAssetReader(rootBundle);
  return [
    projectsRepositoryProvider.overrideWithValue(
      projects ?? ProjectsRepositoryImpl(ProjectsLocalDataSource(content)),
    ),
    experienceRepositoryProvider.overrideWithValue(
      experience ??
          ExperienceRepositoryImpl(ExperienceLocalDataSource(content)),
    ),
    contactRepositoryProvider.overrideWithValue(
      contact ?? ContactRepositoryImpl(ContactLocalDataSource(content)),
    ),
    aboutRepositoryProvider.overrideWithValue(
      about ?? AboutRepositoryImpl(AboutLocalDataSource(content)),
    ),
    // The repo URL for the architecture badges is the GitHub link of the
    // "Este portfolio" project in the content.
    sourceRepositoryUrlProvider.overrideWith((ref) async {
      final projects = await ref.watch(
        projectsProvider(ContentLanguage.fallback).future,
      );
      for (final project in projects) {
        if (project.slug == 'portfolio') return project.links.github;
      }
      return null;
    }),
    contactEmailProvider.overrideWith((ref) async {
      final contact = await ref.watch(
        contactInfoProvider(ContentLanguage.fallback).future,
      );
      return contact.email;
    }),
  ];
}
