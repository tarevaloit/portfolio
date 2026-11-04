/// Languages the site content is written in.
///
/// Pure Dart on purpose: the domain layer cannot depend on Flutter's
/// `Locale`. The presentation layer maps its locale to this enum.
enum ContentLanguage {
  es,
  en;

  /// Language used when a piece of content is missing in another one.
  static const ContentLanguage fallback = ContentLanguage.es;

  /// ISO 639-1 code, also used as the content folder name.
  String get code => name;
}
