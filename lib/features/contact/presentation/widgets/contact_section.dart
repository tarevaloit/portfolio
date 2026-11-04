import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/features/contact/domain/entities/contact_info.dart';
import 'package:portfolio/features/contact/presentation/providers/contact_providers.dart';

/// Accent-colored contact block. Missing channels show their placeholder
/// text and are not links.
class ContactSection extends ConsumerWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final size = ScreenSize.of(context);
    final language = AppLocale.of(context).contentLanguage;
    // While loading or on error the block still renders, with placeholders.
    final info =
        ref.watch(contactInfoProvider(language)).value ?? const ContactInfo();
    final onAccent = theme.colorScheme.onPrimary;

    final title = Semantics(
      header: true,
      child: Text(
        l10n.contactTitle,
        style: AppTypography.sans(
          size: size.isCompact ? 40 : 64,
          weight: FontWeight.w800,
          height: 1,
          letterSpacing: size.isCompact ? -1.4 : -2.5,
          color: onAccent,
        ),
      ),
    );

    final links = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ContactLink(
          label: info.email ?? l10n.contactEmailPlaceholder,
          uri: info.mailto,
          emphasized: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        ContactLink(label: l10n.contactGithub, uri: info.github),
        const SizedBox(height: AppSpacing.xs),
        ContactLink(label: l10n.contactLinkedin, uri: info.linkedin),
      ],
    );

    return RevealOnScroll(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.isCompact ? AppSpacing.lg : AppSpacing.xxl,
          vertical: size.isCompact ? AppSpacing.xxl : AppSpacing.xxxl,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: AppRadii.lgAll,
        ),
        child: size.isCompact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: AppSpacing.xl),
                  links,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      // Two lines, as in the mockup.
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: title,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  links,
                ],
              ),
      ),
    );
  }
}

/// Underlined link on the accent block. Without [uri] it is plain text.
class ContactLink extends ConsumerWidget {
  const ContactLink({
    required this.label,
    required this.uri,
    this.emphasized = false,
    super.key,
  });

  final String label;
  final Uri? uri;
  final bool emphasized;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Theme.of(context).colorScheme.onPrimary;
    final text = Text(
      label,
      style: AppTypography.sans(
        size: emphasized ? 17 : 15,
        weight: emphasized ? FontWeight.w700 : FontWeight.w500,
        color: color,
      ).copyWith(decoration: TextDecoration.underline, decorationColor: color),
    );
    final target = uri;
    if (target == null) return text;

    return Semantics(
      link: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => ref.read(linkOpenerProvider).open(target),
          child: text,
        ),
      ),
    );
  }
}
