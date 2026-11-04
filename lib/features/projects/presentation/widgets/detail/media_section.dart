import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

/// Real images of the project (screenshots, diagrams, charts), each with
/// its caption, which is also its accessible label.
class MediaSection extends StatelessWidget {
  const MediaSection({required this.media, super.key});

  static const double maxImageWidth = 960;

  final List<ProjectMedia> media;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.detailMedia,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (final item in media)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: RevealOnScroll(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxImageWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadii.mdAll,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          child: Image.asset(
                            item.asset,
                            semanticLabel: item.caption,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const SkeletonBox(height: 240),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ExcludeSemantics(
                        child: Text(
                          item.caption,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
