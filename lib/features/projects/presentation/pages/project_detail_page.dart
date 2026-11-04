import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/l10n/language_switch.dart';
import 'package:portfolio/core/platform/link_opener.dart';
import 'package:portfolio/core/router/not_found_page.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/demos/project_demo.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/how_its_built_section.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/phone_frame.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_heroes.dart';

/// `/projects/:slug`: hero with metadata and the phone demo, then
/// "Cómo está hecho" and the technical decisions.
///
/// Reads the same sorted list as the home grid, so when coming from a card
/// the project is already there on the first frame and the Heroes fly.
class ProjectDetailPage extends ConsumerStatefulWidget {
  const ProjectDetailPage({
    required this.slug,
    this.extraDemos = const {},
    super.key,
  });

  final String slug;

  /// Demos provided by other features, by slug (e.g. the home preview for
  /// "Este portfolio"), so this feature does not import them.
  final Map<String, WidgetBuilder> extraDemos;

  @override
  ConsumerState<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends ConsumerState<ProjectDetailPage> {
  final GlobalKey _howItsBuiltKey = GlobalKey();

  /// Tab title to restore when leaving: the page below (the home) does not
  /// rebuild on pop, so its `Title` would not set it again.
  String? _appTitle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appTitle = context.l10n.appTitle;
  }

  @override
  void dispose() {
    final title = _appTitle;
    if (title != null) {
      unawaited(
        SystemChrome.setApplicationSwitcherDescription(
          ApplicationSwitcherDescription(
            label: title,
            primaryColor: AppColors.accentLime.toARGB32(),
          ),
        ),
      );
    }
    super.dispose();
  }

  Future<void> _scrollToHowItsBuilt() async {
    final target = _howItsBuiltKey.currentContext;
    if (target == null) return;
    await Scrollable.ensureVisible(
      target,
      duration: context.reduceMotion ? Duration.zero : AppMotion.slow,
      curve: AppMotion.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = AppLocale.of(context).contentLanguage;
    final projects = ref.watch(projectsProvider(language));

    return projects.when(
      data: (projects) {
        final index = projects.indexWhere((p) => p.slug == widget.slug);
        if (index == -1) return const NotFoundPage();
        return _content(context, projects[index], index, projects.length);
      },
      loading: () => const Scaffold(
        body: Center(
          child: SizedBox(width: 320, child: SkeletonBox(height: 320)),
        ),
      ),
      error: (_, _) => Scaffold(
        body: Center(
          child: Text(
            l10n.detailError,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, Project project, int index, int total) {
    final size = ScreenSize.of(context);
    return Title(
      title: context.l10n.projectPageTitle(project.name),
      color: Color(project.color),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageContainer(
                  child: _TopBar(index: index, total: total),
                ),
                SizedBox(height: size.isCompact ? AppSpacing.xl : 72),
                PageContainer(
                  child: _DetailHero(
                    project: project,
                    demo: ProjectDemo(
                      project: project,
                      extraDemos: widget.extraDemos,
                    ),
                    onHowItsBuilt: _scrollToHowItsBuilt,
                  ),
                ),
                SizedBox(height: size.sectionSpacing),
                const PageContainer(child: Divider()),
                SizedBox(height: size.sectionSpacing * 0.75),
                PageContainer(
                  child: HowItsBuiltSection(
                    key: _howItsBuiltKey,
                    project: project,
                  ),
                ),
                if (project.decisions.isNotEmpty) ...[
                  SizedBox(height: size.sectionSpacing * 0.75),
                  PageContainer(
                    child: DecisionsSection(decisions: project.decisions),
                  ),
                ],
                SizedBox(height: size.sectionSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    String pad(int value) => value.toString().padLeft(2, '0');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          TextButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppLocale.of(context).homePath);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: colors.onSurface,
              textStyle: AppTypography.monoStyle(size: 14),
            ),
            child: Text(l10n.detailBack),
          ),
          const Spacer(),
          Text(
            l10n.detailCounter(pad(index + 1), pad(total)),
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: AppSpacing.md),
          const LanguageSwitch(),
        ],
      ),
    );
  }
}

class _DetailHero extends ConsumerWidget {
  const _DetailHero({
    required this.project,
    required this.demo,
    required this.onHowItsBuilt,
  });

  /// Below this width the phone goes under the copy.
  static const double sideBySideMinWidth = 900;

  final Project project;
  final Widget demo;
  final VoidCallback onHowItsBuilt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final size = ScreenSize.of(context);
    final accent = Color(project.color);
    final github = project.links.github;

    final nameSize = switch (size) {
      ScreenSize.compact => 72.0,
      ScreenSize.medium => 112.0,
      ScreenSize.expanded => 144.0,
    };

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Entrance(
          index: 0,
          child: Text(
            '${project.category} · ${project.badge}',
            style: AppTypography.monoStyle(size: 15, color: accent),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: ProjectNameHero(
            slug: project.slug,
            child: Text(
              project.name,
              style: AppTypography.sans(
                size: nameSize,
                weight: FontWeight.w800,
                height: 0.95,
                letterSpacing: -nameSize * 0.05,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Entrance(
          index: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              project.description,
              style: AppTypography.sans(
                size: size.isCompact ? 18 : 20,
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl + 8),
        Entrance(
          index: 2,
          child: Wrap(
            spacing: AppSpacing.xxl,
            runSpacing: AppSpacing.lg,
            children: [
              _Meta(label: l10n.detailRole, value: project.role),
              _Meta(
                label: l10n.detailPlatforms,
                value: project.platforms.join(' · '),
              ),
              _Meta(label: l10n.detailStatus, value: project.status),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl + 8),
        Entrance(
          index: 3,
          // The project color is the local accent of the buttons.
          child: Theme(
            data: theme.copyWith(
              filledButtonTheme: FilledButtonThemeData(
                style: theme.filledButtonTheme.style?.copyWith(
                  backgroundColor: WidgetStatePropertyAll(accent),
                  foregroundColor: const WidgetStatePropertyAll(
                    AppColors.background,
                  ),
                ),
              ),
            ),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton(
                  onPressed: onHowItsBuilt,
                  child: Text(l10n.detailHowItsBuiltCta),
                ),
                OutlinedButton(
                  onPressed: github == null
                      ? null
                      : () => ref.read(linkOpenerProvider).open(github),
                  child: Text(l10n.detailCode),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final phone = Semantics(
      container: true,
      label: l10n.detailDemoLabel(project.name),
      child: ProjectCoverHero(
        slug: project.slug,
        color: accent,
        child: PhoneFrame(child: demo),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < sideBySideMinWidth) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              copy,
              const SizedBox(height: AppSpacing.xxl),
              Center(child: phone),
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

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.sans(
            size: 17,
            weight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
