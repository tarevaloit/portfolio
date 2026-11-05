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

    // A clear ring for keyboard focus on every button: the default Material
    // overlay is barely visible on the dark background.
    WidgetStateProperty<BorderSide?> focusRing(BorderSide rest) =>
        WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused)
              ? BorderSide(color: accent, width: 2)
              : rest,
        );
    final focusOverlay = WidgetStateProperty.resolveWith<Color?>(
      (states) => states.contains(WidgetState.focused)
          ? accent.withValues(alpha: 0.16)
          : null,
    );

    return ThemeData(
      useMaterial3: true,
      focusColor: accent.withValues(alpha: 0.24),
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
        style:
            FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: AppColors.onAccent,
              textStyle: textTheme.labelLarge,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg - 4,
                vertical: AppSpacing.md - 2,
              ),
              disabledBackgroundColor: AppColors.surfaceRaised,
              disabledForegroundColor: AppColors.textMuted,
            ).copyWith(
              // On the accent fill the ring is the text color, with a gap.
              side: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? const BorderSide(
                        color: AppColors.textPrimary,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      )
                    : null,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              textStyle: textTheme.labelLarge,
              shape: const StadiumBorder(),
              side: const BorderSide(color: AppColors.border),
              disabledForegroundColor: AppColors.textMuted,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg - 4,
                vertical: AppSpacing.md - 2,
              ),
            ).copyWith(
              side: focusRing(const BorderSide(color: AppColors.border)),
              overlayColor: focusOverlay,
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              textStyle: textTheme.labelMedium,
            ).copyWith(
              side: focusRing(BorderSide.none),
              overlayColor: focusOverlay,
            ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onAccent
              : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accent
              : AppColors.surfaceRaised,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.border),
      ),
      extensions: [AppLayerColors.fromAccent(accent)],
    );
  }
}
