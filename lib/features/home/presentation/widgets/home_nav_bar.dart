import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portfolio/core/architecture_mode/architecture_mode_toggle.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// Sections the nav can scroll to.
enum HomeSection { projects, experience, contact }

/// Top bar: logo, section links, language switch and the architecture mode
/// toggle. Section links are hidden on compact screens.
class HomeNavBar extends StatelessWidget {
  const HomeNavBar({required this.onSectionSelected, super.key});

  final ValueChanged<HomeSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = ScreenSize.of(context);
    final locale = AppLocale.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          BrandLogo(text: l10n.brandName),
          const Spacer(),
          if (!size.isCompact) ...[
            _NavLink(
              label: l10n.navProjects,
              onPressed: () => onSectionSelected(HomeSection.projects),
            ),
            _NavLink(
              label: l10n.navExperience,
              onPressed: () => onSectionSelected(HomeSection.experience),
            ),
            _NavLink(
              label: l10n.navContact,
              onPressed: () => onSectionSelected(HomeSection.contact),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Tooltip(
            message: l10n.switchLanguage,
            excludeFromSemantics: true,
            child: Semantics(
              label: l10n.switchLanguage,
              excludeSemantics: true,
              button: true,
              child: TextButton(
                onPressed: () => context.go(locale.other.homePath),
                child: Text(l10n.navLanguageShort),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          ArchitectureModeToggle(showLabel: !size.isCompact),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        textStyle: AppTypography.sans(size: 14, weight: FontWeight.w500),
      ),
      child: Text(label),
    );
  }
}
