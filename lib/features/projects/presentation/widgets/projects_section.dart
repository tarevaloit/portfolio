import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/architecture_mode/architecture_map.dart';
import 'package:portfolio/core/architecture_mode/layer_badge.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/router/app_router.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_card.dart';

/// "Proyectos (04)" section with the responsive grid of cards.
class ProjectsSection extends ConsumerWidget {
  const ProjectsSection({super.key});

  static const int _skeletonCount = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = AppLocale.of(context).contentLanguage;
    final projects = ref.watch(projectsProvider(language));
    final columns = ScreenSize.of(context).isCompact ? 1 : 2;
    final count = projects.value?.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevealOnScroll(
          child: SectionHeader(
            title: l10n.projectsTitle,
            count: count == null
                ? null
                : l10n.projectsCount(count.toString().padLeft(2, '0')),
            note: l10n.projectsTip,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        projects.when(
          data: (projects) => ResponsiveGrid(
            columns: columns,
            children: [
              for (final (index, project) in projects.indexed)
                RevealOnScroll(
                  delay: AppMotion.stagger * (index % columns),
                  child: LayerBadge(
                    chain: ArchitectureMap.projectCard,
                    child: ProjectCard(
                      project: project,
                      onTap: () => context.go(
                        AppRoutes.projectPath(
                          AppLocale.of(context),
                          project.slug,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          loading: () => ResponsiveGrid(
            columns: columns,
            children: [
              for (var i = 0; i < _skeletonCount; i++)
                const SkeletonBox(height: 420),
            ],
          ),
          error: (_, _) => Text(
            l10n.projectsError,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
