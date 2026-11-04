import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/core/l10n/app_locale.dart';

void main() {
  group('AppLocale', () {
    test('Spanish is the default and lives at the root', () {
      expect(AppLocale.fallback, AppLocale.es);
      expect(AppLocale.es.homePath, '/');
      expect(AppLocale.es.path('/projects/fishar'), '/projects/fishar');
    });

    test('English lives under /en', () {
      expect(AppLocale.en.homePath, '/en');
      expect(AppLocale.en.path('/projects/fishar'), '/en/projects/fishar');
    });

    test('fromPath resolves the locale from the URL', () {
      expect(AppLocale.fromPath('/'), AppLocale.es);
      expect(AppLocale.fromPath('/projects/fishar'), AppLocale.es);
      expect(AppLocale.fromPath('/en'), AppLocale.en);
      expect(AppLocale.fromPath('/en/projects/fishar'), AppLocale.en);
      expect(AppLocale.fromPath('/english'), AppLocale.es);
    });

    test('every locale maps to its content language', () {
      expect(AppLocale.es.contentLanguage, ContentLanguage.es);
      expect(AppLocale.en.contentLanguage, ContentLanguage.en);
    });

    test('other switches between the two languages', () {
      expect(AppLocale.es.other, AppLocale.en);
      expect(AppLocale.en.other, AppLocale.es);
    });
  });
}
