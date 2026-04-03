import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';

class DailyStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DailyStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveries = stats['today_deliveries'] ?? 0;
    final earnings = (stats['today_earnings'] ?? 0).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات اليوم',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.local_shipping_rounded,
                    value: '$deliveries',
                    label: 'توصيلات',
                    color: theme.colorScheme.primary,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.dividerColor,
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.payments_rounded,
                    value: '${earnings.toStringAsFixed(0)} ر.س',
                    label: 'الأرباح',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xxs),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}
