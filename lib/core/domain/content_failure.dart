/// Errors raised while loading site content.
///
/// Repositories throw these; use cases let them through and the
/// presentation layer turns them into error states.
sealed class ContentFailure implements Exception {
  const ContentFailure(this.message);

  final String message;

  @override
  String toString() => 'ContentFailure: $message';
}

/// The requested piece of content does not exist (for example an unknown
/// project slug).
final class ContentNotFound extends ContentFailure {
  const ContentNotFound(super.message);
}

/// A content file exists but cannot be parsed or is missing required data.
final class InvalidContent extends ContentFailure {
  const InvalidContent(this.source, String details)
    : super('$source: $details');

  /// Asset path of the broken file.
  final String source;
}
