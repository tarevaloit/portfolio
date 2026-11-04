import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// `ES / EN` switch: the current language is highlighted and the other one
/// is a link to the same page in that language.
class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final current = AppLocale.of(context);
    final style = AppTypography.monoStyle(size: 12, weight: FontWeight.w600);

    final items = <Widget>[];
    for (final locale in AppLocale.values) {
      if (items.isNotEmpty) {
        items.add(
          ExcludeSemantics(
            child: Text(
              '/',
              style: style.copyWith(color: AppColors.textMuted),
            ),
          ),
        );
      }
      final code = locale.name.toUpperCase();
      items.add(
        locale == current
            ? Semantics(
                selected: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    code,
                    style: style.copyWith(color: colors.primary),
                  ),
                ),
              )
            : Tooltip(
                message: context.l10n.switchLanguage,
                excludeFromSemantics: true,
                child: Semantics(
                  label: context.l10n.switchLanguage,
                  button: true,
                  excludeSemantics: true,
                  child: TextButton(
                    onPressed: () => context.go(locale.homePath),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(36, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      foregroundColor: colors.onSurfaceVariant,
                      textStyle: style,
                    ),
                    child: Text(code),
                  ),
                ),
              ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: items);
  }
}
