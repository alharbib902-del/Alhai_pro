/// Sales Trend Mini Chart Screen
///
/// Displays sales trends with a simple bar chart visualization,
/// period selector (day/week/month), and comparison indicators.
/// Uses liteDailySalesProvider and liteWeeklyComparisonProvider.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../providers/lite_screen_providers.dart';

/// Sales Trend Screen - mini chart with period comparison
class LiteSalesTrendScreen extends ConsumerStatefulWidget {
  const LiteSalesTrendScreen({super.key});

  @override
  ConsumerState<LiteSalesTrendScreen> createState() =>
      _LiteSalesTrendScreenState();
}

class _LiteSalesTrendScreenState extends ConsumerState<LiteSalesTrendScreen> {
  int _selectedPeriod = 0; // 0=day, 1=week, 2=month

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context);

    final dailyAsync = ref.watch(liteDailySalesProvider);
    final weeklyAsync = ref.watch(liteWeeklyComparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salesAnalytics),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(liteDailySalesProvider);
              ref.invalidate(liteWeeklyComparisonProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(l10n, isDark),
            const SizedBox(height: AlhaiSpacing.lg),

            // Summary cards
            dailyAsync.when(
              data: (data) => _buildSummaryCards(isDark, isMobile, l10n, data),
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(AlhaiSpacing.lg),
                child: CircularProgressIndicator(),
              )),
              error: (_, __) => Center(child: Text(l10n.errorOccurred)),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Chart area
            weeklyAsync.when(
              data: (data) => _buildChartCard(isDark, l10n, data),
              loading: () => const Center(
                  child: Padding(
                padding: EdgeInsets.all(AlhaiSpacing.lg),
                child: CircularProgressIndicator(),
              )),
              error: (_, __) => Center(child: Text(l10n.errorOccurred)),
            ),
            const SizedBox(height: AlhaiSpacing.lg),

            // Comparison section
            weeklyAsync.when(
              data: (data) => _buildComparisonSection(isDark, l10n, data),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(AppLocalizations l10n, bool isDark) {
    final periods = [l10n.daily, l10n.weekly, l10n.thisMonth];
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: periods.asMap().entries.map((entry) {
          final isSelected = _selectedPeriod == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = entry.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AlhaiColors.primary : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected && !isDark
                      ? [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4)
                        ]
                      : null,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? (isDark ? Colors.white : AlhaiColors.primary)
                        : (isDark ? Colors.white54 : Colors.black54),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCards(
      bool isDark, bool isMobile, AppLocalizations l10n, DailySalesData data) {
    final items = [
      _SummaryItem(l10n.totalSales, data.todayStats.total.toStringAsFixed(0),
          AlhaiColors.success, Icons.trending_up),
      _SummaryItem(l10n.orders, '${data.todayStats.count}', AlhaiColors.info,
          Icons.receipt_long),
      _SummaryItem(
          l10n.averageSale,
          data.todayStats.count > 0
              ? (data.todayStats.total / data.todayStats.count)
                  .toStringAsFixed(0)
              : '0',
          AlhaiColors.primary,
          Icons.analytics),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: entry.key < items.length - 1 ? AlhaiSpacing.sm : 0,
            ),
            child: _buildSummaryCard(entry.value, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(_SummaryItem item, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
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
          Icon(item.icon, size: 20, color: item.color),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            item.value,
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
              fontSize: 11,
              color: isDark
                  ? Colors.white54
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(
      bool isDark, AppLocalizations l10n, WeeklyComparisonData data) {
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
            l10n.salesAnalytics,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            height: MediaQuery.of(context).size.width < 600 ? 150 : 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildChartBars(
                  isDark,
                  MediaQuery.of(context).size.width < 600 ? 150.0 : 200.0,
                  data.dailyBreakdown),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Row(
            children: data.dailyBreakdown
                .map((d) => Expanded(
                      child: Text(
                        d.dayName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars(
      bool isDark, double chartHeight, List<DaySalesData> days) {
    if (days.isEmpty) return [];
    final maxVal =
        days.map((d) => d.current).fold(0.0, (a, b) => a > b ? a : b);
    if (maxVal == 0) {
      return days
          .map((_) => Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AlhaiColors.primary.withValues(alpha: 0.3),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                    ),
                  ),
                ),
              ))
          .toList();
    }

    return days.asMap().entries.map((entry) {
      final ratio = entry.value.current / maxVal;
      final isToday = entry.key == days.length - 1;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
          child: Container(
            height: chartHeight * ratio.clamp(0.05, 1.0),
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: isToday ? 1.0 : 0.5),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildComparisonSection(
      bool isDark, AppLocalizations l10n, WeeklyComparisonData data) {
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
            l10n.thisWeek,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _ComparisonRow(
            label: l10n.totalSales,
            current: data.thisWeek.total.toStringAsFixed(0),
            previous: data.lastWeek.total.toStringAsFixed(0),
            isDark: isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _ComparisonRow(
            label: l10n.orders,
            current: '${data.thisWeek.count}',
            previous: '${data.lastWeek.count}',
            isDark: isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _ComparisonRow(
            label: l10n.customers,
            current: '${data.thisWeekCustomers}',
            previous: '${data.lastWeekCustomers}',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem(this.label, this.value, this.color, this.icon);
}

class _ComparisonRow extends StatelessWidget {
  final String label;
  final String current;
  final String previous;
  final bool isDark;

  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? Colors.white54
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Expanded(
          child: Text(
            current,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.sm),
        Expanded(
          child: Text(
            previous,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
          ),
        ),
      ],
    );
  }
}
