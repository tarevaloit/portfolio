import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:portfolio/core/content/content_retry.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/about/domain/entities/about_info.dart';
import 'package:portfolio/features/about/domain/repositories/about_repository.dart';
import 'package:portfolio/features/about/domain/usecases/get_about_info.dart';

/// Repository contract, overridden in `lib/app/di/`.
final aboutRepositoryProvider = Provider<AboutRepository>(
  (ref) => throw UnimplementedError(
    'aboutRepositoryProvider must be overridden in lib/app/di.',
  ),
  name: 'aboutRepositoryProvider',
);

final getAboutInfoProvider = Provider<GetAboutInfo>(
  (ref) => GetAboutInfo(ref.watch(aboutRepositoryProvider)),
  name: 'getAboutInfoProvider',
);

/// "Sobre mí" content for the language.
final FutureProviderFamily<AboutInfo, ContentLanguage> aboutInfoProvider =
    FutureProvider.family<AboutInfo, ContentLanguage>(
      (ref, language) => ref.watch(getAboutInfoProvider)(language),
      retry: contentRetry,
      name: 'aboutInfoProvider',
    );
