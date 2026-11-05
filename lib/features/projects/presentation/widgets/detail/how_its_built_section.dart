import 'package:flutter/material.dart';
import 'package:portfolio/core/architecture_mode/architecture_map.dart';
import 'package:portfolio/core/architecture_mode/layer_badge.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/feature_code.dart';

/// "Cómo está hecho": the three layers of one feature, with their real
/// class names, then its code by file and the tree of its files.
class HowItsBuiltSection extends StatelessWidget {
  const HowItsBuiltSection({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final size = ScreenSize.of(context);
    final layerColors = AppLayerColors.of(context);
    final architecture = project.architecture;
    final snippets = project.snippets;

    final title = Semantics(
      header: true,
      child: Text(
        l10n.detailHowItsBuilt,
        style: size.isCompact
            ? theme.textTheme.displaySmall
            : theme.textTheme.displayMedium,
      ),
    );
    final feature = Text(
      l10n.detailFeature(architecture.feature),
      style: theme.textTheme.labelMedium,
    );

    final cards = [
      LayerCard(
        name: l10n.layerPresentation,
        color: layerColors.presentation,
        detail: architecture.presentation,
      ),
      LayerCard(
        name: l10n.layerDomain,
        color: layerColors.domain,
        detail: architecture.domain,
      ),
      LayerCard(
        name: l10n.layerData,
        color: layerColors.data,
        detail: architecture.data,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevealOnScroll(
          child: size.isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: AppSpacing.sm),
                    feature,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: title),
                    feature,
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        RevealOnScroll(
          child: size.isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    cards[0],
                    const _Arrow(vertical: true),
                    cards[1],
                    const _Arrow(vertical: true),
                    cards[2],
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: cards[0]),
                      const _Arrow(vertical: false),
                      Expanded(child: cards[1]),
                      const _Arrow(vertical: false),
                      Expanded(child: cards[2]),
                    ],
                  ),
                ),
        ),
        if (snippets.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          RevealOnScroll(
            child: LayerBadge(
              chain: ArchitectureMap.codeBlock,
              child: FeatureCode(snippets: snippets, files: project.files),
            ),
          ),
        ],
      ],
    );
  }
}

/// One layer: folder name in the layer color, class names and its role.
class LayerCard extends StatelessWidget {
  const LayerCard({
    required this.name,
    required this.color,
    required this.detail,
    super.key,
  });

  final String name;
  final Color color;
  final LayerDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: AppTypography.monoStyle(size: 14, color: color)),
          const SizedBox(height: AppSpacing.md),
          for (final className in detail.classes)
            Text(
              className,
              style: AppTypography.monoStyle(
                size: 15,
                height: 1.7,
                color: theme.colorScheme.onSurface,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(detail.description, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.vertical});

  final bool vertical;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: vertical
            ? const EdgeInsets.symmetric(vertical: AppSpacing.sm)
            : const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Center(
          child: Text(
            vertical ? '↓' : '→',
            style: AppTypography.monoStyle(
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Technical decisions of the project, numbered.
class DecisionsSection extends StatelessWidget {
  const DecisionsSection({required this.decisions, super.key});

  final List<TechDecision> decisions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = ScreenSize.of(context).isCompact;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.detailDecisions,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ResponsiveGrid(
          columns: compact ? 1 : decisions.length.clamp(1, 3),
          children: [
            for (final (index, decision) in decisions.indexed)
              RevealOnScroll(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg + 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: AppRadii.mdAll,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (index + 1).toString().padLeft(2, '0'),
                        style: theme.textTheme.labelSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(decision.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(decision.body, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
