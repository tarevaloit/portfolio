import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/projects/data/datasources/projects_local_data_source.dart';
import 'package:portfolio/features/projects/data/repositories/projects_repository_impl.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

import '../../../helpers/in_memory_content_reader.dart';
import '../../../helpers/project_fixtures.dart';

const _root = 'assets/content';

ProjectsRepositoryImpl _repository(InMemoryContentReader reader) =>
    ProjectsRepositoryImpl(ProjectsLocalDataSource(reader));

void main() {
  group('ProjectsRepositoryImpl', () {
    test('merges shared data with the texts of the language', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(),
        '$_root/es/projects/fishar.json': projectTextsJson(name: 'Fishar ES'),
        '$_root/en/projects/fishar.json': projectTextsJson(name: 'Fishar EN'),
      });

      final project = (await _repository(
        reader,
      ).getProjects(ContentLanguage.en)).single;

      expect(project.slug, 'fishar');
      expect(project.name, 'Fishar EN');
      expect(project.color, 0xFF5EEAD4);
      expect(project.platforms, ['iOS', 'Android']);
      expect(
        project.links.github,
        Uri.parse('https://github.com/example/demo'),
      );
      expect(project.links.appStore, isNull);
      expect(project.architecture.feature, 'spots');
      expect(project.architecture.domain.classes, ['Spot', 'GetNearbySpots']);
      expect(project.architecture.domain.description, 'Dart puro');
      expect(project.decisions.single.title, 'Decisión');
      expect(project.body, isNull);
      expect(project.snippet, isNull);
    });

    test('falls back to Spanish texts and body when a translation is '
        'missing', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(),
        '$_root/es/projects/fishar.json': projectTextsJson(name: 'Fishar ES'),
        '$_root/es/projects/fishar.md': '# Cuerpo',
      });

      final project = (await _repository(
        reader,
      ).getProjects(ContentLanguage.en)).single;

      expect(project.name, 'Fishar ES');
      expect(project.body, '# Cuerpo');
    });

    test('loads the snippet code when the shared JSON declares it', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(
          snippet: {'path': 'domain/get_nearby_spots.dart'},
        ),
        '$_root/projects/fishar.snippet': 'class GetNearbySpots {}',
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });

      final project = (await _repository(
        reader,
      ).getProjects(ContentLanguage.es)).single;

      expect(project.snippet?.path, 'domain/get_nearby_spots.dart');
      expect(project.snippet?.language, 'dart');
      expect(project.snippet?.code, 'class GetNearbySpots {}');
    });

    test('maps the logo and the images with their captions', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(
          extra: {
            'logo': 'assets/projects/fishar-logo.webp',
            'media': [
              {'id': 'map', 'asset': 'assets/projects/fishar-map.webp'},
              {
                'id': 'feed',
                'asset': 'assets/projects/fishar-feed.webp',
                'kind': 'phone',
              },
            ],
          },
        ),
        '$_root/es/projects/fishar.json': {
          ...projectTextsJson(),
          'mediaCaptions': {'map': 'El mapa de spots', 'feed': 'El feed'},
        },
      });

      final project = (await _repository(
        reader,
      ).getProjects(ContentLanguage.es)).single;

      expect(project.logo, 'assets/projects/fishar-logo.webp');
      expect(project.media, const [
        ProjectMedia(
          asset: 'assets/projects/fishar-map.webp',
          caption: 'El mapa de spots',
        ),
        ProjectMedia(
          asset: 'assets/projects/fishar-feed.webp',
          caption: 'El feed',
          kind: ProjectMediaKind.phone,
        ),
      ]);
    });

    test('an image without a caption is InvalidContent', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(
          extra: {
            'media': [
              {'id': 'map', 'asset': 'assets/projects/fishar-map.webp'},
            ],
          },
        ),
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });

      await expectLater(
        _repository(reader).getProjects(ContentLanguage.es),
        throwsA(isA<InvalidContent>()),
      );
    });

    test('ignores files that are not shared project JSON', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(),
        '$_root/projects/fishar.snippet': 'code',
        '$_root/projects/nested/other.json': projectSharedJson(),
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });

      final projects = await _repository(
        reader,
      ).getProjects(ContentLanguage.es);

      expect(projects.map((p) => p.slug), ['fishar']);
    });

    test('caches results per language', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(),
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });
      final repository = _repository(reader);

      await repository.getProjects(ContentLanguage.es);
      final readsAfterFirstLoad = reader.reads.length;
      await repository.getProjects(ContentLanguage.es);

      expect(reader.reads.length, readsAfterFirstLoad);
    });

    test(
      'getProjectBySlug finds the project or throws ContentNotFound',
      () async {
        final reader = InMemoryContentReader({
          '$_root/projects/fishar.json': projectSharedJson(),
          '$_root/es/projects/fishar.json': projectTextsJson(),
        });
        final repository = _repository(reader);

        final project = await repository.getProjectBySlug(
          'fishar',
          ContentLanguage.es,
        );
        expect(project.slug, 'fishar');

        await expectLater(
          repository.getProjectBySlug('nope', ContentLanguage.es),
          throwsA(isA<ContentNotFound>()),
        );
      },
    );

    test('a project without texts in any language is InvalidContent', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(),
      });

      await expectLater(
        _repository(reader).getProjects(ContentLanguage.en),
        throwsA(isA<InvalidContent>()),
      );
    });

    test('broken JSON is InvalidContent naming the file', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': '{"order": ',
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });

      await expectLater(
        _repository(reader).getProjects(ContentLanguage.es),
        throwsA(
          isA<InvalidContent>().having(
            (e) => e.source,
            'source',
            '$_root/projects/fishar.json',
          ),
        ),
      );
    });

    test('unknown keys and wrong types are InvalidContent', () async {
      final typo = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(
          extra: {'colour': '#FFFFFF'},
        ),
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });
      final wrongType = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(
          extra: {'order': 'first'},
        ),
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });
      final badColor = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(
          extra: {'color': 'teal'},
        ),
        '$_root/es/projects/fishar.json': projectTextsJson(),
      });

      for (final reader in [typo, wrongType, badColor]) {
        await expectLater(
          _repository(reader).getProjects(ContentLanguage.es),
          throwsA(isA<InvalidContent>()),
        );
      }
    });

    test('a failed load is not cached', () async {
      final reader = InMemoryContentReader({
        '$_root/projects/fishar.json': projectSharedJson(),
      });
      final repository = _repository(reader);

      await expectLater(
        repository.getProjects(ContentLanguage.es),
        throwsA(isA<InvalidContent>()),
      );

      reader.put('$_root/es/projects/fishar.json', projectTextsJson());

      expect(await repository.getProjects(ContentLanguage.es), hasLength(1));
    });
  });
}
