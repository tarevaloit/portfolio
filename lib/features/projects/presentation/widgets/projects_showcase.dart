import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';
import 'package:portfolio/core/router/app_router.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/providers/projects_providers.dart';
import 'package:portfolio/features/projects/presentation/widgets/detail/phone_frame.dart';

/// The real apps in one phone: a screen of each project with screenshots,
/// changing every few seconds (never with reduced motion), and a chip per
/// app to pick one. The link under it opens the app's page.
class ProjectsShowcase extends ConsumerStatefulWidget {
  const ProjectsShowcase({super.key});

  static const Duration interval = Duration(seconds: 4);
  static const double phoneWidth = 280;

  @override
  ConsumerState<ProjectsShowcase> createState() => _ProjectsShowcaseState();
}

class _ProjectsShowcaseState extends ConsumerState<ProjectsShowcase> {
  Timer? _timer;
  int _index = 0;
  int _count = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// (Re)starts the rotation; a pick by hand gives the new app a full turn.
  void _schedule() {
    _timer?.cancel();
    if (_count < 2 || context.reduceMotion) return;
    _timer = Timer.periodic(ProjectsShowcase.interval, (_) {
      if (mounted) setState(() => _index = (_index + 1) % _count);
    });
  }

  void _pick(int index) {
    setState(() => _index = index);
    _schedule();
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocale.of(context).contentLanguage;
    final apps = [
      for (final project
          in ref.watch(projectsProvider(language)).value ?? const <Project>[])
        if (_firstScreen(project) != null) project,
    ];

    if (apps.isEmpty) {
      return const PhoneFrame(
        width: ProjectsShowcase.phoneWidth,
        child: SkeletonBox(height: double.infinity),
      );
    }
    if (apps.length != _count) {
      _count = apps.length;
      _index = _index % _count;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _schedule();
        // Decode every screen now, so the first change never flashes.
        for (final app in apps) {
          unawaited(
            precacheImage(
              AssetImage(_firstScreen(app)!),
              context,
              onError: (_, _) {},
            ),
          );
        }
      });
    }

    final current = apps[_index];
    final accent = Color(current.color);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          container: true,
          label: l10n.showcaseScreenLabel(current.name),
          child: PhoneFrame(
            width: ProjectsShowcase.phoneWidth,
            child: AnimatedSwitcher(
              duration: context.reduceMotion ? Duration.zero : AppMotion.medium,
              child: Image.asset(
                _firstScreen(current)!,
                key: ValueKey(current.slug),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                width: double.infinity,
                height: double.infinity,
                excludeFromSemantics: true,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    ColoredBox(color: accent),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            for (final (index, app) in apps.indexed)
              _AppChip(
                project: app,
                selected: index == _index,
                onTap: () => _pick(index),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go(
            AppRoutes.projectPath(AppLocale.of(context), current.slug),
          ),
          style: TextButton.styleFrom(foregroundColor: accent),
          child: Text(l10n.showcaseOpen(current.name)),
        ),
      ],
    );
  }
}

String? _firstScreen(Project project) {
  for (final media in project.media) {
    if (media.kind == ProjectMediaKind.phone) return media.asset;
  }
  return null;
}

class _AppChip extends StatelessWidget {
  const _AppChip({
    required this.project,
    required this.selected,
    required this.onTap,
  });

  final Project project;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = Color(project.color);
    final logo = project.logo;
    return Semantics(
      button: true,
      selected: selected,
      label: project.name,
      excludeSemantics: true,
      child: Material(
        color: selected
            ? accent.withValues(alpha: 0.14)
            : theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.pillAll,
          side: BorderSide(
            color: selected ? accent : theme.colorScheme.outline,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, AppSpacing.md, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: logo == null
                      ? ColoredBox(
                          color: accent,
                          child: const SizedBox.square(dimension: 24),
                        )
                      : Image.asset(
                          logo,
                          width: 24,
                          height: 24,
                          excludeFromSemantics: true,
                          errorBuilder: (context, error, stackTrace) =>
                              ColoredBox(
                                color: accent,
                                child: const SizedBox.square(dimension: 24),
                              ),
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  project.name,
                  style: AppTypography.sans(
                    size: 14,
                    weight: FontWeight.w600,
                    color: selected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
