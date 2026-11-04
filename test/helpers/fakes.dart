import 'dart:async';

import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/domain/repositories/experience_repository.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/domain/repositories/projects_repository.dart';

/// Repositories whose answer is a future the test controls: pass a value,
/// an error, or a never-completing future to keep the UI loading.
///
/// Futures are created on each call, so a failing one is never unhandled.
class FakeProjectsRepository implements ProjectsRepository {
  FakeProjectsRepository(List<Project> projects)
    : _result = (() => Future.value(projects));

  FakeProjectsRepository.loading()
    : _result = (() => Completer<List<Project>>().future);

  FakeProjectsRepository.failing()
    : _result = (() => Future.error(const InvalidContent('projects', 'x')));

  final Future<List<Project>> Function() _result;

  @override
  Future<List<Project>> getProjects(ContentLanguage language) => _result();

  @override
  Future<Project> getProjectBySlug(String slug, ContentLanguage language) =>
      _result().then((projects) => projects.firstWhere((p) => p.slug == slug));
}

class FakeExperienceRepository implements ExperienceRepository {
  FakeExperienceRepository(List<Experience> entries)
    : _result = (() => Future.value(entries));

  FakeExperienceRepository.failing()
    : _result = (() => Future.error(const InvalidContent('experience', 'x')));

  final Future<List<Experience>> Function() _result;

  @override
  Future<List<Experience>> getExperience(ContentLanguage language) => _result();
}

class FakeContactRepository implements ContactRepository {
  FakeContactRepository([this.info = const ContactInfo()]);

  final ContactInfo info;

  @override
  Future<ContactInfo> getContactInfo(ContentLanguage language) async => info;
}

/// Records the links the UI tries to open.
class RecordingLinkOpener implements LinkOpener {
  final List<Uri> opened = [];

  @override
  Future<void> open(Uri uri) async => opened.add(uri);
}
