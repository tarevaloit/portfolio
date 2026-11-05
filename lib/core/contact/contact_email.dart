import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contact email of the site owner, for features that need to offer it
/// without depending on the contact feature (asking for access to a
/// private repository, for one). `null` while there is none.
///
/// `lib/app/di/` overrides it with the email from the contact content.
final contactEmailProvider = FutureProvider<String?>(
  (ref) async => null,
  name: 'contactEmailProvider',
);

/// `mailto:` link to [email] with [subject] already filled in.
///
/// Built by hand because `Uri.queryParameters` encodes spaces as `+`, which
/// some mail clients show literally.
Uri mailtoWithSubject(String email, String subject) =>
    Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');
