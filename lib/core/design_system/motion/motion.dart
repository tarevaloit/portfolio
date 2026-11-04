import 'package:flutter/widgets.dart';

/// Motion helpers shared by every animated widget.
extension MotionContext on BuildContext {
  /// True when the platform asks to reduce motion. Every animation in the
  /// site checks this and renders its final state instead.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 700);

  /// Delay between items of a staggered entrance.
  static const Duration stagger = Duration(milliseconds: 90);

  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
}
