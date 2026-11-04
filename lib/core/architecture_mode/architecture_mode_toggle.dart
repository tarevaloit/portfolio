import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_controller.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// Nav pill with the "Modo arquitectura" switch. On compact screens only
/// the switch is drawn; the label is still read by screen readers.
class ArchitectureModeToggle extends ConsumerWidget {
  const ArchitectureModeToggle({this.showLabel = true, super.key});

  final bool showLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(architectureModeProvider);
    final colors = Theme.of(context).colorScheme;
    final label = context.l10n.architectureMode;

    return MergeSemantics(
      child: Semantics(
        label: label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadii.pillAll,
            onTap: () => ref.read(architectureModeProvider.notifier).toggle(),
            child: Ink(
              padding: EdgeInsets.only(
                left: showLabel ? AppSpacing.md : AppSpacing.xxs,
                right: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: AppRadii.pillAll,
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showLabel)
                    ExcludeSemantics(
                      child: Text(
                        label,
                        style: AppTypography.monoStyle(
                          size: 12,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  SizedBox(
                    height: 36,
                    child: FittedBox(
                      child: Switch(
                        value: enabled,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (_) => ref
                            .read(architectureModeProvider.notifier)
                            .toggle(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
