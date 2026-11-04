import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// The three floating "blueprint" plates of the hero: presentation, domain
/// and data, stacked with a small overlap. They bob gently unless reduced
/// motion is on.
class LayerPlates extends StatefulWidget {
  const LayerPlates({this.width = 300, super.key});

  final double width;

  static const double plateHeight = 104;
  static const double step = 98;

  @override
  State<LayerPlates> createState() => _LayerPlatesState();
}

class _LayerPlatesState extends State<LayerPlates>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _float
        ..stop()
        ..value = 0;
    } else if (!_float.isAnimating) {
      _float.repeat().ignore();
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final layers = AppLayerColors.of(context);

    // Painted bottom-up so presentation sits on top, as in the mockup.
    final plates = [
      (2, l10n.layerData, l10n.layerDataItems, layers.data),
      (1, l10n.layerDomain, l10n.layerDomainItems, layers.domain),
      (
        0,
        l10n.layerPresentation,
        l10n.layerPresentationItems,
        layers.presentation,
      ),
    ];

    return SizedBox(
      width: widget.width,
      height: LayerPlates.plateHeight + LayerPlates.step * 2,
      child: AnimatedBuilder(
        animation: _float,
        builder: (context, _) => Stack(
          children: [
            for (final (index, name, items, color) in plates)
              Positioned(
                top: LayerPlates.step * index + _offset(index),
                left: 0,
                right: 0,
                height: LayerPlates.plateHeight,
                child: _Plate(name: name, items: items, color: color),
              ),
          ],
        ),
      ),
    );
  }

  /// Vertical bob of ±4 px, each plate out of phase with the others.
  double _offset(int index) {
    final phase = _float.value * 2 * math.pi + index * math.pi * 2 / 3;
    return math.sin(phase) * 4;
  }
}

class _Plate extends StatelessWidget {
  const _Plate({required this.name, required this.items, required this.color});

  final String name;
  final String items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: AppRadii.smAll,
        border: Border.all(color: color),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTypography.monoStyle(size: 12, color: color)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              items,
              style: AppTypography.monoStyle(
                size: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
