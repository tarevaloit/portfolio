import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/shaders/blueprint_background.dart';

/// 404 page in the site style, shown in the locale of the URL that failed.
///
/// Hosting rewrites every path to the app, so this is what a broken link
/// lands on; it shows the requested path to make the mistake obvious.
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({this.path, super.key});

  /// The path that did not match any route.
  final String? path;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final compact = ScreenSize.of(context).isCompact;
    final requested = path;

    return Title(
      title: l10n.projectPageTitle(l10n.notFoundTitle),
      color: theme.colorScheme.primary,
      child: Scaffold(
        body: BlueprintPage(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: PageContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrandLogo(text: l10n.brandName),
                      const SizedBox(height: AppSpacing.xxl),
                      if (requested != null) ...[
                        Text(
                          '// $requested',
                          style: theme.textTheme.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      ExcludeSemantics(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: '4'),
                              TextSpan(
                                text: '0',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const TextSpan(text: '4'),
                            ],
                          ),
                          style: AppTypography.sans(
                            size: compact ? 112 : 176,
                            weight: FontWeight.w800,
                            height: 0.9,
                            letterSpacing: compact ? -5 : -8,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Semantics(
                        header: true,
                        child: Text(
                          l10n.notFoundTitle,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(l10n.notFoundBody, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: () =>
                            context.go(AppLocale.of(context).homePath),
                        child: Text(l10n.notFoundBackHome),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
