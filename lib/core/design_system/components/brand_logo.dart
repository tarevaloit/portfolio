import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/app_typography.dart';

/// `tobias.dev_` logo: the part after the last dot is drawn in the accent
/// color and followed by a blinking cursor.
///
/// The cursor stays solid when the platform asks to reduce motion.
class BrandLogo extends StatefulWidget {
  const BrandLogo({required this.text, this.fontSize = 15, super.key});

  final String text;
  final double fontSize;

  @override
  State<BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<BrandLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _blink
        ..stop()
        ..value = 0;
    } else if (!_blink.isAnimating) {
      unawaited(_blink.repeat());
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = AppTypography.monoStyle(
      size: widget.fontSize,
      weight: FontWeight.w500,
      color: colors.onSurface,
    );
    final dot = widget.text.lastIndexOf('.');
    final head = dot == -1 ? widget.text : widget.text.substring(0, dot + 1);
    final tail = dot == -1 ? '' : widget.text.substring(dot + 1);

    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: head),
                TextSpan(
                  text: tail,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
            style: style,
          ),
          AnimatedBuilder(
            animation: _blink,
            builder: (context, child) => Opacity(
              // Hard on/off blink, like a terminal cursor.
              opacity: _blink.value < 0.5 ? 1 : 0,
              child: child,
            ),
            child: Text('_', style: style.copyWith(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}
