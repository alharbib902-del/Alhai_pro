/// Distributor Reports Screen
///
/// Shows summary statistics, charts, and date filtering.
/// Wired to real Supabase data via reportDataProvider.
/// Uses fl_chart for bar chart visualization.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../data/models.dart';
import '../../providers/distributor_providers.dart';

// ─── Period mapping ─────────────────────────────────────────────

/// Arabic display label -> API period key used by reportDataProvider.
const _periodMap = <String, String>{
  'يوم': 'day',
  'أسبوع': 'week',
  'شهر': 'month',
  'سنة': 'year',
};

// ─── Screen ──────────────────────────────────────────────────────

/// شاشة التقارير للموزع
class DistributorReportsScreen extends ConsumerStatefulWidget {
  const DistributorReportsScreen({super.key});

  @override
  ConsumerState<DistributorReportsScreen> createState() =>
      _DistributorReportsScreenState();
}

class _DistributorReportsScreenState
    extends ConsumerState<DistributorReportsScreen> {
  String _selectedPeriod = 'أسبوع';
  final _periods = ['يوم', 'أسبوع', 'شهر', 'سنة'];

  String get _apiPeriod => _periodMap[_selectedPeriod] ?? 'week';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final reportAsync = ref.watch(reportDataProvider(_apiPeriod));

    return Scaffold(
      backgroundColor: AppColors.getBackground(isDark),
      appBar: AppBar(
        title: Text(
          'التقارير',
          style: TextStyle(fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تصدير التقرير - قريباً'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded),
            tooltip: 'تصدير',
          ),
          const SizedBox(width: AlhaiSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // ── Period Filter (always visible) ──
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md,
              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md,
              isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md,
              0,
            ),
            child: _buildPeriodFilter(isDark),
          ),

          // ── Content ──
          Expanded(
            child: reportAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.getTextMuted(isDark)),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(
                      'حدث خطأ في تحميل التقارير',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.getTextSecondary(isDark),
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.invalidate(reportDataProvider(_apiPeriod)),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('إعادة المحاولة'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              data: (report) => RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(reportDataProvider(_apiPeriod)),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(
                      isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Summary Cards ──
                      _buildSummaryCards(report, isDark, isWide, isMedium, size),
                      SizedBox(
                          height: isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),

                      // ── Chart + Top Products ──
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 3,
                                child: _buildChart(
                                    isDark, isMedium, report.dailySales)),
                            const SizedBox(width: AlhaiSpacing.lg),
                            Expanded(
                                flex: 2,
                                child: _buildTopProducts(
                                    isDark, report.topProducts)),
                          ],
                        )
                      else ...[
                        _buildChart(isDark, isMedium, report.dailySales),
                        const SizedBox(height: AlhaiSpacing.md),
                        _buildTopProducts(isDark, report.topProducts),
                      ],
                      const SizedBox(height: AlhaiSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Summary Cards ────────────────────────────────────────────

  Widget _buildSummaryCards(ReportData report, bool isDark, bool isWide,
      bool isMedium, Size size) {
    final fmt = NumberFormat('#,##0', 'ar');
    final fmtDec = NumberFormat('#,##0.00', 'ar');

    final cards = [
      _statCard(
        Icons.payments_rounded,
        'إجمالي المبيعات',
        '${fmt.format(report.totalSales)} ر.س',
        '', // No comparison data yet
        AppColors.primary,
        isDark,
      ),
      _statCard(
        Icons.receipt_long_rounded,
        'عدد الطلبات',
        '${report.orderCount}',
        '',
        AppColors.info,
        isDark,
      ),
      _statCard(
        Icons.trending_up_rounded,
        'متوسط قيمة الطلب',
        '${fmtDec.format(report.avgOrderValue)} ر.س',
        '',
        AppColors.secondary,
        isDark,
      ),
      _statCard(
        Icons.star_rounded,
        'أفضل منتج',
        report.topProduct,
        '${report.topProductOrders} طلب',
        AppColors.warning,
        isDark,
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AlhaiSpacing.md),
            Expanded(child: cards[i]),
          ],
        ],
      );
    }

    return Wrap(
      spacing: AlhaiSpacing.sm,
      runSpacing: AlhaiSpacing.sm,
      children: [
        for (final card in cards)
          SizedBox(
            width: isMedium ? (size.width - 60) / 2 : double.infinity,
            child: card,
          ),
      ],
    );
  }

  // ─── Period Filter ─────────────────────────────────────────────

  Widget _buildPeriodFilter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = period == _selectedPeriod;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : AppColors.getTextSecondary(isDark),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Stat Card ─────────────────────────────────────────────────

  Widget _statCard(IconData icon, String label, String value, String change,
      Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (change.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    change,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Chart ─────────────────────────────────────────────────────

  Widget _buildChart(bool isDark, bool isMedium, List<DailySales> dailySales) {
    if (dailySales.isEmpty) {
      return Container(
        height: 280,
        padding: EdgeInsets.all(isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Center(
          child: Text(
            'لا توجد بيانات للفترة المحددة',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
        ),
      );
    }

    final maxValue = dailySales
        .map((s) => s.amount)
        .reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 100.0;

    return Container(
      padding: EdgeInsets.all(isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'المبيعات اليومية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: chartMaxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${NumberFormat('#,##0').format(rod.toY)} ر.س',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dailySales.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                          child: Text(
                            dailySales[idx].day,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.getTextSecondary(isDark),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval:
                      maxValue > 0 ? maxValue / 4 : 25,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.getBorder(isDark),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(dailySales.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: dailySales[index].amount,
                        color: AppColors.primary,
                        width: isMedium ? 20 : 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMaxY,
                          color: AppColors.primary.withValues(alpha: 0.04),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Products ──────────────────────────────────────────────

  Widget _buildTopProducts(bool isDark, List<TopProduct> topProducts) {
    if (topProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AlhaiSpacing.mdl),
        decoration: BoxDecoration(
          color: AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.getBorder(isDark)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Text(
                  'أفضل المنتجات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.getTextPrimary(isDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            Text(
              'لا توجد بيانات',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.getTextMuted(isDark),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: AppColors.warning, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                'أفضل المنتجات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.md),
          ...List.generate(topProducts.length, (index) {
            final product = topProducts[index];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: index < topProducts.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: AppColors.getBorder(isDark)
                              .withValues(alpha: 0.5),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: index < 3
                          ? [
                              AppColors.warning,
                              AppColors.grey400,
                              AppColors.secondary
                            ][index]
                              .withValues(alpha: 0.12)
                          : AppColors.getSurfaceVariant(isDark),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: index < 3
                            ? [
                                AppColors.warning,
                                AppColors.grey500,
                                AppColors.secondary
                              ][index]
                            : AppColors.getTextMuted(isDark),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          '${product.orderCount} طلب',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,##0').format(product.revenue)} ر.س',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
