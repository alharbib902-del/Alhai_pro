import 'package:flutter/material.dart';

import '../../tokens/alhai_spacing.dart';

/// Alhai Chart Card - Dashboard chart container (v1.1.0)
/// Used in: admin_pos, super_admin dashboards
class AlhaiChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final List<Widget>? actions;
  final Widget? legend;
  final bool isLoading;
  final double? height;

  const AlhaiChartCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.chart,
    this.actions,
    this.legend,
    this.isLoading = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (actions != null) ...[
                  Row(children: actions!),
                ],
              ],
            ),
            const SizedBox(height: AlhaiSpacing.mdl),
            // Chart
            isLoading
                ? SizedBox(
                    height: height ?? 200,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : SizedBox(
                    height: height ?? 200,
                    child: chart,
                  ),
            // Legend
            if (legend != null) ...[
              const SizedBox(height: AlhaiSpacing.md),
              legend!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Legend item for charts
class AlhaiLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String? value;

  const AlhaiLegendItem({
    super.key,
    required this.color,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        if (value != null) ...[
          const SizedBox(width: AlhaiSpacing.xxs),
          Text(
            value!,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

/// Chart legend row
class AlhaiChartLegend extends StatelessWidget {
  final List<AlhaiLegendItem> items;
  final MainAxisAlignment alignment;

  const AlhaiChartLegend({
    super.key,
    required this.items,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AlhaiSpacing.md,
      runSpacing: AlhaiSpacing.xs,
      children: items,
    );
  }
}
