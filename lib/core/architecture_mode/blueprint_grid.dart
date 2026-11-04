import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// Blueprint grid drawn over every page while the architecture mode is on.
/// Mounted once in `MaterialApp.builder`; it never takes pointer events.
class ArchitectureModeHost extends ConsumerWidget {
  const ArchitectureModeHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(architectureModeProvider);
    final accent = Theme.of(context).colorScheme.primary;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: enabled ? 1 : 0,
              duration: context.reduceMotion ? Duration.zero : AppMotion.slow,
              curve: AppMotion.emphasized,
              child: RepaintBoundary(
                child: CustomPaint(painter: BlueprintGridPainter(accent)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Minor lines every 24 px, major lines every 120 px with a "+" mark at
/// each crossing, all in a faint accent.
class BlueprintGridPainter extends CustomPainter {
  const BlueprintGridPainter(this.color);

  static const double minor = 24;
  static const double major = 120;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    final majorPaint = Paint()
      ..color = color.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    final markPaint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 1;

    for (var x = 0.0; x <= size.width; x += minor) {
      final isMajor = x % major == 0;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        isMajor ? majorPaint : minorPaint,
      );
    }
    for (var y = 0.0; y <= size.height; y += minor) {
      final isMajor = y % major == 0;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        isMajor ? majorPaint : minorPaint,
      );
    }
    for (var x = major; x < size.width; x += major) {
      for (var y = major; y < size.height; y += major) {
        canvas
          ..drawLine(Offset(x - 4, y), Offset(x + 4, y), markPaint)
          ..drawLine(Offset(x, y - 4), Offset(x, y + 4), markPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BlueprintGridPainter oldDelegate) =>
      color != oldDelegate.color;
}
