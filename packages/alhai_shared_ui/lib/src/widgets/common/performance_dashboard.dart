import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors, AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/performance_provider.dart';

/// Widget لعرض لوحة KPIs الأداء
/// 
/// يعرض:
/// - متوسط وقت البيع
/// - عمليات/ساعة
/// - نسبة الأخطاء
class PerformanceDashboard extends ConsumerWidget {
  final bool compact;

  const PerformanceDashboard({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(performanceProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (compact) {
      return _CompactView(stats: stats);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                SizedBox(width: AlhaiSpacing.xs),
                Text(
                  l10n.cashierPerformance,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    ref.read(performanceProvider.notifier).resetSession();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.statsReset)),
                    );
                  },
                  tooltip: l10n.resetStatsAction,
                ),
              ],
            ),
            const Divider(),
            SizedBox(height: AlhaiSpacing.xs),
            
            // الإحصائيات
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    icon: Icons.timer,
                    label: l10n.averageSaleTime,
                    value: stats.avgSaleTime.toStringAsFixed(0),
                    unit: l10n.seconds,
                    color: _getTimeColor(stats.avgSaleTime),
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _KpiCard(
                    icon: Icons.speed,
                    label: l10n.operationsPerHour,
                    value: stats.salesPerHour.toStringAsFixed(1),
                    unit: '',
                    color: _getSalesColor(stats.salesPerHour),
                  ),
                ),
                SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: _KpiCard(
                    icon: Icons.error_outline,
                    label: l10n.errorRateLabel,
                    value: stats.errorRate.toStringAsFixed(1),
                    unit: '%',
                    color: _getErrorColor(stats.errorRate),
                  ),
                ),
              ],
            ),
            SizedBox(height: AlhaiSpacing.md),
            
            // ملخص اليوم
            Container(
              padding: const EdgeInsets.all(AlhaiSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: l10n.completedOperations,
                    value: '${stats.completedSales}',
                    icon: Icons.check_circle,
                    color: AlhaiColors.success,
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
                  _SummaryItem(
                    label: l10n.totalSales,
                    value: '${stats.totalSales.toStringAsFixed(0)} ${StoreSettings.defaultCurrencySymbol}',
                    icon: Icons.attach_money,
                    color: AlhaiColors.info,
                  ),
                  Container(width: 1, height: 30, color: Theme.of(context).dividerColor),
                  _SummaryItem(
                    label: l10n.errors,
                    value: '${stats.errorCount}',
                    icon: Icons.warning_amber,
                    color: stats.errorCount > 0 ? AlhaiColors.error : Theme.of(context).colorScheme.outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTimeColor(double seconds) {
    if (seconds < 30) return AlhaiColors.success;
    if (seconds < 60) return AlhaiColors.warning;
    return AlhaiColors.error;
  }

  Color _getSalesColor(double salesPerHour) {
    if (salesPerHour > 20) return AlhaiColors.success;
    if (salesPerHour > 10) return AlhaiColors.warning;
    return AlhaiColors.error;
  }

  Color _getErrorColor(double errorRate) {
    if (errorRate < 1) return AlhaiColors.success;
    if (errorRate < 5) return AlhaiColors.warning;
    return AlhaiColors.error;
  }
}

class _CompactView extends StatelessWidget {
  final PerformanceStats stats;

  const _CompactView({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _MiniKpi(
          icon: Icons.timer,
          value: '${stats.avgSaleTime.toStringAsFixed(0)}s',
          tooltip: AppLocalizations.of(context)!.averageSaleTime,
        ),
        SizedBox(width: AlhaiSpacing.xs),
        _MiniKpi(
          icon: Icons.speed,
          value: '${stats.salesPerHour.toStringAsFixed(0)}/h',
          tooltip: AppLocalizations.of(context)!.operationsPerHour,
        ),
        SizedBox(width: AlhaiSpacing.xs),
        _MiniKpi(
          icon: Icons.check_circle,
          value: '${stats.completedSales}',
          tooltip: AppLocalizations.of(context)!.completedOperations,
        ),
      ],
    );
  }
}

class _MiniKpi extends StatelessWidget {
  final IconData icon;
  final String value;
  final String tooltip;

  const _MiniKpi({
    required this.icon,
    required this.value,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxs),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
            SizedBox(width: AlhaiSpacing.xxs),
            Text(value, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AlhaiSpacing.xs),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AlhaiSpacing.xxs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: AlhaiSpacing.xxxs),
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(height: AlhaiSpacing.xxs),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
