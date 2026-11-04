import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

/// Project card of the home grid: colored cover with the monogram and the
/// badge, then name, category, summary and stack.
///
/// Lifts on hover. [onTap] is wired in Phase 4 (detail page).
class ProjectCard extends StatefulWidget {
  const ProjectCard({required this.project, this.onTap, super.key});

  final Project project;
  final VoidCallback? onTap;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = widget.project;
    final lifted = _hovered && !context.reduceMotion;

    final card = AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.emphasized,
      transform: Matrix4.translationValues(0, lifted ? -6 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: AppRadii.mdAll,
        boxShadow: [
          if (lifted)
            BoxShadow(
              color: Color(project.color).withValues(alpha: 0.18),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: ClipRRect(
        borderRadius: AppRadii.mdAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Cover(project: project),
            Expanded(child: _Body(project: project)),
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      button: widget.onTap != null,
      child: MouseRegion(
        cursor: widget.onTap == null
            ? MouseCursor.defer
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(onTap: widget.onTap, child: card),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final compact = ScreenSize.of(context).isCompact;
    return Container(
      height: compact ? 180 : 220,
      color: Color(project.color),
      child: Stack(
        children: [
          Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.sm,
            child: ExcludeSemantics(
              child: Text(
                project.monogram,
                style: AppTypography.sans(
                  size: compact ? 96 : 120,
                  weight: FontWeight.w800,
                  height: 1,
                  letterSpacing: -6,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: AppRadii.pillAll,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                child: Text(
                  project.badge,
                  style: AppTypography.monoStyle(
                    size: 11,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ScreenSize.of(context).isCompact) ...[
              Text(project.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.xxs),
              Text(project.category, style: theme.textTheme.labelSmall),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      project.category,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(project.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [for (final tag in project.stack) TagChip(label: tag)],
            ),
          ],
        ),
      ),
    );
  }
}
