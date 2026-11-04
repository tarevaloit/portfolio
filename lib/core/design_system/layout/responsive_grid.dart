import 'package:flutter/widgets.dart';

/// Grid of [columns] columns where every row is as tall as its tallest
/// child. Children receive a bounded height, so they can use `Expanded`.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.columns,
    required this.children,
    this.spacing = 20,
    super.key,
  }) : assert(columns > 0, 'columns must be positive');

  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var start = 0; start < children.length; start += columns) {
      final rowChildren = <Widget>[];
      for (var column = 0; column < columns; column++) {
        if (column > 0) rowChildren.add(SizedBox(width: spacing));
        final index = start + column;
        rowChildren.add(
          Expanded(
            child: index < children.length
                ? children[index]
                : const SizedBox.shrink(),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rowChildren,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
