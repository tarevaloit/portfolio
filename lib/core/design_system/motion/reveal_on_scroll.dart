import 'package:flutter/widgets.dart';
import 'package:portfolio/core/design_system/motion/motion.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Fades and slides [child] in the first time it enters the viewport.
///
/// With reduced motion the child is shown right away.
class RevealOnScroll extends StatefulWidget {
  const RevealOnScroll({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll> {
  static const double _threshold = 0.12;

  final Key _detectorKey = UniqueKey();
  bool _visible = false;

  Future<void> _onVisibilityChanged(VisibilityInfo info) async {
    if (_visible || info.visibleFraction < _threshold) return;
    if (widget.delay > Duration.zero) {
      await Future<void>.delayed(widget.delay);
    }
    if (mounted) setState(() => _visible = true);
  }

  @override
  Widget build(BuildContext context) {
    if (context.reduceMotion) return widget.child;

    return VisibilityDetector(
      key: _detectorKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: AppMotion.slow,
        curve: AppMotion.emphasized,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 0.06),
          duration: AppMotion.slow,
          curve: AppMotion.emphasized,
          child: widget.child,
        ),
      ),
    );
  }
}
