import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';

/// Neutral block shown while content loads, with the shape of the content.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({required this.height, this.width, super.key});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: AppRadii.mdAll,
      ),
    );
  }
}
