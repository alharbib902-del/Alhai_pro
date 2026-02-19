import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'أداء الكاشير',
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
                      const SnackBar(content: Text('تم إعادة تعيين الإحصائيات')),
                    );
                  },
                  tooltip: 'إعادة تعيين',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            
            // الإحصائيات
            Row(
              children: [
                Expanded(
                  child: _KpiCard(
                    icon: Icons.timer,
                    label: 'متوسط وقت البيع',
                    value: stats.avgSaleTime.toStringAsFixed(0),
                    unit: l10n.seconds,
                    color: _getTimeColor(stats.avgSaleTime),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    icon: Icons.speed,
                    label: 'عمليات/ساعة',
                    value: stats.salesPerHour.toStringAsFixed(1),
                    unit: '',
                    color: _getSalesColor(stats.salesPerHour),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KpiCard(
                    icon: Icons.error_outline,
                    label: 'نسبة الأخطاء',
                    value: stats.errorRate.toStringAsFixed(1),
                    unit: '%',
                    color: _getErrorColor(stats.errorRate),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // ملخص اليوم
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                    label: 'عمليات مكتملة',
                    value: '${stats.completedSales}',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  _SummaryItem(
                    label: 'إجمالي المبيعات',
                    value: '${stats.totalSales.toStringAsFixed(0)} ر.س',
                    icon: Icons.attach_money,
                    color: Colors.blue,
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  _SummaryItem(
                    label: 'أخطاء',
                    value: '${stats.errorCount}',
                    icon: Icons.warning_amber,
                    color: stats.errorCount > 0 ? Colors.red : Colors.grey,
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
    if (seconds < 30) return Colors.green;
    if (seconds < 60) return Colors.orange;
    return Colors.red;
  }

  Color _getSalesColor(double salesPerHour) {
    if (salesPerHour > 20) return Colors.green;
    if (salesPerHour > 10) return Colors.orange;
    return Colors.red;
  }

  Color _getErrorColor(double errorRate) {
    if (errorRate < 1) return Colors.green;
    if (errorRate < 5) return Colors.orange;
    return Colors.red;
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
          tooltip: 'متوسط وقت البيع',
        ),
        const SizedBox(width: 8),
        _MiniKpi(
          icon: Icons.speed,
          value: '${stats.salesPerHour.toStringAsFixed(0)}/h',
          tooltip: 'عمليات/ساعة',
        ),
        const SizedBox(width: 8),
        _MiniKpi(
          icon: Icons.check_circle,
          value: '${stats.completedSales}',
          tooltip: 'عمليات مكتملة',
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
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
                const SizedBox(width: 2),
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
        const SizedBox(height: 4),
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
