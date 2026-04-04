import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/stat_item.dart';

class DailyStatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const DailyStatsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deliveries = stats['today_deliveries'] ?? 0;
    final earnings = (stats['today_earnings'] ?? 0).toDouble();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
      ),
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
                  child: StatItem(
                    icon: Icons.local_shipping_rounded,
                    value: '$deliveries',
                    label: 'توصيلات',
                    iconColor: theme.colorScheme.primary,
                    valueStyle: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: StatItem(
                    icon: Icons.payments_rounded,
                    value: '${earnings.toStringAsFixed(0)} ر.س',
                    label: 'الأرباح',
                    iconColor: theme.colorScheme.primary,
                    valueStyle: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
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
