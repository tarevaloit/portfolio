import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/features/about/domain/entities/about_info.dart';
import 'package:portfolio/features/about/presentation/providers/about_providers.dart';

/// "Sobre mí": photo, a few paragraphs and short facts (location,
/// experience, education, languages). Photo beside the text on wide
/// screens, above it on phones.
class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = AppLocale.of(context).contentLanguage;
    final about = ref.watch(aboutInfoProvider(language));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RevealOnScroll(child: SectionHeader(title: l10n.aboutTitle)),
        const SizedBox(height: AppSpacing.xxl),
        about.when(
          data: (info) => RevealOnScroll(child: _AboutBody(info: info)),
          loading: () => const SkeletonBox(height: 280),
          error: (_, _) => Text(
            l10n.aboutError,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({required this.info});

  static const double photoSize = 220;

  final AboutInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = ScreenSize.of(context).isCompact;
    final photo = info.photo;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, paragraph) in info.paragraphs.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          Text(
            paragraph,
            style: index == 0
                ? AppTypography.sans(
                    size: compact ? 20 : 24,
                    weight: FontWeight.w600,
                    height: 1.4,
                    color: theme.colorScheme.onSurface,
                  )
                : theme.textTheme.bodyLarge,
          ),
        ],
        if (info.facts.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          ResponsiveGrid(
            columns: compact ? 1 : 2,
            spacing: AppSpacing.lg,
            children: [
              for (final fact in info.facts)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fact.label.toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      fact.value,
                      style: AppTypography.sans(
                        size: 15,
                        weight: FontWeight.w500,
                        height: 1.4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ],
    );

    if (photo == null) return text;
    final portrait = _Portrait(asset: photo, size: compact ? 160 : photoSize);
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          portrait,
          const SizedBox(height: AppSpacing.xl),
          text,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        portrait,
        const SizedBox(width: AppSpacing.xxl),
        Expanded(child: text),
      ],
    );
  }
}

/// Round photo with a thin accent ring.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          semanticLabel: context.l10n.aboutPhotoLabel,
          errorBuilder: (context, error, stackTrace) =>
              ColoredBox(color: colors.surfaceContainerHigh),
        ),
      ),
    );
  }
}
