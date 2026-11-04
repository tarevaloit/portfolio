import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// Builds the app [ThemeData] from the design tokens.
abstract final class AppTheme {
  /// Dark theme from the mockup. [accent] defaults to lime and also drives
  /// the domain layer color.
  static ThemeData dark({Color accent = AppColors.accentLime}) {
    final colorScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: AppColors.onAccent,
      secondary: accent,
      onSecondary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceRaised,
      surfaceContainerHighest: AppColors.surfaceRaised,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
    );

    final textTheme = AppTypography.textTheme(
      primary: AppColors.textPrimary,
      secondary: AppColors.textSecondary,
      muted: AppColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.border,
      fontFamily: AppTypography.display,
      textTheme: textTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withValues(alpha: 0.3),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: textTheme.labelLarge,
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: textTheme.labelMedium,
        ),
      ),
      extensions: [AppLayerColors.fromAccent(accent)],
    );
  }
}
