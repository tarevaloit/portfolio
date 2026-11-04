import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:portfolio/core/content/content_retry.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/domain/repositories/contact_repository.dart';
import 'package:portfolio/features/contact/domain/usecases/get_contact_info.dart';

/// Repository contract, overridden in `lib/app/di/`.
final contactRepositoryProvider = Provider<ContactRepository>(
  (ref) => throw UnimplementedError(
    'contactRepositoryProvider must be overridden in lib/app/di.',
  ),
  name: 'contactRepositoryProvider',
);

final getContactInfoProvider = Provider<GetContactInfo>(
  (ref) => GetContactInfo(ref.watch(contactRepositoryProvider)),
  name: 'getContactInfoProvider',
);

/// Contact channels for the language.
final FutureProviderFamily<ContactInfo, ContentLanguage> contactInfoProvider =
    FutureProvider.family<ContactInfo, ContentLanguage>(
      (ref, language) => ref.watch(getContactInfoProvider)(language),
      retry: contentRetry,
      name: 'contactInfoProvider',
    );
