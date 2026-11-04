import 'dart:ui';

/// Raw color tokens from the design spec (PLAN.md › Diseño › Tokens).
///
/// Widgets should read colors from the theme (`Theme.of(context)` and
/// `AppLayerColors`) instead of using these constants directly, so the
/// accent stays configurable.
abstract final class AppColors {
  // Backgrounds and surfaces.
  static const Color background = Color(0xFF0E0F12);
  static const Color surface = Color(0xFF131519);
  static const Color surfaceRaised = Color(0xFF17191E);
  static const Color border = Color(0xFF22252B);

  // Text.
  static const Color textPrimary = Color(0xFFECEAE4);
  static const Color textSecondary = Color(0xFFB9B8B1);
  static const Color textMuted = Color(0xFF9A9A93);

  // Accent (default; configurable through `AppTheme.dark(accent:)`).
  static const Color accentLime = Color(0xFFC6F432);
  static const Color onAccent = Color(0xFF0E0F12);

  // Architecture layers. The domain layer uses the accent color.
  static const Color layerPresentation = Color(0xFF7DD3FC);
  static const Color layerData = Color(0xFFFDBA74);
}
