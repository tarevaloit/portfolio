import 'package:portfolio/core/domain/domain.dart';

/// Riverpod retry policy for content providers.
///
/// A [ContentFailure] (missing or broken file) will not fix itself, so it is
/// not retried. Anything else is retried up to 3 times with backoff.
Duration? contentRetry(int retryCount, Object error) {
  if (error is ContentFailure || retryCount >= 3) return null;
  return Duration(milliseconds: 200 * (1 << retryCount));
}
