import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:portfolio/core/content/content_retry.dart';
import 'package:portfolio/core/domain/domain.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/domain/repositories/experience_repository.dart';
import 'package:portfolio/features/experience/domain/usecases/get_experience.dart';

/// Repository contract, overridden in `lib/app/di/`.
final experienceRepositoryProvider = Provider<ExperienceRepository>(
  (ref) => throw UnimplementedError(
    'experienceRepositoryProvider must be overridden in lib/app/di.',
  ),
  name: 'experienceRepositoryProvider',
);

final getExperienceProvider = Provider<GetExperience>(
  (ref) => GetExperience(ref.watch(experienceRepositoryProvider)),
  name: 'getExperienceProvider',
);

/// Sorted experience timeline.
final FutureProviderFamily<List<Experience>, ContentLanguage>
experienceProvider = FutureProvider.family<List<Experience>, ContentLanguage>(
  (ref, language) => ref.watch(getExperienceProvider)(language),
  retry: contentRetry,
  name: 'experienceProvider',
);
