import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// Laburito mock: hiring flow in three steps (trade → professional →
/// confirm) and a done screen. Example copy and fictional names.
class LaburitoDemo extends StatefulWidget {
  const LaburitoDemo({super.key});

  @override
  State<LaburitoDemo> createState() => _LaburitoDemoState();
}

enum _Step { trade, worker, confirm, done }

class _LaburitoDemoState extends State<LaburitoDemo> {
  static const Color _background = Color(0xFFFFF7ED);
  static const Color _orange = Color(0xFFFDBA74);
  static const Color _ink = Color(0xFF1C1917);
  static const Color _muted = Color(0xFF78716C);
  static const Color _mercadoPago = Color(0xFF009EE3);

  static const List<IconData> _tradeIcons = [
    Icons.plumbing,
    Icons.electrical_services,
    Icons.local_fire_department,
    Icons.format_paint,
  ];
  static const List<double> _ratings = [4.9, 4.8, 4.7];
  static const List<double> _distances = [1.2, 2.5, 3.1];

  _Step _step = _Step.trade;
  int _trade = 0;
  int _worker = 0;

  void _go(_Step step) => setState(() => _step = step);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trades = l10n.demoLaburitoTrades.split(',');
    final workers = l10n.demoLaburitoWorkers.split(',');
    final number = NumberFormat(
      '0.0',
      Localizations.localeOf(context).languageCode,
    );

    final title = switch (_step) {
      _Step.trade => l10n.demoLaburitoTradesTitle,
      _Step.worker => l10n.demoLaburitoWorkersTitle,
      _Step.confirm => l10n.demoLaburitoConfirmTitle,
      _Step.done => '',
    };
    final previous = switch (_step) {
      _Step.worker => _Step.trade,
      _Step.confirm => _Step.worker,
      _ => null,
    };

    final body = switch (_step) {
      _Step.trade => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final (index, trade) in trades.indexed)
            _Tile(
              leading: Icon(
                _tradeIcons[index % _tradeIcons.length],
                color: _ink,
                size: 20,
              ),
              title: trade,
              onTap: () {
                _trade = index;
                _go(_Step.worker);
              },
            ),
        ],
      ),
      _Step.worker => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final (index, worker) in workers.indexed)
            _Tile(
              leading: Text(
                worker.substring(0, 1),
                style: AppTypography.sans(
                  size: 15,
                  weight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              title: worker,
              subtitle: l10n.demoLaburitoWorkerMeta(
                number.format(_ratings[index % _ratings.length]),
                number.format(_distances[index % _distances.length]),
              ),
              onTap: () {
                _worker = index;
                _go(_Step.confirm);
              },
            ),
        ],
      ),
      _Step.confirm => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                l10n.demoLaburitoSummary(trades[_trade], workers[_worker]),
                style: AppTypography.sans(
                  size: 15,
                  weight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _go(_Step.done),
              style: FilledButton.styleFrom(
                backgroundColor: _mercadoPago,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.demoLaburitoPay),
            ),
          ],
        ),
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
                l10n.demoLaburitoDone(workers[_worker]),
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
  const _Tile({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
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
                  child: leading,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.sans(
                          size: 14,
                          weight: FontWeight.w600,
                          color: _LaburitoDemoState._ink,
                        ),
                      ),
                      if (subtitle != null)
                        Row(
                          children: [
                            // An icon: no bundled font has the "★" glyph.
                            const Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                subtitle!,
                                style: AppTypography.sans(
                                  size: 11,
                                  color: _LaburitoDemoState._muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
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
