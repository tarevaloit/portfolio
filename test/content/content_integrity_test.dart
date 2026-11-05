// Checks the real files in assets/content/ through the real asset bundle,
// so a typo in a JSON fails here instead of in production.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/di/repository_overrides.dart';
import 'package:portfolio/core/content/content.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/presentation/providers/about_providers.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';
import 'package:portfolio/features/experience/presentation/providers/experience_providers.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentAssetReader reader;
  late ProviderContainer container;

  setUp(() {
    reader = BundleContentAssetReader(rootBundle);
    container = ProviderContainer(
      overrides: repositoryOverrides(reader: reader),
    );
    addTearDown(container.dispose);
  });

  Future<List<Project>> projects(ContentLanguage language) =>
      container.read(projectsProvider(language).future);

  for (final language in ContentLanguage.values) {
    group('content in ${language.code}', () {
      test('projects load, with unique slugs and orders', () async {
        final list = await projects(language);

        expect(list, isNotEmpty);
        expect(list.map((p) => p.slug).toSet(), hasLength(list.length));
        expect(list.map((p) => p.order).toSet(), hasLength(list.length));
        for (final project in list) {
          expect(project.name.trim(), isNotEmpty, reason: project.slug);
          expect(project.monogram.trim(), isNotEmpty, reason: project.slug);
          expect(project.stack, isNotEmpty, reason: project.slug);
        }
      });

      test('every project is translated (no silent fallback)', () async {
        for (final project in await projects(language)) {
          final path =
              'assets/content/${language.code}/projects/${project.slug}.json';
          expect(await reader.read(path), isNotNull, reason: path);
        }
      });

      test('every logo and image is bundled', () async {
        final bundled = await reader.list('assets/projects/');
        for (final project in await projects(language)) {
          for (final asset in [
            ?project.logo,
            for (final media in project.media) media.asset,
          ]) {
            expect(bundled, contains(asset), reason: project.slug);
          }
        }
      });

      test('experience loads', () async {
        final entries = await container.read(
          experienceProvider(language).future,
        );

        expect(entries, isNotEmpty);
        for (final entry in entries) {
          expect(entry.highlights, isNotEmpty, reason: entry.id);
        }
      });

      test('about loads and its photo is bundled', () async {
        final about = await container.read(aboutInfoProvider(language).future);

        expect(about.paragraphs, isNotEmpty);
        final photo = about.photo;
        if (photo != null) {
          expect(await reader.list('assets/about/'), contains(photo));
        }
      });

      test('contact loads and its CV is bundled', () async {
        final contact = await container.read(
          contactInfoProvider(language).future,
        );
        final cv = contact.cvAssetPath;
        if (cv != null) {
          expect(await reader.list('assets/cv/'), contains(cv));
        }
      });
    });
  }

  group('"Este portfolio" describes this very repo', () {
    Future<Project> portfolio() => container.read(
      projectBySlugProvider((
        slug: 'portfolio',
        language: ContentLanguage.es,
      )).future,
    );

    test('every class name in its architecture exists in lib/', () async {
      final architecture = (await portfolio()).architecture;
      final sources = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');

      for (final name in [
        ...architecture.presentation.classes,
        ...architecture.domain.classes,
        ...architecture.data.classes,
      ]) {
        final declared = RegExp(
          '(class|typedef|enum|mixin|extension)\\s+$name\\b'
          '|\\b$name\\s*=',
        ).hasMatch(sources);
        expect(declared, isTrue, reason: '$name is not declared in lib/');
      }
    });

    test('its snippets are excerpts of the real source files', () async {
      final project = await portfolio();

      expect(project.snippets, isNotEmpty);
      for (final snippet in project.snippets) {
        expect(
          File(snippet.path).readAsStringSync(),
          contains(snippet.code),
          reason: '${snippet.path} changed: copy the excerpt again',
        );
      }
    });

    test('its file tree only lists files that exist', () async {
      for (final path in (await portfolio()).files) {
        expect(File(path).existsSync(), isTrue, reason: '$path is missing');
      }
    });
  });
}
