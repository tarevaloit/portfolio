import 'package:flutter/material.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';

/// Mini app shown inside the phone of a project detail when there are no
/// screenshots of the real app.
///
/// Other features provide theirs by slug (the home preview for "Este
/// portfolio"); any other project shows a plain screen in its color.
class ProjectDemo extends StatelessWidget {
  const ProjectDemo({
    required this.project,
    this.extraDemos = const {},
    super.key,
  });

  final Project project;
  final Map<String, WidgetBuilder> extraDemos;

  @override
  Widget build(BuildContext context) {
    final extra = extraDemos[project.slug];
    if (extra != null) return extra(context);
    return ColoredBox(color: Color(project.color));
  }
}
