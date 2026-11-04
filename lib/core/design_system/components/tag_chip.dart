import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/app_typography.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';

/// Small monospace pill used for stack tags.
class TagChip extends StatelessWidget {
  const TagChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.pillAll,
        border: Border.all(color: colors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: AppTypography.monoStyle(
            size: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
