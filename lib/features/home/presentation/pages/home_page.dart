import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// Home page. In Phase 1 it is an empty shell that proves theme, fonts,
/// l10n and routing work end to end; the real sections arrive in Phase 3.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _maxContentWidth = 1120;
  static const double _compactBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = AppLocale.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < _compactBreakpoint;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  compact ? AppSpacing.lg : AppSpacing.xxl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _maxContentWidth,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrandLogo(text: l10n.brandName),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        '${l10n.heroTitleLead} ${l10n.heroTitleHighlight}',
                        style: compact
                            ? textTheme.displaySmall
                            : textTheme.displayLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        l10n.heroBody,
                        style: textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      OutlinedButton(
                        onPressed: () => context.go(locale.other.homePath),
                        child: Text(l10n.switchLanguage),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
