import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/sa_providers.dart';

/// Super Admin Dashboard -- Platform overview with real KPIs from Supabase.
class SADashboardScreen extends ConsumerWidget {
  const SADashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= AlhaiBreakpoints.desktopLarge ? 4 : 2;

    final kpisAsync = ref.watch(saDashboardKPIsProvider);
    final monthlyRevenueAsync = ref.watch(saMonthlyRevenueProvider);
    final subsDistAsync = ref.watch(saSubscriptionDistributionProvider);

    return Scaffold(
      body: kpisAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (kpis) {
          final activeStores = kpis['active_stores'] as int? ?? 0;
          final activeSubs = kpis['active_subscriptions'] as int? ?? 0;
          final trialSubs = kpis['trial_subscriptions'] as int? ?? 0;
          final newSignups = kpis['new_signups'] as int? ?? 0;
          final mrr = kpis['mrr'] as double? ?? 0;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(saDashboardKPIsProvider);
              ref.invalidate(saMonthlyRevenueProvider);
              ref.invalidate(saSubscriptionDistributionProvider);
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.platformOverview,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // KPI stat cards
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AlhaiSpacing.md,
                    crossAxisSpacing: AlhaiSpacing.md,
                    childAspectRatio: 2.2,
                    children: [
                      _StatCard(
                        title: l10n.activeStores,
                        value: _fmt(activeStores),
                        change: '',
                        icon: Icons.store_rounded,
                        color: theme.colorScheme.primary,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.totalRevenue,
                        value: _fmt(mrr.round()),
                        suffix: l10n.sar,
                        change: '',
                        icon: Icons.payments_rounded,
                        color: Colors.green,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.newSignups,
                        value: _fmt(newSignups),
                        change: '',
                        icon: Icons.person_add_rounded,
                        color: Colors.blue,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.activeSubscriptions,
                        value: _fmt(activeSubs),
                        change: '',
                        icon: Icons.card_membership_rounded,
                        color: Colors.indigo,
                        showArrow: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // Second row
                  GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AlhaiSpacing.md,
                    crossAxisSpacing: AlhaiSpacing.md,
                    childAspectRatio: 2.2,
                    children: [
                      _StatCard(
                        title: l10n.monthlyRecurringRevenue,
                        value: _fmt(mrr.round()),
                        suffix: l10n.sar,
                        change: '',
                        icon: Icons.repeat_rounded,
                        color: Colors.teal,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.trialConversion,
                        value: activeSubs > 0
                            ? '${((activeSubs / (activeSubs + trialSubs)) * 100).toStringAsFixed(1)}%'
                            : '0%',
                        change: '',
                        icon: Icons.swap_horiz_rounded,
                        color: Colors.deepPurple,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.subscriptionStats,
                        value: '$trialSubs / $activeSubs',
                        change: l10n.trialSubscriptions,
                        icon: Icons.science_rounded,
                        color: Colors.amber,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.annualRecurringRevenue,
                        value: _fmt((mrr * 12).round()),
                        suffix: l10n.sar,
                        change: '',
                        icon: Icons.calendar_today_rounded,
                        color: Colors.indigo,
                        showArrow: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // Revenue chart
                  _SectionTitle(title: l10n.revenueByMonth),
                  const SizedBox(height: AlhaiSpacing.md),
                  monthlyRevenueAsync.when(
                    loading: () =>
                        const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('$e'),
                    data: (data) => _RevenueChart(
                      theme: theme,
                      monthlyData: data,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // Subscription distribution
                  _SectionTitle(title: l10n.revenueByPlan),
                  const SizedBox(height: AlhaiSpacing.md),
                  subsDistAsync.when(
                    loading: () =>
                        const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => Text('$e'),
                    data: (dist) => _SubscriptionDistribution(
                      theme: theme,
                      l10n: l10n,
                      distribution: dist,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _fmt(int n) {
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? suffix;
  final String change;
  final IconData icon;
  final Color color;
  final bool isNegativeGood;
  final bool showArrow;

  const _StatCard({
    required this.title,
    required this.value,
    this.suffix,
    required this.change,
    required this.icon,
    required this.color,
    this.isNegativeGood = false,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = change.startsWith('+');
    final changeColor = showArrow
        ? ((isPositive && !isNegativeGood) || (!isPositive && isNegativeGood)
            ? Colors.green
            : Colors.red)
        : theme.colorScheme.outline;

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
            if (change.isNotEmpty)
              Row(
                children: [
                  if (showArrow)
                    Icon(
                      isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: changeColor,
                    ),
                  const SizedBox(width: AlhaiSpacing.xxxs),
                  Flexible(
                    child: Text(
                      change,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: changeColor,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final ThemeData theme;
  final List<Map<String, dynamic>> monthlyData;
  const _RevenueChart({required this.theme, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final maxY = monthlyData.isEmpty
        ? 100.0
        : monthlyData
                .map((e) => (e['revenue'] as num?)?.toDouble() ?? 0)
                .reduce((a, b) => a > b ? a : b) *
            1.2;

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
          height: 280,
          child: monthlyData.isEmpty
              ? Center(
                  child: Text(
                    'No revenue data',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barGroups: List.generate(monthlyData.length, (i) {
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: (monthlyData[i]['revenue'] as num?)
                                    ?.toDouble() ??
                                0,
                            color: theme.colorScheme.primary,
                            width: 16,
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
                          reservedSize: 50,
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
                            if (idx < 0 || idx >= monthlyData.length) {
                              return const SizedBox();
                            }
                            final month =
                                monthlyData[idx]['month'] as String? ?? '';
                            final label = month.length >= 7
                                ? month.substring(5)
                                : month;
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: AlhaiSpacing.xs),
                              child: Text(
                                label,
                                style:
                                    theme.textTheme.bodySmall?.copyWith(
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
}

class _SubscriptionDistribution extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  final Map<String, int> distribution;
  const _SubscriptionDistribution({
    required this.theme,
    required this.l10n,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Text('No subscriptions yet',
              style: theme.textTheme.bodyMedium),
        ),
      );
    }

    final planColors = {
      'basic': Colors.blue,
      'advanced': Colors.deepPurple,
      'professional': Colors.teal,
    };

    final planNames = {
      'basic': l10n.basicPlan,
      'advanced': l10n.advancedPlan,
      'professional': l10n.professionalPlan,
    };

    final sections = distribution.entries.map((e) {
      final pct = (e.value / total * 100);
      final color = planColors[e.key] ?? Colors.grey;
      return PieChartSectionData(
        value: pct,
        title: '${pct.toStringAsFixed(0)}%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();

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
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: distribution.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
                  child: _LegendItem(
                    color: planColors[e.key] ?? Colors.grey,
                    label: planNames[e.key] ?? e.key,
                    value: '${e.value}',
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
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
            borderRadius: BorderRadius.circular(AlhaiRadius.xs),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          '$label: $value',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
