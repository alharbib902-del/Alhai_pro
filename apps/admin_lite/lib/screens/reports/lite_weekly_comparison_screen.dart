/// Lite Weekly Comparison Screen
///
/// Compares current week vs previous week metrics:
/// sales, orders, customers, and average ticket.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Weekly comparison report for Admin Lite
class LiteWeeklyComparisonScreen extends StatelessWidget {
  const LiteWeeklyComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weekly),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? AlhaiSpacing.md : AlhaiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week selector
            _buildWeekSelector(context, isDark),
            const SizedBox(height: AlhaiSpacing.lg),

            // Comparison cards
            _buildComparisonCards(context, isDark, isMobile, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Day-by-day breakdown
            _buildDayBreakdown(context, isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Category performance
            _buildCategoryPerformance(context, isDark, l10n),

            const SizedBox(height: AlhaiSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.chevron_left, color: isDark ? Colors.white54 : Colors.black54),
          const Spacer(),
          Text(
            'Mar 24 - Mar 30, 2026',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black54),
        ],
      ),
    );
  }

  Widget _buildComparisonCards(BuildContext context, bool isDark, bool isMobile, AppLocalizations l10n) {
    final items = [
      _ComparisonItem(l10n.totalSales, '87,200', '80,150', 8.8, Icons.trending_up),
      _ComparisonItem(l10n.orders, '1,240', '1,105', 12.2, Icons.receipt),
      _ComparisonItem(l10n.customers, '342', '310', 10.3, Icons.people),
      _ComparisonItem(l10n.averageSale, '70.3', '72.5', -3.0, Icons.analytics),
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

  Widget _buildComparisonCard(BuildContext context, _ComparisonItem item, bool isDark) {
    final isPositive = item.changePercent >= 0;
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
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
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildDayBreakdown(BuildContext context, bool isDark, AppLocalizations l10n) {
    final days = [
      _DayData('Sat', 11200, 10800),
      _DayData('Sun', 14500, 12100),
      _DayData('Mon', 10800, 11500),
      _DayData('Tue', 13200, 10900),
      _DayData('Wed', 12400, 12800),
      _DayData('Thu', 15100, 13050),
      _DayData('Fri', 10000, 9000),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
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
          // Legend
          Row(
            children: [
              _LegendDot(color: AlhaiColors.primary, label: l10n.thisWeek),
              const SizedBox(width: AlhaiSpacing.md),
              _LegendDot(color: Colors.grey, label: l10n.yesterday),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...days.map((day) {
            final maxVal = 16000.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      day.name,
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
                        _BarRow(value: day.current / maxVal, color: AlhaiColors.primary),
                        const SizedBox(height: AlhaiSpacing.xxxs),
                        _BarRow(value: day.previous / maxVal, color: Colors.grey.shade400),
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

  Widget _buildCategoryPerformance(BuildContext context, bool isDark, AppLocalizations l10n) {
    final categories = [
      _CategoryPerf(l10n.products, '32,400', 12.5),
      _CategoryPerf(l10n.categories, '18,600', 5.2),
      _CategoryPerf(l10n.inventory, '15,200', -2.1),
      _CategoryPerf(l10n.customers, '12,000', 8.7),
      _CategoryPerf(l10n.expenses, '9,000', -4.3),
    ];

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categories,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...categories.map((cat) {
            final isPositive = cat.change >= 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    cat.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  SizedBox(
                    width: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 12,
                          color: isPositive ? AlhaiColors.success : AlhaiColors.error,
                        ),
                        Text(
                          '${cat.change.abs().toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? AlhaiColors.success : AlhaiColors.error,
                          ),
                        ),
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
  final String previous;
  final double changePercent;
  final IconData icon;
  const _ComparisonItem(this.label, this.current, this.previous, this.changePercent, this.icon);
}

class _DayData {
  final String name;
  final double current;
  final double previous;
  const _DayData(this.name, this.current, this.previous);
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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

class _CategoryPerf {
  final String name;
  final String value;
  final double change;
  const _CategoryPerf(this.name, this.value, this.change);
}
