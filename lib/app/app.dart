import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/app/theme/app_theme.dart';
import 'package:portfolio/core/architecture_mode/blueprint_grid.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/router/app_router.dart';

class PortfolioApp extends ConsumerWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appTitle,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      // The effective locale is set per route from the URL; this is only
      // the base so the browser language never overrides the URL.
      locale: AppLocale.fallback.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(appRouterProvider),
      // The blueprint grid of the architecture mode, over every page.
      builder: (context, child) =>
          ArchitectureModeHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
