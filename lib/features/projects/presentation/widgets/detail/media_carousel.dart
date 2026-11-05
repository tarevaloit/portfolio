import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

/// Real screenshots one at a time: swipe or drag, the arrows, or the
/// keyboard arrows once focus is inside. The caption of the current image
/// sits under the controls and is announced when it changes.
///
/// [frameBuilder] wraps the sliding images (the phone, the browser window),
/// so the controls stay outside whatever the frame is (a Hero, for one).
class MediaCarousel extends StatefulWidget {
  const MediaCarousel({
    required this.media,
    required this.frameBuilder,
    this.accent,
    this.captionWidth,
    super.key,
  });

  final List<ProjectMedia> media;
  final Widget Function(BuildContext context, Widget images) frameBuilder;

  /// Color of the current dot; the theme's primary by default.
  final Color? accent;

  /// Width of the caption (by default as wide as the carousel allows).
  final double? captionWidth;

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final PageController _controller = PageController();
  int _index = 0;

  int get _count => widget.media.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAround(_index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Decodes the neighbours so swiping never shows an empty frame.
  void _precacheAround(int index) {
    for (final i in [index - 1, index + 1]) {
      if (i < 0 || i >= _count) continue;
      unawaited(
        precacheImage(
          AssetImage(widget.media[i].asset),
          context,
          onError: (_, _) {},
        ),
      );
    }
  }

  void _go(int index) {
    if (index < 0 || index >= _count || !_controller.hasClients) return;
    if (context.reduceMotion) {
      _controller.jumpToPage(index);
    } else {
      unawaited(
        _controller.animateToPage(
          index,
          duration: AppMotion.medium,
          curve: AppMotion.emphasized,
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() => _index = index);
    _precacheAround(index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final accent = widget.accent ?? theme.colorScheme.primary;
    final current = widget.media[_index];

    final images = ScrollConfiguration(
      // On the web a mouse or trackpad drag should also slide the images.
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
        scrollbars: false,
      ),
      child: PageView.builder(
        controller: _controller,
        itemCount: _count,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) => Image.asset(
          widget.media[index].asset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          // The caption below says what it shows.
          excludeFromSemantics: true,
          gaplessPlayback: true,
          errorBuilder: (context, error, stackTrace) =>
              ColoredBox(color: theme.colorScheme.surfaceContainerHighest),
        ),
      ),
    );

    String pad(int value) => value.toString().padLeft(2, '0');

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
            _go(_index - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _go(_index + 1),
      },
      child: FocusTraversalGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.frameBuilder(context, images),
            if (_count > 1) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _index == 0 ? null : () => _go(_index - 1),
                    tooltip: l10n.carouselPrevious,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ExcludeSemantics(
                    child: _Dots(count: _count, index: _index, color: accent),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton(
                    onPressed: _index == _count - 1
                        ? null
                        : () => _go(_index + 1),
                    tooltip: l10n.carouselNext,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: widget.captionWidth,
              child: Semantics(
                liveRegion: true,
                label: l10n.carouselCaption(
                  _index + 1,
                  _count,
                  current.caption,
                ),
                child: ExcludeSemantics(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (_count > 1)
                          TextSpan(
                            text: '${pad(_index + 1)}/${pad(_count)}  ',
                            style: AppTypography.monoStyle(
                              size: 13,
                              color: accent,
                            ),
                          ),
                        TextSpan(text: current.caption),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: AppTypography.sans(
                      size: 15,
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.color});

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final idle = Theme.of(context).colorScheme.outline;
    final duration = context.reduceMotion ? Duration.zero : AppMotion.fast;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: duration,
            curve: AppMotion.emphasized,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == index ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == index ? color : idle,
              borderRadius: AppRadii.pillAll,
            ),
          ),
      ],
    );
  }
}
