import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';

/// Super Admin Dashboard -- Platform overview with KPIs and charts.
class SADashboardScreen extends StatelessWidget {
  const SADashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= AlhaiBreakpoints.desktopLarge ? 4 : 2;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page title
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
                  value: '1,247',
                  change: '+12%',
                  icon: Icons.store_rounded,
                  color: theme.colorScheme.primary,
                ),
                _StatCard(
                  title: l10n.totalRevenue,
                  value: '847,500',
                  suffix: l10n.sar,
                  change: '+8.3%',
                  icon: Icons.payments_rounded,
                  color: Colors.green,
                ),
                _StatCard(
                  title: l10n.churnRate,
                  value: '2.4%',
                  change: '-0.3%',
                  icon: Icons.trending_down_rounded,
                  color: Colors.orange,
                  isNegativeGood: true,
                ),
                _StatCard(
                  title: l10n.trialConversion,
                  value: '34.7%',
                  change: '+2.1%',
                  icon: Icons.swap_horiz_rounded,
                  color: Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Second row: MRR / Subscription breakdown
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
                  value: '312,400',
                  suffix: l10n.sar,
                  change: '+5.2%',
                  icon: Icons.repeat_rounded,
                  color: Colors.teal,
                ),
                _StatCard(
                  title: l10n.newSignups,
                  value: '89',
                  change: '+15',
                  icon: Icons.person_add_rounded,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: l10n.activeSubscriptions,
                  value: '1,180',
                  change: '+24',
                  icon: Icons.card_membership_rounded,
                  color: Colors.indigo,
                ),
                _StatCard(
                  title: l10n.subscriptionStats,
                  value: '67 / 1,180',
                  change: l10n.trialSubscriptions,
                  icon: Icons.science_rounded,
                  color: Colors.amber,
                  showArrow: false,
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.xl),

            // Charts row
            _SectionTitle(title: l10n.revenueByMonth),
            const SizedBox(height: AlhaiSpacing.md),
            _RevenueChart(theme: theme),

            const SizedBox(height: AlhaiSpacing.xl),

            // Subscription distribution pie chart
            _SectionTitle(title: l10n.revenueByPlan),
            const SizedBox(height: AlhaiSpacing.md),
            _SubscriptionDistribution(theme: theme, l10n: l10n),
          ],
        ),
      ),
    );
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
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChart extends StatelessWidget {
  final ThemeData theme;
  const _RevenueChart({required this.theme});

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
          height: 280,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 400,
              barGroups: _generateBarGroups(),
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
                      if (idx < 0 || idx >= months.length) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    final values = [
      180.0, 210.0, 240.0, 260.0, 280.0, 295.0,
      310.0, 320.0, 335.0, 350.0, 370.0, 312.0,
    ];
    return List.generate(12, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            color: theme.colorScheme.primary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AlhaiRadius.xs),
              topRight: Radius.circular(AlhaiRadius.xs),
            ),
          ),
        ],
      );
    });
  }
}

class _SubscriptionDistribution extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;
  const _SubscriptionDistribution(
      {required this.theme, required this.l10n});

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
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        value: 45,
                        title: '45%',
                        color: Colors.blue,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      PieChartSectionData(
                        value: 35,
                        title: '35%',
                        color: Colors.deepPurple,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      PieChartSectionData(
                        value: 20,
                        title: '20%',
                        color: Colors.teal,
                        radius: 60,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AlhaiSpacing.lg),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendItem(
                  color: Colors.blue,
                  label: l10n.basicPlan,
                  value: '531',
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                _LegendItem(
                  color: Colors.deepPurple,
                  label: l10n.advancedPlan,
                  value: '413',
                ),
                const SizedBox(height: AlhaiSpacing.sm),
                _LegendItem(
                  color: Colors.teal,
                  label: l10n.professionalPlan,
                  value: '236',
                ),
              ],
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
