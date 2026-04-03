import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';

/// Usage analytics: active users, transactions per store.
class SAUsageAnalyticsScreen extends StatelessWidget {
  const SAUsageAnalyticsScreen({super.key});

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
            Text(
              l10n.usageAnalytics,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Summary KPIs
            GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AlhaiSpacing.md,
              crossAxisSpacing: AlhaiSpacing.md,
              childAspectRatio: isWide ? 2.5 : 3.0,
              children: [
                _UsageKpi(
                  title: l10n.activeStores,
                  value: '1,247',
                  icon: Icons.store_rounded,
                  color: Colors.blue,
                ),
                _UsageKpi(
                  title: l10n.avgTransactionsPerDay,
                  value: '8,430',
                  icon: Icons.receipt_long_rounded,
                  color: Colors.teal,
                ),
                _UsageKpi(
                  title: l10n.platformUsers,
                  value: '4,892',
                  icon: Icons.people_rounded,
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // Active users chart
            Text(
              l10n.activeUsersPerStore,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _ActiveUsersChart(theme: theme),
            const SizedBox(height: AlhaiSpacing.xl),

            // Transactions per store ranking
            Text(
              l10n.topStoresByTransactions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.md),
            _TransactionsTable(l10n: l10n),
          ],
        ),
      ),
    );
  }
}

class _UsageKpi extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _UsageKpi({
    required this.title,
    required this.value,
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
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AlhaiRadius.sm),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: AlhaiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxxs),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveUsersChart extends StatelessWidget {
  final ThemeData theme;
  const _ActiveUsersChart({required this.theme});

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
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 600,
              barGroups: [
                _bar(0, 520, Colors.blue),
                _bar(1, 380, Colors.deepPurple),
                _bar(2, 290, Colors.teal),
                _bar(3, 450, Colors.blue),
                _bar(4, 340, Colors.deepPurple),
                _bar(5, 560, Colors.teal),
                _bar(6, 280, Colors.blue),
                _bar(7, 410, Colors.deepPurple),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt()}',
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
                      const stores = [
                        'Grocery+', 'TechZ', 'Fashion', 'HomeE',
                        'Beauty', 'AutoP', 'BookH', 'FreshM',
                      ];
                      final idx = value.toInt();
                      if (idx < 0 || idx >= stores.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding:
                            const EdgeInsets.only(top: AlhaiSpacing.xs),
                        child: Text(
                          stores[idx],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                            fontSize: 10,
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant
                      .withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AlhaiRadius.xs),
            topRight: Radius.circular(AlhaiRadius.xs),
          ),
        ),
      ],
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  final AppLocalizations l10n;
  const _TransactionsTable({required this.l10n});

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
          DataColumn(
            label: Text(l10n.storeTransactions),
            numeric: true,
          ),
          DataColumn(
            label: Text(l10n.avgTransactionsPerDay),
            numeric: true,
          ),
          DataColumn(
            label: Text(l10n.storeProducts),
            numeric: true,
          ),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('1')),
            DataCell(Text('Auto Parts KSA')),
            DataCell(Text('6,230')),
            DataCell(Text('207')),
            DataCell(Text('3,450')),
          ]),
          DataRow(cells: [
            DataCell(Text('2')),
            DataCell(Text('Fresh Market')),
            DataCell(Text('5,640')),
            DataCell(Text('188')),
            DataCell(Text('2,100')),
          ]),
          DataRow(cells: [
            DataCell(Text('3')),
            DataCell(Text('Grocery Plus')),
            DataCell(Text('4,520')),
            DataCell(Text('150')),
            DataCell(Text('1,832')),
          ]),
          DataRow(cells: [
            DataCell(Text('4')),
            DataCell(Text('Tech Zone')),
            DataCell(Text('3,180')),
            DataCell(Text('106')),
            DataCell(Text('890')),
          ]),
          DataRow(cells: [
            DataCell(Text('5')),
            DataCell(Text('Home Essentials')),
            DataCell(Text('1,870')),
            DataCell(Text('62')),
            DataCell(Text('1,200')),
          ]),
        ],
      ),
    );
  }
}
