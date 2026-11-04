import 'package:flutter/material.dart';
import 'package:portfolio/features/home/presentation/pages/home_page.dart';
import 'package:portfolio/features/projects/presentation/widgets/project_heroes.dart';

/// The live home, scaled into a phone screen: the demo of "Este portfolio".
/// Rendered at 390 px wide, so it uses the compact layout, and scrollable.
class HomePreview extends StatelessWidget {
  const HomePreview({super.key});

  static const double logicalWidth = 390;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / logicalWidth;
        final size = Size(logicalWidth, constraints.maxHeight / scale);
        return FittedBox(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(
            size: size,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                size: size,
                padding: EdgeInsets.zero,
                viewPadding: EdgeInsets.zero,
              ),
              // It sits inside the phone Hero, and Heroes cannot nest.
              child: const ProjectHeroesScope(
                enabled: false,
                child: HomePage(),
              ),
            ),
          ),
        );
      },
    );
  }
}
