import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';
import 'package:portfolio/features/projects/presentation/widgets/projects_showcase.dart';

/// Hero: eyebrow, title with the highlighted last words, paragraph, CTAs
/// and a phone with the real apps.
class HeroSection extends StatelessWidget {
  const HeroSection({required this.onSeeProjects, super.key});

  final VoidCallback onSeeProjects;

  /// Below this width the phone goes under the copy instead of beside it.
  static const double sideBySideMinWidth = 900;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final size = ScreenSize.of(context);

    final titleStyle = switch (size) {
      ScreenSize.compact => AppTypography.sans(
        size: 44,
        weight: FontWeight.w800,
        height: 1,
        letterSpacing: -1.6,
        color: theme.colorScheme.onSurface,
      ),
      ScreenSize.medium => theme.textTheme.displayMedium,
      ScreenSize.expanded => theme.textTheme.displayLarge,
    };

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Entrance(
          index: 0,
          child: Text(l10n.heroEyebrow, style: theme.textTheme.labelMedium),
        ),
        const SizedBox(height: AppSpacing.lg),
        Entrance(
          index: 1,
          child: Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${l10n.heroTitleLead} '),
                  TextSpan(
                    text: l10n.heroTitleHighlight,
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                ],
              ),
              style: titleStyle,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Entrance(
          index: 2,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(l10n.heroBody, style: theme.textTheme.bodyLarge),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Entrance(
          index: 3,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              FilledButton(
                onPressed: onSeeProjects,
                child: Text(l10n.heroCtaProjects),
              ),
              const _DownloadCvButton(),
            ],
          ),
        ),
      ],
    );

    const phone = Entrance(index: 4, child: ProjectsShowcase());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Side by side only when the copy column stays wide enough for the
        // title at this size.
        if (constraints.maxWidth < sideBySideMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              const SizedBox(height: AppSpacing.xxl),
              const Center(child: phone),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: copy),
            const SizedBox(width: AppSpacing.xxl),
            phone,
          ],
        );
      },
    );
  }
}

/// Opens the CV of the current language. Disabled until the PDF exists.
class _DownloadCvButton extends ConsumerWidget {
  const _DownloadCvButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = AppLocale.of(context).contentLanguage;
    final cvPath = ref.watch(contactInfoProvider(language)).value?.cvAssetPath;

    return OutlinedButton(
      onPressed: cvPath == null
          ? null
          : () => ref
                .read(linkOpenerProvider)
                .open(Uri.base.resolve('/assets/$cvPath')),
      child: Text(context.l10n.heroCtaCv),
    );
  }
}
