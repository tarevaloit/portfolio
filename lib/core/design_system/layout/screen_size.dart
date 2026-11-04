import 'package:flutter/widgets.dart';

/// Responsive size classes. The site is checked at 360, 768, 1280 and
/// 1440 px wide.
enum ScreenSize {
  /// Phones: < 768 px.
  compact,

  /// Tablets and small laptops: 768–1279 px.
  medium,

  /// Desktops: ≥ 1280 px.
  expanded;

  static const double mediumMinWidth = 768;
  static const double expandedMinWidth = 1280;

  /// Max width of the page content (the mockup uses 1200 px at 1440).
  static const double maxContentWidth = 1200;

  static ScreenSize fromWidth(double width) {
    if (width >= expandedMinWidth) return ScreenSize.expanded;
    if (width >= mediumMinWidth) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static ScreenSize of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  bool get isCompact => this == ScreenSize.compact;

  /// Side padding of the page content.
  double get gutter => switch (this) {
    ScreenSize.compact => 20,
    ScreenSize.medium => 40,
    ScreenSize.expanded => 48,
  };

  /// Vertical space between home sections.
  double get sectionSpacing => switch (this) {
    ScreenSize.compact => 72,
    ScreenSize.medium => 96,
    ScreenSize.expanded => 120,
  };
}
