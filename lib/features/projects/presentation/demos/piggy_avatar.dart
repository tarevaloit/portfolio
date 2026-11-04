import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// Fundido's piggy, animated natively: it blinks, wiggles its ears while
/// [talking] and hops each time [celebrations] grows (a reply arrived).
/// Static with reduced motion. A Rive version can replace it later.
class PiggyAvatar extends StatefulWidget {
  const PiggyAvatar({
    this.size = 44,
    this.talking = false,
    this.celebrations = 0,
    super.key,
  });

  final double size;
  final bool talking;
  final int celebrations;

  @override
  State<PiggyAvatar> createState() => _PiggyAvatarState();
}

class _PiggyAvatarState extends State<PiggyAvatar>
    with TickerProviderStateMixin {
  /// One cycle of 4 s; the eyes close briefly near its end.
  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  late final AnimationController _ears = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final AnimationController _hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  bool get _animate => !context.reduceMotion;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_animate) {
      if (!_blink.isAnimating) unawaited(_blink.repeat());
      _syncEars();
    } else {
      _blink
        ..stop()
        ..value = 0;
      _ears
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didUpdateWidget(PiggyAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_animate) return;
    if (widget.talking != oldWidget.talking) _syncEars();
    if (widget.celebrations > oldWidget.celebrations) {
      unawaited(_hop.forward(from: 0));
    }
  }

  void _syncEars() {
    if (widget.talking) {
      if (!_ears.isAnimating) unawaited(_ears.repeat());
    } else {
      _ears
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _blink.dispose();
    _ears.dispose();
    _hop.dispose();
    super.dispose();
  }

  /// 1 = open, 0 = closed: closed between 92 % and 98 % of the cycle.
  double get _eyeOpen {
    final t = _blink.value;
    if (t < 0.92 || t > 0.98) return 1;
    return (1 - math.sin((t - 0.92) / 0.06 * math.pi)).clamp(0.1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_blink, _ears, _hop]),
      builder: (context, _) {
        final hop = math.sin(_hop.value * math.pi);
        return Transform.translate(
          offset: Offset(0, -hop * widget.size * 0.12),
          child: Transform.scale(
            scale: 1 + hop * 0.08,
            child: SizedBox.square(
              dimension: widget.size,
              child: CustomPaint(
                painter: PiggyPainter(
                  eyeOpen: _eyeOpen,
                  earTilt: math.sin(_ears.value * 2 * math.pi) * 0.35,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The piggy drawn with shapes. [eyeOpen] goes from 0 (closed) to 1 and
/// [earTilt] rotates the ears, in radians.
class PiggyPainter extends CustomPainter {
  const PiggyPainter({this.eyeOpen = 1, this.earTilt = 0});

  final double eyeOpen;
  final double earTilt;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = Offset(size.width / 2, size.height / 2);
    final pink = Paint()..color = const Color(0xFFF9A8D4);
    final dark = Paint()..color = const Color(0xFFF472B6);
    final ink = Paint()..color = const Color(0xFF831843);

    for (final side in [-1.0, 1.0]) {
      final base = center.translate(side * 0.26 * s, -0.3 * s);
      canvas
        ..save()
        ..translate(base.dx, base.dy)
        ..rotate(side * (0.2 + earTilt))
        ..drawPath(
          Path()
            ..moveTo(-0.12 * s, 0.06 * s)
            ..lineTo(side * 0.04 * s, -0.2 * s)
            ..lineTo(0.12 * s, 0.06 * s)
            ..close(),
          dark,
        )
        ..restore();
    }

    canvas
      ..drawCircle(center, s * 0.42, pink)
      ..drawOval(
        Rect.fromCenter(
          center: center.translate(0, s * 0.1),
          width: s * 0.36,
          height: s * 0.24,
        ),
        dark,
      )
      ..drawCircle(center.translate(-s * 0.07, s * 0.1), s * 0.04, ink)
      ..drawCircle(center.translate(s * 0.07, s * 0.1), s * 0.04, ink);

    for (final dx in [-0.15, 0.15]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(dx * s, -0.1 * s),
          width: s * 0.09,
          height: s * 0.09 * eyeOpen,
        ),
        ink,
      );
    }
  }

  @override
  bool shouldRepaint(PiggyPainter oldDelegate) =>
      eyeOpen != oldDelegate.eyeOpen || earTilt != oldDelegate.earTilt;
}
