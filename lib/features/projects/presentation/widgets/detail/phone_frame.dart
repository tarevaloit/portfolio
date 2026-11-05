import 'package:flutter/material.dart';

/// Phone bezel around a mini app. The screen is about 280×600 at the
/// default width.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({required this.child, this.width = defaultWidth, super.key});

  static const double defaultWidth = 300;
  static const double aspectRatio = 1 / 2.06;
  static const double bezel = 10;
  static const double radius = 48;

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width / aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF050608),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 48,
              offset: Offset(0, 24),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(bezel),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius - bezel),
            child: child,
          ),
        ),
      ),
    );
  }
}
