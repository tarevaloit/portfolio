import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/design_system/design_system.dart';

/// Whether pages draw the shader background. Tests turn it off so goldens
/// do not depend on the GPU.
final backgroundEffectsEnabledProvider = Provider<bool>(
  (ref) => true,
  name: 'backgroundEffectsEnabledProvider',
);

/// The compiled `shaders/blueprint.frag`, or `null` if the platform cannot
/// load it (then pages keep their plain background).
final blueprintProgramProvider = FutureProvider<ui.FragmentProgram?>((
  ref,
) async {
  try {
    return await ui.FragmentProgram.fromAsset('shaders/blueprint.frag');
  } on Object catch (error) {
    debugPrint('Blueprint shader unavailable: $error');
    return null;
  }
}, name: 'blueprintProgramProvider');

/// Page body with the shader background behind [child].
///
/// Tracks the pointer over the whole page and the vertical scroll of
/// [child] (only its own, not nested scrollables like the marquee).
class BlueprintPage extends StatefulWidget {
  const BlueprintPage({required this.child, super.key});

  final Widget child;

  @override
  State<BlueprintPage> createState() => _BlueprintPageState();
}

class _BlueprintPageState extends State<BlueprintPage> {
  final ValueNotifier<Offset?> _pointer = ValueNotifier(null);
  final ValueNotifier<double> _scroll = ValueNotifier(0);

  @override
  void dispose() {
    _pointer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0 && notification.metrics.axis == Axis.vertical) {
      _scroll.value = notification.metrics.pixels;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => _pointer.value = event.localPosition,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              child: BlueprintBackground(pointer: _pointer, scroll: _scroll),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

/// Paints `blueprint.frag`. Animates with a ticker unless reduced motion
/// is on; then it draws one static frame.
class BlueprintBackground extends ConsumerStatefulWidget {
  const BlueprintBackground({
    required this.pointer,
    required this.scroll,
    super.key,
  });

  final ValueListenable<Offset?> pointer;
  final ValueListenable<double> scroll;

  @override
  ConsumerState<BlueprintBackground> createState() =>
      _BlueprintBackgroundState();
}

class _BlueprintBackgroundState extends ConsumerState<BlueprintBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);

  /// Seconds since start, and the pointer eased toward its real position.
  final ValueNotifier<double> _time = ValueNotifier(0);
  final ValueNotifier<Offset?> _smoothPointer = ValueNotifier(null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = !context.reduceMotion;
    if (animate && !_ticker.isActive) {
      unawaited(_ticker.start());
    } else if (!animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    _time.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final target = widget.pointer.value;
    if (target == null) return;
    final current = _smoothPointer.value ?? target;
    _smoothPointer.value = Offset.lerp(current, target, 0.08);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    _smoothPointer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(backgroundEffectsEnabledProvider)) {
      return const SizedBox.expand();
    }
    final program = ref.watch(blueprintProgramProvider).value;
    if (program == null) return const SizedBox.expand();

    final theme = Theme.of(context);
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _BlueprintPainter(
          shader: program.fragmentShader(),
          time: _time,
          // With reduced motion the glow stays put instead of following.
          pointer: context.reduceMotion ? null : _smoothPointer,
          scroll: widget.scroll,
          base: theme.scaffoldBackgroundColor,
          accent: theme.colorScheme.primary,
          cool: AppLayerColors.of(context).presentation,
        ),
      ),
    );
  }
}

class _BlueprintPainter extends CustomPainter {
  _BlueprintPainter({
    required this.shader,
    required this.time,
    required this.pointer,
    required this.scroll,
    required this.base,
    required this.accent,
    required this.cool,
  }) : super(
         repaint: Listenable.merge([time, scroll, ?pointer]),
       );

  final ui.FragmentShader shader;
  final ValueListenable<double> time;
  final ValueListenable<Offset?>? pointer;
  final ValueListenable<double> scroll;
  final Color base;
  final Color accent;
  final Color cool;

  @override
  void paint(Canvas canvas, Size size) {
    // Until the pointer moves, glow near the top right (behind the hero
    // plates).
    final glow =
        pointer?.value ?? Offset(size.width * 0.78, size.height * 0.25);
    var index = 0;
    void set(double value) => shader.setFloat(index++, value);
    void setColor(Color color) {
      set(color.r);
      set(color.g);
      set(color.b);
      set(color.a);
    }

    set(size.width);
    set(size.height);
    set(time.value);
    set(glow.dx);
    set(glow.dy);
    set(scroll.value);
    setColor(base);
    setColor(accent);
    setColor(cool);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_BlueprintPainter oldDelegate) =>
      oldDelegate.shader != shader ||
      oldDelegate.base != base ||
      oldDelegate.accent != accent ||
      oldDelegate.cool != cool;
}
