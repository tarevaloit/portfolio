import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Hero tags shared by the project card and the project detail.
abstract final class ProjectHeroTags {
  static String name(String slug) => 'project-name-$slug';
  static String cover(String slug) => 'project-cover-$slug';
}

/// Turns the project Heroes below it into plain widgets.
///
/// Used by previews that render project cards inside another Hero (the
/// home inside the "Este portfolio" phone), where Heroes cannot nest.
class ProjectHeroesScope extends InheritedWidget {
  const ProjectHeroesScope({
    required super.child,
    this.enabled = true,
    super.key,
  });

  final bool enabled;

  static bool enabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ProjectHeroesScope>()
          ?.enabled ??
      true;

  @override
  bool updateShouldNotify(ProjectHeroesScope oldWidget) =>
      enabled != oldWidget.enabled;
}

/// Project name that flies from the card title to the giant detail title.
///
/// The flight shows the big title scaled with a [FittedBox], so the text
/// grows without re-wrapping on every frame.
class ProjectNameHero extends StatelessWidget {
  const ProjectNameHero({required this.slug, required this.child, super.key});

  final String slug;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ProjectHeroesScope.enabledOf(context)) return child;
    return Hero(
      tag: ProjectHeroTags.name(slug),
      flightShuttleBuilder: _nameShuttle,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }

  static Widget _nameShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final big =
        (direction == HeroFlightDirection.push
                ? toHeroContext.widget
                : fromHeroContext.widget)
            as Hero;
    return FittedBox(alignment: Alignment.centerLeft, child: big.child);
  }
}

/// Colored card cover that flies into the phone frame of the detail.
///
/// The flight draws a plain rounded block in the project color, so neither
/// the cover nor the demo re-lays out mid-flight.
class ProjectCoverHero extends StatelessWidget {
  const ProjectCoverHero({
    required this.slug,
    required this.color,
    required this.child,
    super.key,
  });

  /// Corner radius of the card cover and of the phone frame.
  static const double cardRadius = 24;
  static const double phoneRadius = 48;

  final String slug;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!ProjectHeroesScope.enabledOf(context)) return child;
    return Hero(
      tag: ProjectHeroTags.cover(slug),
      flightShuttleBuilder: (context, animation, direction, from, to) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) => DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(
                lerpDouble(cardRadius, phoneRadius, animation.value)!,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}
