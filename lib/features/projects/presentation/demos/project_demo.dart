import 'package:flutter/material.dart';
import 'package:portfolio/features/projects/domain/entities/project.dart';
import 'package:portfolio/features/projects/presentation/demos/fishar_demo.dart';
import 'package:portfolio/features/projects/presentation/demos/fundido_demo.dart';
import 'package:portfolio/features/projects/presentation/demos/laburito_demo.dart';

/// Mini app shown inside the phone frame of a project detail.
///
/// Each demo is a hand-made mock of the real app (not its code). Projects
/// without one show a plain screen in their color.
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
    return switch (project.slug) {
      'fishar' => const FisharDemo(),
      'fundido' => const FundidoDemo(),
      'laburito' => const LaburitoDemo(),
      _ => ColoredBox(color: Color(project.color)),
    };
  }
}
