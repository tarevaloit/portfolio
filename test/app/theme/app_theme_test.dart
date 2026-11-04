import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio/app/theme/app_theme.dart';
import 'package:portfolio/core/design_system/design_system.dart';

void main() {
  group('AppTheme.dark', () {
    test('uses the background and surface tokens', () {
      final theme = AppTheme.dark();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.outline, AppColors.border);
      expect(theme.colorScheme.onSurface, AppColors.textPrimary);
    });

    test('defaults the accent to lime and uses it for the domain layer', () {
      final theme = AppTheme.dark();
      final layers = theme.extension<AppLayerColors>()!;

      expect(theme.colorScheme.primary, AppColors.accentLime);
      expect(layers.domain, AppColors.accentLime);
      expect(layers.presentation, AppColors.layerPresentation);
      expect(layers.data, AppColors.layerData);
    });

    test('a custom accent propagates to primary and the domain layer', () {
      const accent = Color(0xFFFF4D8D);
      final theme = AppTheme.dark(accent: accent);

      expect(theme.colorScheme.primary, accent);
      expect(theme.extension<AppLayerColors>()!.domain, accent);
    });

    test('uses Bricolage for text and JetBrains Mono for labels', () {
      final textTheme = AppTheme.dark().textTheme;

      expect(textTheme.displayLarge!.fontFamily, AppTypography.display);
      expect(textTheme.bodyLarge!.fontFamily, AppTypography.display);
      expect(textTheme.labelMedium!.fontFamily, AppTypography.mono);
      expect(textTheme.labelSmall!.fontFamily, AppTypography.mono);
    });
  });

  test('AppLayerColors.lerp interpolates every layer', () {
    final a = AppLayerColors.fromAccent(const Color(0xFF000000));
    const b = AppLayerColors(
      presentation: Color(0xFFFFFFFF),
      domain: Color(0xFFFFFFFF),
      data: Color(0xFFFFFFFF),
    );

    expect(a.lerp(b, 1).domain, b.domain);
    expect(a.lerp(b, 0).domain, a.domain);
    expect(a.lerp(null, 0.5), a);
  });
}
