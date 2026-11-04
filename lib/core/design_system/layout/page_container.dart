import 'package:flutter/widgets.dart';
import 'package:portfolio/core/design_system/layout/screen_size.dart';

/// Centers [child] with the page max width and the responsive gutter.
class PageContainer extends StatelessWidget {
  const PageContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = ScreenSize.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ScreenSize.maxContentWidth + size.gutter * 2,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.gutter),
          child: child,
        ),
      ),
    );
  }
}
