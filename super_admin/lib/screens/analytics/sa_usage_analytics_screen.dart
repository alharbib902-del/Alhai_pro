import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/sa_providers.dart';
import '../../data/models/sa_analytics_model.dart';

/// Usage analytics: active users, transactions per store -- real Supabase data.
class SAUsageAnalyticsScreen extends ConsumerWidget {
  const SAUsageAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AlhaiBreakpoints.desktop;

    final kpisAsync = ref.watch(saDashboardKPIsProvider);
    final avgTxAsync = ref.watch(saAvgDailyTransactionsProvider);
    final totalUsersAsync = ref.watch(saTotalUserCountProvider);
    final activeUsersAsync = ref.watch(saActiveUsersPerStoreProvider);
    final topStoresAsync = ref.watch(saTopStoresByTransactionsProvider);

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
            _buildKpis(
              theme: theme,
              isDark: isDark,
              l10n: l10n,
              isWide: isWide,
              kpisAsync: kpisAsync,
              avgTxAsync: avgTxAsync,
              totalUsersAsync: totalUsersAsync,
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
            activeUsersAsync.when(
              loading: () => const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (data) => _ActiveUsersChart(theme: theme, storeData: data),
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // Transactions per store ranking
            Text(
              l10n.topStoresByTransactions,
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
              data: (stores) => _TransactionsTable(l10n: l10n, stores: stores),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpis({
    required ThemeData theme,
    required bool isDark,
    required AppLocalizations l10n,
    required bool isWide,
    required AsyncValue<SADashboardKPIs> kpisAsync,
    required AsyncValue<double> avgTxAsync,
    required AsyncValue<int> totalUsersAsync,
  }) {
    // Show a loading state if any KPI is still loading
    final activeStores = kpisAsync.valueOrNull?.activeStores;
    final avgTx = avgTxAsync.valueOrNull;
    final totalUsers = totalUsersAsync.valueOrNull;

    final isLoading =
        kpisAsync.isLoading ||
        avgTxAsync.isLoading ||
        totalUsersAsync.isLoading;

    if (isLoading && activeStores == null) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GridView.count(
      crossAxisCount: isWide ? 3 : 1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AlhaiSpacing.md,
      crossAxisSpacing: AlhaiSpacing.md,
      childAspectRatio: isWide ? 2.5 : 3.0,
      children: [
        _UsageKpi(
          title: l10n.activeStores,
          value: _fmtInt(activeStores ?? 0),
          icon: Icons.store_rounded,
          color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
        ),
        _UsageKpi(
          title: l10n.avgTransactionsPerDay,
          value: _fmtInt(avgTx?.round() ?? 0),
          icon: Icons.receipt_long_rounded,
          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
        ),
        _UsageKpi(
          title: l10n.platformUsers,
          value: _fmtInt(totalUsers ?? 0),
          icon: Icons.people_rounded,
          color: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  String _fmtInt(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return n.toString();
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
  final List<SAActiveUsersPerStore> storeData;
  const _ActiveUsersChart({required this.theme, required this.storeData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (storeData.isEmpty) {
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
              'No active user data',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      );
    }

    final blueColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);
    final deepPurpleColor = isDark
        ? const Color(0xFFA78BFA)
        : const Color(0xFF7C3AED);
    final tealColor = isDark
        ? const Color(0xFF2DD4BF)
        : const Color(0xFF0D9488);
    final colors = [
      blueColor,
      deepPurpleColor,
      tealColor,
      blueColor,
      deepPurpleColor,
      tealColor,
      blueColor,
      deepPurpleColor,
    ];

    double maxY = 0;
    for (final s in storeData) {
      final v = s.activeUsers.toDouble();
      if (v > maxY) maxY = v;
    }
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 10;

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
              maxY: maxY,
              barGroups: List.generate(storeData.length, (i) {
                final y = storeData[i].activeUsers.toDouble();
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: y,
                      color: colors[i % colors.length],
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AlhaiRadius.xs),
                        topRight: Radius.circular(AlhaiRadius.xs),
                      ),
                    ),
                  ],
                );
              }),
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
                      final idx = value.toInt();
                      if (idx < 0 || idx >= storeData.length) {
                        return const SizedBox();
                      }
                      final name = storeData[idx].storeName;
                      // Truncate long names
                      final label = name.length > 8
                          ? name.substring(0, 8)
                          : name;
                      return Padding(
                        padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
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
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  final AppLocalizations l10n;
  final List<SATopStoreTransactions> stores;
  const _TransactionsTable({required this.l10n, required this.stores});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (stores.isEmpty) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Text(
            'No transaction data',
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
          DataColumn(label: Text(l10n.storeTransactions), numeric: true),
          DataColumn(label: Text(l10n.avgTransactionsPerDay), numeric: true),
          DataColumn(label: Text(l10n.storeProducts), numeric: true),
        ],
        rows: List.generate(stores.length, (i) {
          final store = stores[i];

          return DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(Text(store.storeName)),
              DataCell(Text(_fmtInt(store.transactions))),
              DataCell(Text('${store.avgPerDay}')),
              DataCell(Text(_fmtInt(store.products))),
            ],
          );
        }),
      ),
    );
  }

  String _fmtInt(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return buffer.toString();
    }
    return n.toString();
  }
}
