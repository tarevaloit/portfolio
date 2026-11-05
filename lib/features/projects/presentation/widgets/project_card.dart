import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_heroes.dart';

/// Project card of the home grid: colored cover with the monogram and the
/// badge, then name, category, summary and stack.
///
/// Lifts on hover and keyboard focus; Enter or Space activates it. The name
/// and the cover are Heroes that fly into the detail page.
class ProjectCard extends StatefulWidget {
  const ProjectCard({required this.project, this.onTap, super.key});

  final Project project;
  final VoidCallback? onTap;

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = widget.project;
    final lifted = (_hovered || _focused) && !context.reduceMotion;

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
        border: Border.all(
          color: _focused ? Color(project.color) : theme.colorScheme.outline,
          width: _focused ? 2 : 1,
        ),
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

    final onTap = widget.onTap;
    return Semantics(
      container: true,
      button: onTap != null,
      // Hover is tracked directly so the lift does not depend on the focus
      // highlight mode; the detector handles focus and Enter/Space.
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: FocusableActionDetector(
          enabled: onTap != null,
          mouseCursor: onTap == null
              ? MouseCursor.defer
              : SystemMouseCursors.click,
          onShowFocusHighlight: (value) => setState(() => _focused = value),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                onTap?.call();
                return null;
              },
            ),
          },
          child: GestureDetector(onTap: onTap, child: card),
        ),
      ),
    );
  }
}

class _Cover extends ConsumerWidget {
  const _Cover({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = ScreenSize.of(context).isCompact;
    final showLayers = ref.watch(architectureModeProvider);
    return SizedBox(
      height: compact ? 180 : 220,
      child: Stack(
        children: [
          Positioned.fill(
            child: ProjectCoverHero(
              slug: project.slug,
              color: Color(project.color),
              child: ColoredBox(color: Color(project.color)),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            bottom: project.logo == null ? AppSpacing.sm : AppSpacing.lg,
            child: ExcludeSemantics(
              child: project.logo == null
                  ? Text(
                      project.monogram,
                      style: AppTypography.sans(
                        size: compact ? 96 : 120,
                        weight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -6,
                        color: AppColors.background,
                      ),
                    )
                  : _Logo(asset: project.logo!, size: compact ? 88 : 104),
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
          // Architecture mode: the cover shows the real classes of each
          // layer of this project, from the content.
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: context.reduceMotion ? Duration.zero : AppMotion.medium,
              child: showLayers
                  ? _CoverLayers(project: project)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

/// App icon on the cover. No shadow: some icons are transparent, and a
/// box shadow would show as a dark square behind them.
class _Logo extends StatelessWidget {
  const _Logo({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) =>
            SizedBox.square(dimension: size),
      ),
    );
  }
}

class _CoverLayers extends StatelessWidget {
  const _CoverLayers({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final architecture = project.architecture;
    final layers = AppLayerColors.of(context);
    final rows = [
      (l10n.layerPresentation, layers.presentation, architecture.presentation),
      (l10n.layerDomain, layers.domain, architecture.domain),
      (l10n.layerData, layers.data, architecture.data),
    ];
    // Expand: AnimatedSwitcher lays its child out with loose constraints.
    return Semantics(
      label: l10n.projectLayers(project.name),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background.withValues(alpha: 0.9),
        // Three layers of up to two lines each fit the 180 px compact cover.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            for (final (name, color, detail) in rows)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: TextStyle(color: color),
                      ),
                      TextSpan(text: detail.classes.join(' · ')),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.monoStyle(
                    size: 11,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
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
              ProjectNameHero(
                slug: project.slug,
                child: Text(project.name, style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(project.category, style: theme.textTheme.labelSmall),
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ProjectNameHero(
                        slug: project.slug,
                        child: Text(
                          project.name,
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
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
