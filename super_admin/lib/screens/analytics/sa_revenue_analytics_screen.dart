import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';

/// Revenue analytics: MRR, ARR, growth.
class SARevenueAnalyticsScreen extends StatefulWidget {
  const SARevenueAnalyticsScreen({super.key});

  @override
  State<SARevenueAnalyticsScreen> createState() =>
      _SARevenueAnalyticsScreenState();
}

class _SARevenueAnalyticsScreenState
    extends State<SARevenueAnalyticsScreen> {
  String _period = 'last12Months';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

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
                  selected: {_period},
                  onSelectionChanged: (v) =>
                      setState(() => _period = v.first),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // KPIs
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: 2.2,
              children: [
                _KpiCard(
                  title: l10n.monthlyRecurringRevenue,
                  value: '312,400',
                  suffix: l10n.sar,
                  change: '+5.2%',
                  icon: Icons.repeat_rounded,
                  color: Colors.teal,
                ),
                _KpiCard(
                  title: l10n.annualRecurringRevenue,
                  value: '3,748,800',
                  suffix: l10n.sar,
                  change: '+18.4%',
                  icon: Icons.calendar_today_rounded,
                  color: Colors.indigo,
                ),
                _KpiCard(
                  title: l10n.growth,
                  value: '23.5%',
                  change: '+3.1%',
                  icon: Icons.trending_up_rounded,
                  color: Colors.green,
                ),
                _KpiCard(
                  title: l10n.churnRate,
                  value: '2.4%',
                  change: '-0.3%',
                  icon: Icons.trending_down_rounded,
                  color: Colors.orange,
                ),
              ],
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
            _MrrChart(theme: theme),
            const SizedBox(height: AlhaiSpacing.xl),

            // Revenue by plan
            Text(
              l10n.revenueByPlan,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _RevenueByPlanTable(l10n: l10n),

            const SizedBox(height: AlhaiSpacing.xl),

            // Top stores by revenue
            Text(
              l10n.topStoresByRevenue,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _TopStoresTable(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final String change;
  final IconData icon;
  final Color color;

  const _KpiCard({
    required this.title,
    required this.value,
    this.suffix,
    required this.change,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change.startsWith('+');

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
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: AlhaiSpacing.xxxs),
                Text(
                  change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
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

class _MrrChart extends StatelessWidget {
  final ThemeData theme;
  const _MrrChart({required this.theme});

  @override
  Widget build(BuildContext context) {
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
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.3),
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
                      const months = [
                        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                      ];
                      final idx = value.toInt();
                      if (idx < 0 || idx >= months.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: AlhaiSpacing.xs),
                        child: Text(
                          months[idx],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minY: 150,
              maxY: 350,
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 180),
                    FlSpot(1, 195),
                    FlSpot(2, 210),
                    FlSpot(3, 225),
                    FlSpot(4, 240),
                    FlSpot(5, 250),
                    FlSpot(6, 262),
                    FlSpot(7, 275),
                    FlSpot(8, 285),
                    FlSpot(9, 295),
                    FlSpot(10, 305),
                    FlSpot(11, 312),
                  ],
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
  const _RevenueByPlanTable({required this.l10n});

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
      child: DataTable(
        columnSpacing: AlhaiSpacing.xl,
        columns: [
          DataColumn(label: Text(l10n.planName)),
          const DataColumn(label: Text('Subscribers'), numeric: true),
          DataColumn(label: Text(l10n.revenue), numeric: true),
          const DataColumn(label: Text('% of Total'), numeric: true),
        ],
        rows: [
          DataRow(cells: [
            DataCell(Text(l10n.basicPlan)),
            const DataCell(Text('531')),
            DataCell(Text('52,569 ${l10n.sar}')),
            const DataCell(Text('16.8%')),
          ]),
          DataRow(cells: [
            DataCell(Text(l10n.advancedPlan)),
            const DataCell(Text('413')),
            DataCell(Text('102,837 ${l10n.sar}')),
            const DataCell(Text('32.9%')),
          ]),
          DataRow(cells: [
            DataCell(Text(l10n.professionalPlan)),
            const DataCell(Text('236')),
            DataCell(Text('117,764 ${l10n.sar}')),
            const DataCell(Text('37.7%')),
          ]),
        ],
      ),
    );
  }
}

class _TopStoresTable extends StatelessWidget {
  final AppLocalizations l10n;
  const _TopStoresTable({required this.l10n});

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
      child: DataTable(
        columnSpacing: AlhaiSpacing.xl,
        columns: [
          const DataColumn(label: Text('#')),
          DataColumn(label: Text(l10n.storeName)),
          DataColumn(label: Text(l10n.storePlan)),
          DataColumn(label: Text(l10n.revenue), numeric: true),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('1')),
            DataCell(Text('Auto Parts KSA')),
            DataCell(Text('Professional')),
            DataCell(Text('6,230 SAR')),
          ]),
          DataRow(cells: [
            DataCell(Text('2')),
            DataCell(Text('Fresh Market')),
            DataCell(Text('Advanced')),
            DataCell(Text('5,640 SAR')),
          ]),
          DataRow(cells: [
            DataCell(Text('3')),
            DataCell(Text('Grocery Plus')),
            DataCell(Text('Professional')),
            DataCell(Text('4,520 SAR')),
          ]),
          DataRow(cells: [
            DataCell(Text('4')),
            DataCell(Text('Tech Zone')),
            DataCell(Text('Advanced')),
            DataCell(Text('3,180 SAR')),
          ]),
          DataRow(cells: [
            DataCell(Text('5')),
            DataCell(Text('Home Essentials')),
            DataCell(Text('Basic')),
            DataCell(Text('1,870 SAR')),
          ]),
        ],
      ),
    );
  }
}
