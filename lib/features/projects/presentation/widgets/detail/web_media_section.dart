import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/browser_frame.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/media_carousel.dart';

/// Screenshots of the web version of a project, in a browser window.
class WebMediaSection extends StatelessWidget {
  const WebMediaSection({required this.media, this.accent, super.key});

  static const double maxWidth = 1040;

  /// The screenshots are cropped to 1600×902.
  static const double aspectRatio = 1600 / 902;

  final List<ProjectMedia> media;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            context.l10n.detailWeb,
            style: theme.textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        RevealOnScroll(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxWidth),
              child: MediaCarousel(
                media: media,
                accent: accent,
                frameBuilder: (context, images) =>
                    BrowserFrame(aspectRatio: aspectRatio, child: images),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
