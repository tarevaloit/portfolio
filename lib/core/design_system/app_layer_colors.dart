import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/tokens/app_colors.dart';

/// Colors for the three clean-architecture layers, exposed as a
/// [ThemeExtension] so they follow the configured accent.
@immutable
class AppLayerColors extends ThemeExtension<AppLayerColors> {
  const AppLayerColors({
    required this.presentation,
    required this.domain,
    required this.data,
  });

  /// Default layer colors; `domain` mirrors the given [accent].
  factory AppLayerColors.fromAccent(Color accent) => AppLayerColors(
    presentation: AppColors.layerPresentation,
    domain: accent,
    data: AppColors.layerData,
  );

  final Color presentation;
  final Color domain;
  final Color data;

  static AppLayerColors of(BuildContext context) =>
      Theme.of(context).extension<AppLayerColors>()!;

  @override
  AppLayerColors copyWith({Color? presentation, Color? domain, Color? data}) {
    return AppLayerColors(
      presentation: presentation ?? this.presentation,
      domain: domain ?? this.domain,
      data: data ?? this.data,
    );
  }

  @override
  AppLayerColors lerp(covariant AppLayerColors? other, double t) {
    if (other == null) return this;
    return AppLayerColors(
      presentation: Color.lerp(presentation, other.presentation, t)!,
      domain: Color.lerp(domain, other.domain, t)!,
      data: Color.lerp(data, other.data, t)!,
    );
  }
}
