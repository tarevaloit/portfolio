import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/experience/data/datasources/experience_local_data_source.dart';
import 'package:portfolio/features/experience/data/repositories/experience_repository_impl.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/domain/repositories/experience_repository.dart';
import 'package:portfolio/features/experience/domain/usecases/get_experience.dart';
import 'package:portfolio/features/experience/presentation/providers/experience_providers.dart';

import '../../helpers/in_memory_content_reader.dart';

const _root = 'assets/content';

Experience _entry(String id, int order) => Experience(
  id: id,
  order: order,
  company: id,
  role: 'Role',
  highlights: const [],
);

class _FakeRepository implements ExperienceRepository {
  _FakeRepository(this.entries);

  final List<Experience> entries;

  @override
  Future<List<Experience>> getExperience(ContentLanguage language) async =>
      entries;
}

Map<String, Object?> _shared() => {
  'entries': [
    {'id': 'byto', 'order': 2, 'company': 'Byto Apps', 'startYear': 2021},
    {'id': 'ueno', 'order': 1, 'company': 'ueno bank · itti'},
  ],
};

Map<String, Object?> _texts(String role, {bool includeByto = true}) => {
  'entries': {
    'ueno': {
      'role': role,
      'highlights': ['A', 'B'],
    },
    if (includeByto)
      'byto': {
        'role': '$role (Byto)',
        'highlights': <String>[],
      },
  },
};

ExperienceRepositoryImpl _repository(Map<String, Object> files) =>
    ExperienceRepositoryImpl(
      ExperienceLocalDataSource(InMemoryContentReader(files)),
    );

void main() {
  group('Experience', () {
    test('without endYear it is current', () {
      expect(_entry('a', 1).isCurrent, isTrue);
      expect(_entry('a', 1).copyWith(endYear: 2024).isCurrent, isFalse);
    });
  });

  group('GetExperience', () {
    test('sorts by order', () async {
      final useCase = GetExperience(
        _FakeRepository([_entry('b', 2), _entry('a', 1)]),
      );

      final entries = await useCase(ContentLanguage.es);

      expect(entries.map((e) => e.id), ['a', 'b']);
    });
  });

  group('ExperienceRepositoryImpl', () {
    test('merges shared data with the texts of the language', () async {
      final repository = _repository({
        '$_root/experience.json': _shared(),
        '$_root/es/experience.json': _texts('Desarrollador'),
        '$_root/en/experience.json': _texts('Developer'),
      });

      final entries = await repository.getExperience(ContentLanguage.en);
      final ueno = entries.firstWhere((e) => e.id == 'ueno');
      final byto = entries.firstWhere((e) => e.id == 'byto');

      expect(ueno.role, 'Developer');
      expect(ueno.highlights, ['A', 'B']);
      expect(ueno.startYear, isNull);
      expect(ueno.isCurrent, isTrue);
      expect(byto.startYear, 2021);
    });

    test('falls back to Spanish per entry', () async {
      final repository = _repository({
        '$_root/experience.json': _shared(),
        '$_root/es/experience.json': _texts('Desarrollador'),
        '$_root/en/experience.json': _texts('Developer', includeByto: false),
      });

      final entries = await repository.getExperience(ContentLanguage.en);

      expect(
        entries.firstWhere((e) => e.id == 'byto').role,
        'Desarrollador (Byto)',
      );
    });

    test('an entry without texts is InvalidContent', () async {
      final repository = _repository({
        '$_root/experience.json': _shared(),
        '$_root/es/experience.json': _texts('Dev', includeByto: false),
      });

      await expectLater(
        repository.getExperience(ContentLanguage.es),
        throwsA(isA<InvalidContent>()),
      );
    });

    test('a missing shared file is ContentNotFound', () async {
      await expectLater(
        _repository({}).getExperience(ContentLanguage.es),
        throwsA(isA<ContentNotFound>()),
      );
    });
  });

  test('experienceProvider uses the overridden repository', () async {
    final container = ProviderContainer(
      overrides: [
        experienceRepositoryProvider.overrideWithValue(
          _FakeRepository([_entry('b', 2), _entry('a', 1)]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final entries = await container.read(
      experienceProvider(ContentLanguage.es).future,
    );

    expect(entries.map((e) => e.id), ['a', 'b']);
  });
}
