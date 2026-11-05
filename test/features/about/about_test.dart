import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/about/data/datasources/about_local_data_source.dart';
import 'package:portfolio/features/about/data/repositories/about_repository_impl.dart';
import 'package:portfolio/features/about/domain/entities/about_info.dart';
import 'package:portfolio/features/about/domain/repositories/about_repository.dart';
import 'package:portfolio/features/about/presentation/providers/about_providers.dart';
import 'package:portfolio/features/about/presentation/widgets/about_section.dart';

import '../../helpers/in_memory_content_reader.dart';
import '../../helpers/pump_localized.dart';

const _root = 'assets/content';

AboutRepositoryImpl _repository(Map<String, Object> files) =>
    AboutRepositoryImpl(AboutLocalDataSource(InMemoryContentReader(files)));

class _FakeRepository implements AboutRepository {
  _FakeRepository(this.info);

  final AboutInfo info;

  @override
  Future<AboutInfo> getAboutInfo(ContentLanguage language) async => info;
}

void main() {
  group('AboutRepositoryImpl', () {
    test('merges the photo with the texts of the language', () async {
      final repository = _repository({
        '$_root/about.json': {'photo': 'assets/about/me.webp'},
        '$_root/en/about.json': {
          'paragraphs': ['Hi'],
          'facts': [
            {'label': 'Location', 'value': 'Buenos Aires'},
          ],
        },
      });

      final info = await repository.getAboutInfo(ContentLanguage.en);

      expect(info.photo, 'assets/about/me.webp');
      expect(info.paragraphs, ['Hi']);
      expect(info.facts.single.value, 'Buenos Aires');
    });

    test('falls back to Spanish', () async {
      final repository = _repository({
        '$_root/about.json': <String, Object>{},
        '$_root/es/about.json': {
          'paragraphs': ['Hola'],
        },
      });

      final info = await repository.getAboutInfo(ContentLanguage.en);

      expect(info.paragraphs, ['Hola']);
      expect(info.photo, isNull);
    });

    test('without texts it is InvalidContent', () async {
      await expectLater(
        _repository({
          '$_root/about.json': <String, Object>{},
        }).getAboutInfo(ContentLanguage.es),
        throwsA(isA<InvalidContent>()),
      );
    });
  });

  group('AboutSection', () {
    const info = AboutInfo(
      paragraphs: ['Desarrollador mobile.', 'Segundo párrafo.'],
      facts: [AboutFact(label: 'Idiomas', value: 'Español · Inglés')],
    );

    testWidgets('shows paragraphs and facts', (tester) async {
      await tester.pumpLocalized(
        const AboutSection(),
        overrides: [
          aboutRepositoryProvider.overrideWithValue(_FakeRepository(info)),
        ],
      );
      await tester.pump();

      expect(find.text('Sobre mí'), findsOneWidget);
      expect(find.text('Desarrollador mobile.'), findsOneWidget);
      expect(find.text('IDIOMAS'), findsOneWidget);
      expect(find.text('Español · Inglés'), findsOneWidget);
    });

    testWidgets('puts the photo above the text on phones', (tester) async {
      await tester.pumpLocalized(
        const AboutSection(),
        size: const Size(360, 800),
        locale: AppLocale.en,
        overrides: [
          aboutRepositoryProvider.overrideWithValue(
            _FakeRepository(
              info.copyWith(photo: 'assets/about/tobias-arevalo.webp'),
            ),
          ),
        ],
      );
      await tester.pump();

      final photo = tester.getRect(find.byType(ClipOval));
      final text = tester.getRect(find.text('Desarrollador mobile.'));
      expect(photo.bottom, lessThanOrEqualTo(text.top));
      expect(find.text('About me'), findsOneWidget);
    });
  });
}
