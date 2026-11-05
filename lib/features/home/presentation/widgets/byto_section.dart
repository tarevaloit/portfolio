import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/router/app_router.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';

/// Byto Apps ("By To Apps", made by Toby): what it is, how each idea is
/// carried out, and the apps, each one opening its page.
class BytoSection extends ConsumerWidget {
  const BytoSection({super.key});

  /// Below this width the steps go under the text.
  static const double sideBySideMinWidth = 900;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final language = AppLocale.of(context).contentLanguage;
    final apps = [
      for (final project
          in ref.watch(projectsProvider(language)).value ?? const <Project>[])
        if (project.logo != null && project.slug != 'portfolio') project,
    ];

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.bytoEyebrow, style: theme.textTheme.labelMedium),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: l10n.bytoTitle),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.bytoLead,
          style: AppTypography.sans(
            size: 22,
            weight: FontWeight.w600,
            height: 1.4,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Text(l10n.bytoBody, style: theme.textTheme.bodyLarge),
        ),
        if (apps.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.bytoApps, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [for (final app in apps) _AppLink(project: app)],
          ),
        ],
      ],
    );

    final steps = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, (title, body)) in [
          (l10n.bytoStepIdeaTitle, l10n.bytoStepIdeaBody),
          (l10n.bytoStepBuildTitle, l10n.bytoStepBuildBody),
          (l10n.bytoStepShipTitle, l10n.bytoStepShipBody),
        ].indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm),
          _Step(number: index + 1, title: title, body: body),
        ],
      ],
    );

    return RevealOnScroll(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < sideBySideMinWidth) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                intro,
                const SizedBox(height: AppSpacing.xl),
                steps,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: intro),
              const SizedBox(width: AppSpacing.xxl),
              Expanded(flex: 5, child: steps),
            ],
          );
        },
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title, required this.body});

  final int number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number.toString().padLeft(2, '0'),
            style: AppTypography.monoStyle(
              size: 14,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo and name of an app; opens its page.
class _AppLink extends StatelessWidget {
  const _AppLink({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      link: true,
      label: project.name,
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.pillAll,
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        child: InkWell(
          onTap: () => context.go(
            AppRoutes.projectPath(AppLocale.of(context), project.slug),
          ),
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, AppSpacing.md, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    project.logo!,
                    width: 28,
                    height: 28,
                    excludeFromSemantics: true,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: Color(project.color),
                      child: const SizedBox.square(dimension: 28),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${project.name} →',
                  style: AppTypography.sans(
                    size: 14,
                    weight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
