import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/experience/domain/entities/experience.dart';
import 'package:portfolio/features/experience/presentation/providers/experience_providers.dart';

/// "Experiencia" timeline: one row per position, separated by rules.
class ExperienceSection extends ConsumerWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = AppLocale.of(context).contentLanguage;
    final experience = ref.watch(experienceProvider(language));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevealOnScroll(child: SectionHeader(title: l10n.experienceTitle)),
        const SizedBox(height: AppSpacing.xxl),
        experience.when(
          data: (entries) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(),
              for (final entry in entries) ...[
                RevealOnScroll(child: ExperienceRow(experience: entry)),
                const Divider(),
              ],
            ],
          ),
          loading: () => const SkeletonBox(height: 320),
          error: (_, _) => Text(
            l10n.experienceError,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

/// One position: period, company and role on the left; highlights on the
/// right (below on compact screens).
class ExperienceRow extends StatelessWidget {
  const ExperienceRow({required this.experience, super.key});

  final Experience experience;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final start =
        experience.startYear?.toString() ?? l10n.experienceYearUnknown;
    final end = experience.isCurrent
        ? l10n.experiencePresent
        : experience.endYear.toString();

    final meta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.experiencePeriod(start, end),
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(experience.company, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          experience.role,
          style: AppTypography.sans(
            size: 14,
            weight: FontWeight.w500,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );

    final highlights = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final highlight in experience.highlights)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              '→ $highlight',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: ScreenSize.of(context).isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                meta,
                const SizedBox(height: AppSpacing.lg),
                highlights,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 280, child: meta),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: highlights),
              ],
            ),
    );
  }
}
