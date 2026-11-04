import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/app_typography.dart';
import 'package:portfolio/core/design_system/layout/screen_size.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';

/// Section title ("Proyectos (04)") with an optional note on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.count, this.note, super.key});

  final String title;

  /// Already formatted, e.g. `(04)`.
  final String? count;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = ScreenSize.of(context);
    final titleStyle = size.isCompact
        ? theme.textTheme.displaySmall
        : theme.textTheme.displayMedium;

    final heading = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: title),
          if (count != null)
            TextSpan(
              text: ' $count',
              style: AppTypography.monoStyle(
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      style: titleStyle,
    );

    final noteWidget = note == null
        ? null
        : Text(note!, style: theme.textTheme.labelSmall);

    if (noteWidget == null) {
      return Semantics(header: true, child: heading);
    }
    if (size.isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: heading),
          const SizedBox(height: AppSpacing.sm),
          noteWidget,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Semantics(header: true, child: heading)),
        const SizedBox(width: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: noteWidget,
        ),
      ],
    );
  }
}
