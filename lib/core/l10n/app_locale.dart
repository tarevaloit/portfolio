import 'package:flutter/widgets.dart';
import 'package:portfolio/core/domain/domain.dart';

/// Locales supported by the site and how they map to URLs.
///
/// Spanish is the default and lives at the root (`/`, `/projects/...`).
/// English lives under `/en` (`/en`, `/en/projects/...`).
enum AppLocale {
  es(Locale('es'), ''),
  en(Locale('en'), '/en');

  const AppLocale(this.locale, this.pathPrefix);

  final Locale locale;

  /// URL prefix for this locale; empty for the default one.
  final String pathPrefix;

  static const AppLocale fallback = AppLocale.es;

  /// Home URL for this locale.
  String get homePath => pathPrefix.isEmpty ? '/' : pathPrefix;

  /// Builds a URL for this locale from a root-relative [subpath]
  /// (for example `/projects/fishar`).
  String path(String subpath) {
    assert(subpath.startsWith('/'), 'subpath must start with "/"');
    return '$pathPrefix$subpath';
  }

  /// Content language used to ask the domain layer for texts.
  ContentLanguage get contentLanguage => ContentLanguage.values.byName(name);

  /// The locale that the language switch links to.
  AppLocale get other => this == AppLocale.es ? AppLocale.en : AppLocale.es;

  /// Resolves the locale from a URL path. Unknown prefixes fall back to
  /// Spanish.
  static AppLocale fromPath(String path) {
    for (final locale in values) {
      final prefix = locale.pathPrefix;
      if (prefix.isEmpty) continue;
      if (path == prefix || path.startsWith('$prefix/')) return locale;
    }
    return fallback;
  }

  /// Locale active in the widget tree under [context].
  static AppLocale of(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return values.firstWhere(
      (locale) => locale.locale.languageCode == languageCode,
      orElse: () => fallback,
    );
  }
}
