import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/app_typography.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';

/// "Skip to content" link for keyboard users: the first stop of the Tab
/// order, invisible until it gets focus. Screen readers always see it.
///
/// Place it in a `Stack` so showing it never moves the layout.
class SkipLink extends StatefulWidget {
  const SkipLink({required this.label, required this.onActivate, super.key});

  final String label;
  final VoidCallback onActivate;

  @override
  State<SkipLink> createState() => _SkipLinkState();
}

class _SkipLinkState extends State<SkipLink> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: Opacity(
        opacity: _focused ? 1 : 0,
        child: FilledButton(
          onPressed: widget.onActivate,
          style: FilledButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: AppColors.onAccent,
            textStyle: AppTypography.monoStyle(
              size: 13,
              weight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}
