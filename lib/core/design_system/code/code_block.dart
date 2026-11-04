import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/app_layer_colors.dart';
import 'package:portfolio/core/design_system/app_typography.dart';
import 'package:portfolio/core/design_system/code/dart_highlighter.dart';
import 'package:portfolio/core/design_system/tokens/tokens.dart';

/// Code sample with its source path as a comment and Dart highlighting.
/// Long lines scroll inside the block, never the page.
class CodeBlock extends StatelessWidget {
  const CodeBlock({required this.path, required this.code, super.key});

  final String path;
  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final layers = AppLayerColors.of(context);
    final palette = CodePalette(
      plain: colors.onSurface,
      keyword: colors.primary,
      string: layers.presentation,
      number: layers.data,
      comment: AppColors.textMuted,
      type: colors.onSurface,
    );
    final base = AppTypography.monoStyle(size: 14, height: 1.7);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: colors.outline),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SelectableText.rich(
          DartHighlighter.highlight(
            '// $path\n${code.trimRight()}',
            base,
            palette,
          ),
        ),
      ),
    );
  }
}
