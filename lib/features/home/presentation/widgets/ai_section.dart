import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/architecture_mode/source_repository.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/core/router/app_router.dart';

/// "IA que llega a producción": the AI work, one card per case, each with
/// where it lives and, when there is one, a link to see it.
class AiSection extends ConsumerWidget {
  const AiSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final size = ScreenSize.of(context);
    final repository = ref.watch(sourceRepositoryUrlProvider).value;

    final cards = [
      _AiCard(
        tag: l10n.aiWhatsNewTag,
        title: l10n.aiWhatsNewTitle,
        body: l10n.aiWhatsNewBody,
      ),
      _AiCard(
        tag: l10n.aiFundidoTag,
        title: l10n.aiFundidoTitle,
        body: l10n.aiFundidoBody,
        action: l10n.aiSeeProject,
        onAction: () => context.go(
          AppRoutes.projectPath(AppLocale.of(context), 'fundido'),
        ),
      ),
      _AiCard(
        tag: l10n.aiAgentsTag,
        title: l10n.aiAgentsTitle,
        body: l10n.aiAgentsBody,
        action: repository == null ? null : l10n.aiSeeRepo,
        onAction: repository == null
            ? null
            : () => ref.read(linkOpenerProvider).open(repository),
      ),
    ];

    return RevealOnScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.aiEyebrow, style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.md),
          SectionHeader(title: l10n.aiTitle),
          const SizedBox(height: AppSpacing.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(l10n.aiLead, style: theme.textTheme.bodyLarge),
          ),
          const SizedBox(height: AppSpacing.xl),
          ResponsiveGrid(
            columns: size.isCompact ? 1 : 3,
            children: cards,
          ),
        ],
      ),
    );
  }
}

class _AiCard extends StatelessWidget {
  const _AiCard({
    required this.tag,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });

  final String tag;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = this.action;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tag,
            style: AppTypography.monoStyle(
              size: 13,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: theme.textTheme.bodyMedium),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 36),
              ),
              child: Text(action),
            ),
          ],
        ],
      ),
    );
  }
}
