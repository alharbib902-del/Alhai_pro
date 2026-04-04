/// Lite Weekly Comparison Screen
///
/// Compares current week vs previous week metrics:
/// sales, orders, customers, and average ticket.
/// Queries real data from salesDao via Riverpod providers.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/lite_screen_providers.dart';

/// Weekly comparison report for Admin Lite
class LiteWeeklyComparisonScreen extends ConsumerWidget {
  const LiteWeeklyComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;
    final dataAsync = ref.watch(liteWeeklyComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weekly),
        centerTitle: true,
      ),
      body: dataAsync.when(
        data: (data) => SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildComparisonCards(context, isDark, isMobile, l10n, data),
              const SizedBox(height: AlhaiSpacing.lg),
              _buildDayBreakdown(context, isDark, l10n, data),
              const SizedBox(height: AlhaiSpacing.lg),
            ],
          ),
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AlhaiSpacing.massive),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.massive),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48,
                    color: isDark
                        ? Colors.white30
                        : Theme.of(context).colorScheme.outlineVariant),
                const SizedBox(height: AlhaiSpacing.md),
                Text(l10n.errorOccurred),
                const SizedBox(height: AlhaiSpacing.sm),
                TextButton.icon(
                  onPressed: () => ref.invalidate(liteWeeklyComparisonProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tryAgain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _changePercent(double current, double previous) {
    if (previous <= 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  Widget _buildComparisonCards(BuildContext context, bool isDark, bool isMobile,
      AppLocalizations l10n, WeeklyComparisonData data) {
    final avgThis = data.thisWeek.count > 0
        ? data.thisWeek.total / data.thisWeek.count
        : 0.0;
    final avgLast = data.lastWeek.count > 0
        ? data.lastWeek.total / data.lastWeek.count
        : 0.0;

    final items = [
      _ComparisonItem(
          l10n.totalSales,
          data.thisWeek.total.toStringAsFixed(0),
          _changePercent(data.thisWeek.total, data.lastWeek.total),
          Icons.trending_up),
      _ComparisonItem(
          l10n.orders,
          '${data.thisWeek.count}',
          _changePercent(
              data.thisWeek.count.toDouble(), data.lastWeek.count.toDouble()),
          Icons.receipt),
      _ComparisonItem(
          l10n.customers,
          '${data.thisWeekCustomers}',
          _changePercent(data.thisWeekCustomers.toDouble(),
              data.lastWeekCustomers.toDouble()),
          Icons.people),
      _ComparisonItem(l10n.averageSale, avgThis.toStringAsFixed(1),
          _changePercent(avgThis, avgLast), Icons.analytics),
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildComparisonCard(context, items[0], isDark)),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(child: _buildComparisonCard(context, items[1], isDark)),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildComparisonCard(context, items[2], isDark)),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(child: _buildComparisonCard(context, items[3], isDark)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: items.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: entry.key < items.length - 1 ? AlhaiSpacing.sm : 0,
            ),
            child: _buildComparisonCard(context, entry.value, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComparisonCard(
      BuildContext context, _ComparisonItem item, bool isDark) {
    final isPositive = item.changePercent >= 0;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, size: 20, color: AlhaiColors.primary),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            item.current,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxxs),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositive ? AlhaiColors.success : AlhaiColors.error,
              ),
              Text(
                '${item.changePercent.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AlhaiColors.success : AlhaiColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayBreakdown(BuildContext context, bool isDark,
      AppLocalizations l10n, WeeklyComparisonData data) {
    final maxVal = data.dailyBreakdown.fold<double>(1.0, (max, d) {
      final m = d.current > d.previous ? d.current : d.previous;
      return m > max ? m : max;
    });

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white12
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sales,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: [
              _LegendDot(color: AlhaiColors.primary, label: l10n.thisWeek),
              const SizedBox(width: AlhaiSpacing.md),
              _LegendDot(color: Colors.grey, label: l10n.yesterday),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...data.dailyBreakdown.map((day) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      day.dayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: Column(
                      children: [
                        _BarRow(
                            value: maxVal > 0 ? day.current / maxVal : 0,
                            color: AlhaiColors.primary),
                        const SizedBox(height: AlhaiSpacing.xxxs),
                        _BarRow(
                            value: maxVal > 0 ? day.previous / maxVal : 0,
                            color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ComparisonItem {
  final String label;
  final String current;
  final double changePercent;
  final IconData icon;
  const _ComparisonItem(
      this.label, this.current, this.changePercent, this.icon);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _BarRow extends StatelessWidget {
  final double value;
  final Color color;
  const _BarRow({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: value.clamp(0.0, 1.0),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
