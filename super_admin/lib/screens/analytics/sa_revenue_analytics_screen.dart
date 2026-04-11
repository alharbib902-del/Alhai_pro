import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/sa_providers.dart';
import '../../data/models/sa_analytics_model.dart';

/// Revenue analytics: MRR, ARR, growth -- real Supabase data.
class SARevenueAnalyticsScreen extends ConsumerStatefulWidget {
  const SARevenueAnalyticsScreen({super.key});

  @override
  ConsumerState<SARevenueAnalyticsScreen> createState() =>
      _SARevenueAnalyticsScreenState();
}

class _SARevenueAnalyticsScreenState
    extends ConsumerState<SARevenueAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;
    final period = ref.watch(saRevenuePeriodProvider);

    final kpisAsync = ref.watch(saDashboardKPIsProvider);
    final monthlyRevenueAsync = ref.watch(saMonthlyRevenueProvider);
    final revenueByPlanAsync = ref.watch(saRevenueByPlanProvider);
    final topStoresAsync = ref.watch(saTopStoresByRevenueProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.revenueAnalytics,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'last30Days',
                      label: Text(l10n.last30Days),
                    ),
                    ButtonSegment(
                      value: 'last90Days',
                      label: Text(l10n.last90Days),
                    ),
                    ButtonSegment(
                      value: 'last12Months',
                      label: Text(l10n.last12Months),
                    ),
                  ],
                  selected: {period},
                  onSelectionChanged: (v) =>
                      ref.read(saRevenuePeriodProvider.notifier).state =
                          v.first,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // KPIs
            kpisAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (kpis) {
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AlhaiSpacing.md,
                  crossAxisSpacing: AlhaiSpacing.md,
                  childAspectRatio: 2.2,
                  children: [
                    _KpiCard(
                      title: l10n.monthlyRecurringRevenue,
                      value: _fmtNum(kpis.mrr),
                      suffix: l10n.sar,
                      icon: Icons.repeat_rounded,
                      color: isDark
                          ? const Color(0xFF2DD4BF)
                          : const Color(0xFF0D9488),
                    ),
                    _KpiCard(
                      title: l10n.annualRecurringRevenue,
                      value: _fmtNum(kpis.arr),
                      suffix: l10n.sar,
                      icon: Icons.calendar_today_rounded,
                      color: isDark
                          ? const Color(0xFF818CF8)
                          : const Color(0xFF4F46E5),
                    ),
                    _KpiCard(
                      title: l10n.activeSubscriptions,
                      value: '${kpis.activeSubscriptions}',
                      icon: Icons.card_membership_rounded,
                      color: isDark
                          ? const Color(0xFF4ADE80)
                          : const Color(0xFF15803D),
                    ),
                    _KpiCard(
                      title: l10n.trialSubscriptions,
                      value: '${kpis.trialSubscriptions}',
                      icon: Icons.science_rounded,
                      color: isDark
                          ? const Color(0xFFFB923C)
                          : const Color(0xFFEA580C),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // MRR Growth line chart
            Text(
              l10n.mrrGrowth,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            monthlyRevenueAsync.when(
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (data) => _MrrChart(theme: theme, monthlyData: data),
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // Revenue by plan
            Text(
              l10n.revenueByPlan,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            revenueByPlanAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (plans) => _RevenueByPlanTable(l10n: l10n, plans: plans),
            ),

            const SizedBox(height: AlhaiSpacing.xl),

            // Top stores by revenue
            Text(
              l10n.topStoresByRevenue,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            topStoresAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (stores) => _TopStoresTable(l10n: l10n, stores: stores),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtNum(double n) {
    final intVal = n.round();
    if (intVal >= 1000) {
      final s = intVal.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return intVal.toString();
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    this.suffix,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: AlhaiSpacing.xs),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: AlhaiSpacing.xxs),
                  Text(
                    suffix!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _MrrChart extends StatelessWidget {
  final ThemeData theme;
  final List<SARevenueData> monthlyData;
  const _MrrChart({required this.theme, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.card),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: AlhaiSpacing.strokeXs,
          ),
        ),
        child: SizedBox(
          height: 250,
          child: Center(
            child: Text(
              'No revenue data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    double maxY = 0;
    for (int i = 0; i < monthlyData.length; i++) {
      final val = monthlyData[i].revenue;
      // Show in thousands for chart
      final kVal = val / 1000;
      if (kVal > maxY) maxY = kVal;
      spots.add(FlSpot(i.toDouble(), kVal));
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt()}K',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= monthlyData.length) {
                        return const SizedBox();
                      }
                      final month = monthlyData[idx].month;
                      final label = month.length >= 7
                          ? month.substring(5)
                          : month;
                      return Padding(
                        padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                        child: Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RevenueByPlanTable extends StatelessWidget {
  final AppLocalizations l10n;
  final List<SARevenueByPlan> plans;
  const _RevenueByPlanTable({required this.l10n, required this.plans});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (plans.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Text(
            'No plan revenue data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    final totalRevenue = plans.fold<double>(0, (sum, p) => sum + p.revenue);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: DataTable(
        columnSpacing: AlhaiSpacing.xl,
        columns: [
          DataColumn(label: Text(l10n.planName)),
          const DataColumn(label: Text('Subscribers'), numeric: true),
          DataColumn(label: Text(l10n.revenue), numeric: true),
          const DataColumn(label: Text('% of Total'), numeric: true),
        ],
        rows: plans.map((plan) {
          final pct = totalRevenue > 0
              ? (plan.revenue / totalRevenue * 100).toStringAsFixed(1)
              : '0.0';

          return DataRow(
            cells: [
              DataCell(Text(plan.name)),
              DataCell(Text('${plan.subscribers}')),
              DataCell(Text('${plan.revenue.toStringAsFixed(0)} ${l10n.sar}')),
              DataCell(Text('$pct%')),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _TopStoresTable extends StatelessWidget {
  final AppLocalizations l10n;
  final List<SATopStoreRevenue> stores;
  const _TopStoresTable({required this.l10n, required this.stores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stores.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Text(
            'No store revenue data',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.card),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: AlhaiSpacing.strokeXs,
        ),
      ),
      child: DataTable(
        columnSpacing: AlhaiSpacing.xl,
        columns: [
          const DataColumn(label: Text('#')),
          DataColumn(label: Text(l10n.storeName)),
          DataColumn(label: Text(l10n.revenue), numeric: true),
        ],
        rows: List.generate(stores.length, (i) {
          final store = stores[i];

          return DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(store.storeName)),
              DataCell(Text('${store.revenue.toStringAsFixed(0)} ${l10n.sar}')),
            ],
          );
        }),
      ),
    );
  }
}
