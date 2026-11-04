import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:portfolio/core/design_system/motion/motion.dart';

/// Staggered entrance (fade + slide up) for the [index]-th item of a group.
///
/// With reduced motion the child is returned untouched.
class Entrance extends StatelessWidget {
  const Entrance({required this.index, required this.child, super.key});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return child;
    return child
        .animate(delay: AppMotion.stagger * index)
        .fadeIn(duration: AppMotion.medium, curve: AppMotion.emphasized)
        .slideY(
          begin: 0.25,
          end: 0,
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
        );
  }
}
