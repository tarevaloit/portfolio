import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:portfolio/core/design_system/app_typography.dart';
import 'package:portfolio/core/design_system/motion/motion.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';

/// Infinite horizontal ticker of [items] separated by an accent mark.
///
/// Scrolls at [speed] logical pixels per second; static with reduced
/// motion. Screen readers get the list once, not the repeated ticker.
class Marquee extends StatefulWidget {
  const Marquee({required this.items, this.speed = 40, super.key});

  final List<String> items;
  final double speed;

  @override
  State<Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late final Ticker _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      if (_ticker.isActive) _ticker.stop();
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      unawaited(_ticker.start());
    }
  }

  void _onTick(Duration elapsed) {
    final delta = elapsed - _last;
    _last = elapsed;
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) {
      return;
    }
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    _controller.jumpTo(_controller.offset + widget.speed * seconds);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final itemStyle = AppTypography.monoStyle(
      size: 14,
      color: colors.onSurfaceVariant,
    );

    return Semantics(
      label: widget.items.join(', '),
      excludeSemantics: true,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(color: colors.outline),
          ),
        ),
        child: ListView.builder(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = widget.items[index % widget.items.length];
            return Row(
              children: [
                const SizedBox(width: AppSpacing.xl),
                Center(child: Text(item, style: itemStyle)),
                const SizedBox(width: AppSpacing.xl),
                Text(
                  '✦',
                  style: itemStyle.copyWith(
                    color: colors.primary,
                    fontSize: 10,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
