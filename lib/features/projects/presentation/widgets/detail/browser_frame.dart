import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// A plain browser window (title bar with the three dots) around a page.
///
/// The child is sized by [aspectRatio]: the screenshots are cropped below
/// the real browser bar, so they all share it.
class BrowserFrame extends StatelessWidget {
  const BrowserFrame({
    required this.child,
    this.aspectRatio = 16 / 9,
    super.key,
  });

  static const double barHeight = 32;

  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF050608),
        borderRadius: AppRadii.smAll,
        border: Border.all(color: colors.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadii.smAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: barHeight,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.md),
                  for (final color in const [
                    Color(0xFFFF5F57),
                    Color(0xFFFEBC2E),
                    Color(0xFF28C840),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const SizedBox.square(dimension: 10),
                      ),
                    ),
                ],
              ),
            ),
            AspectRatio(aspectRatio: aspectRatio, child: child),
          ],
        ),
      ),
    );
  }
}
