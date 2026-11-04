import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// Fishar mock: a map with three spots. Tapping a spot opens its sheet;
/// tapping the map closes it. Texts are the mockup placeholders.
class FisharDemo extends StatefulWidget {
  const FisharDemo({super.key});

  /// Pin positions as fractions of the screen.
  static const List<Offset> spots = [
    Offset(0.30, 0.30),
    Offset(0.74, 0.40),
    Offset(0.46, 0.52),
  ];

  static const double sheetHeight = 210;

  @override
  State<FisharDemo> createState() => _FisharDemoState();
}

class _FisharDemoState extends State<FisharDemo> {
  static const Color _teal = Color(0xFF5EEAD4);
  static const Color _ink = Color(0xFF0E0F12);
  static const Color _paper = Color(0xFFECEAE4);

  int? _selected = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final duration = context.reduceMotion ? Duration.zero : AppMotion.medium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _selected = null),
                child: const CustomPaint(painter: _MapPainter()),
              ),
            ),
            for (final (index, spot) in FisharDemo.spots.indexed)
              _Pin(
                key: ValueKey('fishar-spot-$index'),
                center: Offset(spot.dx * width, spot.dy * height),
                selected: _selected == index,
                label: l10n.demoFisharSpot(index + 1),
                duration: duration,
                onTap: () => setState(() => _selected = index),
              ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  color: _paper,
                  borderRadius: AppRadii.pillAll,
                ),
                child: Text(
                  l10n.demoFisharSearch,
                  style: AppTypography.sans(
                    size: 13,
                    color: const Color(0xFF4B4B45),
                  ),
                ),
              ),
            ),
            if (_selected == null)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _ink.withValues(alpha: 0.8),
                      borderRadius: AppRadii.pillAll,
                    ),
                    child: Text(
                      l10n.demoFisharHint,
                      style: AppTypography.sans(size: 12, color: _paper),
                    ),
                  ),
                ),
              ),
            AnimatedPositioned(
              duration: duration,
              curve: AppMotion.emphasized,
              left: 0,
              right: 0,
              height: FisharDemo.sheetHeight,
              bottom: _selected == null ? -FisharDemo.sheetHeight : 0,
              child: const _SpotSheet(),
            ),
          ],
        );
      },
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({
    required this.center,
    required this.selected,
    required this.label,
    required this.duration,
    required this.onTap,
    super.key,
  });

  final Offset center;
  final bool selected;
  final String label;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 44.0 : 34.0;
    return AnimatedPositioned(
      duration: duration,
      left: center.dx - size / 2,
      top: center.dy - size / 2,
      width: size,
      height: size,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: duration,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.accentLime : _FisharDemoState._teal,
              border: Border.all(color: _FisharDemoState._ink, width: 3),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotSheet extends StatelessWidget {
  const _SpotSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const thumbs = [Color(0xFFB9D9D3), Color(0xFF9FC9C1), Color(0xFFCFE7E2)];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: _FisharDemoState._paper,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFBDBDB5),
                borderRadius: AppRadii.pillAll,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.demoFisharSpotName,
            style: AppTypography.sans(
              size: 18,
              weight: FontWeight.w800,
              color: _FisharDemoState._ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.demoFisharSpotMeta,
            style: AppTypography.sans(size: 12, color: const Color(0xFF4B4B45)),
          ),
          const Spacer(),
          Row(
            children: [
              for (final (index, color) in thumbs.indexed) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Stylized water and shore bands, as in the mockup.
class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF123B3A),
    );

    final upper = Path()
      ..moveTo(0, h * 0.42)
      ..quadraticBezierTo(w * 0.45, h * 0.16, w, h * 0.22)
      ..lineTo(w, h * 0.50)
      ..quadraticBezierTo(w * 0.55, h * 0.62, 0, h * 0.58)
      ..close();
    canvas.drawPath(upper, Paint()..color = const Color(0xFF1A5654));

    final lower = Path()
      ..moveTo(0, h * 0.64)
      ..quadraticBezierTo(w * 0.5, h * 0.60, w, h * 0.76)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(lower, Paint()..color = const Color(0xFF1D6461));
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}
