import 'package:flutter/material.dart';
import 'package:portfolio/core/design_system/design_system.dart';
import 'package:portfolio/core/l10n/l10n.dart';

/// The three headline metrics. Stacked on compact screens.
class MetricsRow extends StatelessWidget {
  const MetricsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metrics = [
      (l10n.metricYearsValue, l10n.metricYearsLabel),
      (l10n.metricStoresValue, l10n.metricStoresLabel),
      (l10n.metricAiValue, l10n.metricAiLabel),
    ];
    final cards = [
      for (final (value, label) in metrics)
        _MetricCard(value: value, label: label),
    ];

    return ResponsiveGrid(
      columns: ScreenSize.of(context).isCompact ? 1 : 3,
      spacing: AppSpacing.sm,
      children: cards,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.smAll,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg - 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.sans(
                size: 30,
                weight: FontWeight.w700,
                height: 1.1,
                letterSpacing: -0.8,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
