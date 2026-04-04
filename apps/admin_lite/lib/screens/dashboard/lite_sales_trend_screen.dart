/// Sales Trend Mini Chart Screen
///
/// Displays sales trends with a simple line chart visualization,
/// period selector (day/week/month), and comparison indicators.
/// Supports RTL, dark mode, and responsive layouts.
library;

import 'package:flutter/material.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// Sales Trend Screen - mini chart with period comparison
class LiteSalesTrendScreen extends StatefulWidget {
  const LiteSalesTrendScreen({super.key});

  @override
  State<LiteSalesTrendScreen> createState() => _LiteSalesTrendScreenState();
}

class _LiteSalesTrendScreenState extends State<LiteSalesTrendScreen> {
  int _selectedPeriod = 0; // 0=day, 1=week, 2=month

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.salesAnalytics),
        centerTitle: true,
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
            _buildSummaryCards(isDark, isMobile, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Chart area
            _buildChartCard(isDark, l10n),
            const SizedBox(height: AlhaiSpacing.lg),

            // Comparison section
            _buildComparisonSection(isDark, l10n),
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
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100,
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
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
                      : null,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildSummaryCards(bool isDark, bool isMobile, AppLocalizations l10n) {
    final items = [
      _SummaryItem(l10n.totalSales, '12,450', AlhaiColors.success, Icons.trending_up, '+8.2%'),
      _SummaryItem(l10n.orders, '186', AlhaiColors.info, Icons.receipt_long, '+12'),
      _SummaryItem(l10n.averageSale, '67', AlhaiColors.primary, Icons.analytics, '-2.1%'),
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
          color: isDark ? Colors.white12 : Theme.of(context).colorScheme.outlineVariant,
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
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            item.change,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: item.change.startsWith('+') ? AlhaiColors.success : AlhaiColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(bool isDark, AppLocalizations l10n) {
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
            l10n.salesAnalytics,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          // Placeholder chart using simple bars
          SizedBox(
            height: MediaQuery.of(context).size.width < 600 ? 150 : 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildChartBars(isDark, MediaQuery.of(context).size.width < 600 ? 150.0 : 200.0),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // X-axis labels
          Row(
            children: ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']
                .map((d) => Expanded(
                      child: Text(
                        d,
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

  List<Widget> _buildChartBars(bool isDark, double chartHeight) {
    final values = [0.6, 0.8, 0.5, 0.9, 0.7, 1.0, 0.65];
    return values.asMap().entries.map((entry) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xxxs),
          child: Container(
            height: chartHeight * entry.value,
            decoration: BoxDecoration(
              color: AlhaiColors.primary.withValues(alpha: entry.key == 5 ? 1.0 : 0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildComparisonSection(bool isDark, AppLocalizations l10n) {
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
            current: '87,200',
            previous: '80,150',
            isDark: isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _ComparisonRow(
            label: l10n.orders,
            current: '1,240',
            previous: '1,105',
            isDark: isDark,
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          _ComparisonRow(
            label: l10n.customers,
            current: '342',
            previous: '310',
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
  final String change;

  const _SummaryItem(this.label, this.value, this.color, this.icon, this.change);
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
              color: isDark ? Colors.white54 : Theme.of(context).colorScheme.onSurfaceVariant,
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
