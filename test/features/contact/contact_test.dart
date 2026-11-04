import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/contact/data/datasources/contact_local_data_source.dart';
import 'package:portfolio/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';

import '../../helpers/in_memory_content_reader.dart';

const _path = 'assets/content/contact.json';

ContactRepositoryImpl _repository(Map<String, Object> files) =>
    ContactRepositoryImpl(ContactLocalDataSource(InMemoryContentReader(files)));

class _FakeRepository implements ContactRepository {
  @override
  Future<ContactInfo> getContactInfo(ContentLanguage language) async =>
      ContactInfo(email: 'test@example.com', cvAssetPath: language.code);
}

void main() {
  group('ContactInfo', () {
    test('mailto is built from the email', () {
      expect(
        const ContactInfo(email: 'test@example.com').mailto,
        Uri.parse('mailto:test@example.com'),
      );
      expect(const ContactInfo().mailto, isNull);
    });
  });

  group('ContactRepositoryImpl', () {
    test('reads every channel and the CV of the language', () async {
      final repository = _repository({
        _path: {
          'email': 'test@example.com',
          'github': 'https://github.com/example',
          'linkedin': 'https://www.linkedin.com/in/example',
          'cv': {'es': 'assets/cv/es.pdf', 'en': 'assets/cv/en.pdf'},
        },
      });

      final info = await repository.getContactInfo(ContentLanguage.en);

      expect(info.email, 'test@example.com');
      expect(info.github, Uri.parse('https://github.com/example'));
      expect(info.linkedin?.host, 'www.linkedin.com');
      expect(info.cvAssetPath, 'assets/cv/en.pdf');
    });

    test('missing values stay null and the CV falls back to Spanish', () async {
      final repository = _repository({
        _path: {
          'email': null,
          'cv': {'es': 'assets/cv/es.pdf', 'en': null},
        },
      });

      final info = await repository.getContactInfo(ContentLanguage.en);

      expect(info.email, isNull);
      expect(info.github, isNull);
      expect(info.cvAssetPath, 'assets/cv/es.pdf');
    });

    test('a missing file is ContentNotFound', () async {
      await expectLater(
        _repository({}).getContactInfo(ContentLanguage.es),
        throwsA(isA<ContentNotFound>()),
      );
    });
  });

  test('contactInfoProvider uses the overridden repository', () async {
    final container = ProviderContainer(
      overrides: [
        contactRepositoryProvider.overrideWithValue(_FakeRepository()),
      ],
    );
    addTearDown(container.dispose);

    final info = await container.read(
      contactInfoProvider(ContentLanguage.en).future,
    );

    expect(info.cvAssetPath, 'en');
  });
}
