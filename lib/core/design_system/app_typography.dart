import 'package:flutter/material.dart';

/// Typography tokens.
///
/// Both families are bundled as variable fonts in `assets/fonts/`, so the
/// weight (and optical size for Bricolage) is also passed as a
/// [FontVariation]; on the web renderers `fontWeight` alone does not move
/// the variable axes.
abstract final class AppTypography {
  static const String display = 'BricolageGrotesque';
  static const String mono = 'JetBrainsMono';

  /// Bricolage Grotesque: display and body text.
  static TextStyle sans({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    double letterSpacing = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: display,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontVariations: [
        FontVariation.weight(weight.value.toDouble()),
        // The opsz axis of Bricolage goes from 12 to 96.
        FontVariation.opticalSize(size.clamp(12, 96).toDouble()),
      ],
    );
  }

  /// JetBrains Mono: labels, metadata and code.
  static TextStyle monoStyle({
    required double size,
    FontWeight weight = FontWeight.w400,
    double? height,
    double letterSpacing = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: mono,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
    );
  }

  /// Base text theme. Responsive scaling of the display sizes is handled by
  /// the sections themselves (Phase 3).
  static TextTheme textTheme({
    required Color primary,
    required Color secondary,
    required Color muted,
  }) {
    return TextTheme(
      displayLarge: sans(
        size: 88,
        weight: FontWeight.w800,
        height: 0.95,
        letterSpacing: -3.5,
        color: primary,
      ),
      displayMedium: sans(
        size: 64,
        weight: FontWeight.w800,
        height: 1,
        letterSpacing: -2.5,
        color: primary,
      ),
      displaySmall: sans(
        size: 48,
        weight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -1.8,
        color: primary,
      ),
      headlineMedium: sans(
        size: 32,
        weight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1,
        color: primary,
      ),
      titleLarge: sans(
        size: 22,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: primary,
      ),
      titleMedium: sans(
        size: 17,
        weight: FontWeight.w600,
        height: 1.3,
        color: primary,
      ),
      bodyLarge: sans(size: 18, height: 1.6, color: secondary),
      bodyMedium: sans(size: 15, height: 1.6, color: secondary),
      bodySmall: sans(size: 13, height: 1.5, color: muted),
      labelLarge: sans(
        size: 15,
        weight: FontWeight.w600,
        height: 1.2,
        color: primary,
      ),
      labelMedium: monoStyle(size: 13, height: 1.4, color: secondary),
      labelSmall: monoStyle(size: 11, height: 1.4, color: muted),
    );
  }
}
