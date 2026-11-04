import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// The switch of the architecture mode: when it turns on, the track fills
/// with the accent and a tiny blueprint grid, and the thumb slides with a
/// crosshair that turns a quarter. Native animation (Rive can replace it
/// later); instant with reduced motion.
class BlueprintSwitch extends StatelessWidget {
  const BlueprintSwitch({required this.value, super.key});

  static const Size size = Size(40, 22);
  static const double thumb = 16;

  final bool value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final duration = context.reduceMotion ? Duration.zero : AppMotion.medium;
    const curve = AppMotion.emphasized;

    return SizedBox.fromSize(
      size: size,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        decoration: BoxDecoration(
          color: value ? colors.primary : colors.surfaceContainerHigh,
          borderRadius: AppRadii.pillAll,
          border: Border.all(color: value ? colors.primary : colors.outline),
        ),
        child: ClipRRect(
          borderRadius: AppRadii.pillAll,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: value ? 1 : 0,
                  duration: duration,
                  child: const CustomPaint(painter: _TrackGridPainter()),
                ),
              ),
              AnimatedAlign(
                duration: duration,
                curve: curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    width: thumb,
                    height: thumb,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? AppColors.onAccent : AppColors.textMuted,
                    ),
                    child: AnimatedRotation(
                      turns: value ? 0.25 : 0,
                      duration: duration,
                      curve: curve,
                      child: CustomPaint(
                        painter: _CrosshairPainter(
                          value ? colors.primary : AppColors.surfaceRaised,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackGridPainter extends CustomPainter {
  const _TrackGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.onAccent.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var x = 4.0; x < size.width; x += 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 4.0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TrackGridPainter oldDelegate) => false;
}

class _CrosshairPainter extends CustomPainter {
  const _CrosshairPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.28;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawLine(c.translate(-r, 0), c.translate(r, 0), paint)
      ..drawLine(c.translate(0, -r), c.translate(0, r), paint)
      ..drawCircle(c, r * 0.55, paint..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_CrosshairPainter oldDelegate) =>
      color != oldDelegate.color;
}
