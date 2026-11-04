import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// Laburito mock of the real "create request" flow of a Buscador: what
/// trade, where (map pin), when (the real urgency options) and posted. The
/// real app also has a photos step, left out to keep the mock short.
class LaburitoDemo extends StatefulWidget {
  const LaburitoDemo({super.key});

  @override
  State<LaburitoDemo> createState() => _LaburitoDemoState();
}

enum _Step { trade, where, when, done }

class _LaburitoDemoState extends State<LaburitoDemo> {
  static const Color _background = Color(0xFFFFF7ED);
  static const Color _orange = Color(0xFFFDBA74);
  static const Color _ink = Color(0xFF1C1917);
  static const Color _muted = Color(0xFF78716C);

  static const List<IconData> _tradeIcons = [
    Icons.plumbing,
    Icons.electrical_services,
    Icons.local_fire_department,
    Icons.format_paint,
  ];
  static const List<IconData> _urgencyIcons = [
    Icons.hourglass_empty,
    Icons.event,
    Icons.priority_high,
  ];

  _Step _step = _Step.trade;
  int _trade = 0;

  void _go(_Step step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trades = l10n.demoLaburitoTrades.split(',');
    final urgencies = l10n.demoLaburitoUrgencies.split(',');

    final title = switch (_step) {
      _Step.trade => l10n.demoLaburitoTradesTitle,
      _Step.where => l10n.demoLaburitoWhereTitle,
      _Step.when => l10n.demoLaburitoWhenTitle,
      _Step.done => '',
    };
    final previous = switch (_step) {
      _Step.where => _Step.trade,
      _Step.when => _Step.where,
      _ => null,
    };

    final body = switch (_step) {
      _Step.trade => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final (index, trade) in trades.indexed)
            _Tile(
              icon: _tradeIcons[index % _tradeIcons.length],
              title: trade,
              onTap: () {
                _trade = index;
                _go(_Step.where);
              },
            ),
        ],
      ),
      _Step.where => Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: const CustomPaint(painter: _MiniMapPainter()),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Color(0xFFEA580C), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.demoLaburitoAddress,
                      style: AppTypography.sans(size: 13, color: _ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _go(_Step.when),
              style: FilledButton.styleFrom(
                backgroundColor: _ink,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.demoLaburitoUseLocation),
            ),
          ],
        ),
      ),
      _Step.when => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final (index, urgency) in urgencies.indexed)
            _Tile(
              icon: _urgencyIcons[index % _urgencyIcons.length],
              title: urgency,
              onTap: () => _go(_Step.done),
            ),
        ],
      ),
      _Step.done => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF16A34A),
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.demoLaburitoDone(trades[_trade]),
                textAlign: TextAlign.center,
                style: AppTypography.sans(
                  size: 16,
                  weight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => _go(_Step.trade),
                style: TextButton.styleFrom(foregroundColor: _ink),
                child: Text(l10n.demoLaburitoRestart),
              ),
            ],
          ),
        ),
      ),
    };

    return ColoredBox(
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _orange,
            padding: const EdgeInsets.fromLTRB(8, 20, 16, 14),
            child: Row(
              children: [
                if (previous != null)
                  IconButton(
                    onPressed: () => _go(previous),
                    tooltip: l10n.demoBack,
                    icon: const Icon(Icons.arrow_back, color: _ink, size: 20),
                    visualDensity: VisualDensity.compact,
                  )
                else
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.sans(
                      size: 16,
                      weight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: context.reduceMotion ? Duration.zero : AppMotion.fast,
              child: KeyedSubtree(key: ValueKey(_step), child: body),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEDD5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: _LaburitoDemoState._ink, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.sans(
                      size: 14,
                      weight: FontWeight.w600,
                      color: _LaburitoDemoState._ink,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: _LaburitoDemoState._muted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Simplified street map with the pin of the request, like the real
/// `MiniMapaPedido`.
class _MiniMapPainter extends CustomPainter {
  const _MiniMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFF1EDE4),
    );
    final street = Paint()
      ..color = Colors.white
      ..strokeWidth = 10;
    for (final f in [0.22, 0.55, 0.85]) {
      canvas
        ..drawLine(
          Offset(0, size.height * f),
          Offset(size.width, size.height * f),
          street,
        )
        ..drawLine(
          Offset(size.width * f, 0),
          Offset(size.width * f, size.height),
          street,
        );
    }
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.6,
        size.height * 0.6,
        size.width * 0.2,
        size.height * 0.2,
      ),
      Paint()..color = const Color(0xFFD9EAD3),
    );
    final pin = Offset(size.width * 0.4, size.height * 0.42);
    canvas
      ..drawCircle(pin, 14, Paint()..color = const Color(0x33EA580C))
      ..drawCircle(pin, 7, Paint()..color = const Color(0xFFEA580C))
      ..drawCircle(pin, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_MiniMapPainter oldDelegate) => false;
}
