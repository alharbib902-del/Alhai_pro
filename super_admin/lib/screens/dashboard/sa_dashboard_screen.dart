import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/sa_providers.dart';
import '../../data/models/sa_analytics_model.dart';
import '../../ui/widgets/sa_skeleton.dart';

/// Super Admin Dashboard -- Platform overview with real KPIs from Supabase.
class SADashboardScreen extends ConsumerWidget {
  const SADashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= AlhaiBreakpoints.desktopLarge ? 4 : 2;

    final kpisAsync = ref.watch(saDashboardKPIsProvider);
    final monthlyRevenueAsync = ref.watch(saMonthlyRevenueProvider);
    final subsDistAsync = ref.watch(saSubscriptionDistributionProvider);

    // Theme-aware colors
    final greenColor =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
    final blueColor =
        isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final indigoColor =
        isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
    final tealColor =
        isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    final deepPurpleColor =
        isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED);
    final amberColor =
        isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

    return Scaffold(
      body: kpisAsync.when(
        loading: () => const SADashboardSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (kpis) {
          final activeStores = kpis.activeStores;
          final activeSubs = kpis.activeSubscriptions;
          final trialSubs = kpis.trialSubscriptions;
          final newSignups = kpis.newSignups;
          final mrr = kpis.mrr;

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
                        color: colorScheme.primary,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.totalRevenue,
                        value: _fmt(mrr.round()),
                        suffix: l10n.sar,
                        change: '',
                        icon: Icons.payments_rounded,
                        color: greenColor,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.newSignups,
                        value: _fmt(newSignups),
                        change: '',
                        icon: Icons.person_add_rounded,
                        color: blueColor,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.activeSubscriptions,
                        value: _fmt(activeSubs),
                        change: '',
                        icon: Icons.card_membership_rounded,
                        color: indigoColor,
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
                        color: tealColor,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.trialConversion,
                        value: activeSubs > 0
                            ? '${((activeSubs / (activeSubs + trialSubs)) * 100).toStringAsFixed(1)}%'
                            : '0%',
                        change: '',
                        icon: Icons.swap_horiz_rounded,
                        color: deepPurpleColor,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.subscriptionStats,
                        value: '$trialSubs / $activeSubs',
                        change: l10n.trialSubscriptions,
                        icon: Icons.science_rounded,
                        color: amberColor,
                        showArrow: false,
                      ),
                      _StatCard(
                        title: l10n.annualRecurringRevenue,
                        value: _fmt((mrr * 12).round()),
                        suffix: l10n.sar,
                        change: '',
                        icon: Icons.calendar_today_rounded,
                        color: indigoColor,
                        showArrow: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // Revenue chart
                  _SectionTitle(title: l10n.revenueByMonth),
                  const SizedBox(height: AlhaiSpacing.md),
                  monthlyRevenueAsync.when(
                    loading: () => const AlhaiShimmer(
                      child: AlhaiSkeleton.rectangle(
                          width: double.infinity, height: 280),
                    ),
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
                    loading: () => const AlhaiShimmer(
                      child: AlhaiSkeleton.rectangle(
                          width: double.infinity, height: 200),
                    ),
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
    final isDark = theme.brightness == Brightness.dark;
    final isPositive = change.startsWith('+');
    final positiveColor =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D);
    final changeColor = showArrow
        ? ((isPositive && !isNegativeGood) || (!isPositive && isNegativeGood)
            ? positiveColor
            : theme.colorScheme.error)
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
  final List<SARevenueData> monthlyData;
  const _RevenueChart({required this.theme, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    final maxY = monthlyData.isEmpty
        ? 100.0
        : monthlyData.map((e) => e.revenue).reduce((a, b) => a > b ? a : b) *
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
                    AppLocalizations.of(context).saNoRevenueData,
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
                            toY: monthlyData[i].revenue,
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
                            final month = monthlyData[idx].month;
                            final label =
                                month.length >= 7 ? month.substring(5) : month;
                            return Padding(
                              padding:
                                  const EdgeInsets.only(top: AlhaiSpacing.xs),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final total = distribution.values.fold(0, (a, b) => a + b);
    if (total == 0) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child:
              Text(l10n.saNoSubscriptionsYet, style: theme.textTheme.bodyMedium),
        ),
      );
    }

    final planColors = {
      'basic': isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      'advanced': isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
      'professional':
          isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488),
    };

    final planNames = {
      'basic': l10n.basicPlan,
      'advanced': l10n.advancedPlan,
      'professional': l10n.professionalPlan,
    };

    final sections = distribution.entries.map((e) {
      final pct = (e.value / total * 100);
      final color = planColors[e.key] ?? colorScheme.outline;
      return PieChartSectionData(
        value: pct,
        title: '${pct.toStringAsFixed(0)}%',
        color: color,
        radius: 60,
        titleStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
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
                    color: planColors[e.key] ?? colorScheme.outline,
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
