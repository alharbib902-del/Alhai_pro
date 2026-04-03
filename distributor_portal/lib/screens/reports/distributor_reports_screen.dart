/// Distributor Reports Screen
///
/// Shows summary statistics, charts, and date filtering.
/// Uses fl_chart for bar chart visualization.
/// Supports: RTL Arabic, dark/light theme, responsive layout.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart' show NumberFormat;

// ─── Mock Data ───────────────────────────────────────────────────

class _MockMonthlySales {
  final String month;
  final double amount;
  const _MockMonthlySales(this.month, this.amount);
}

const _monthlySales = [
  _MockMonthlySales('سبت', 12500),
  _MockMonthlySales('أحد', 18200),
  _MockMonthlySales('اثن', 15600),
  _MockMonthlySales('ثلا', 22100),
  _MockMonthlySales('أربع', 19800),
  _MockMonthlySales('خمي', 24500),
  _MockMonthlySales('جمع', 8900),
];

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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final isMedium = size.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Period Filter ──
              _buildPeriodFilter(isDark),
              SizedBox(height: isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),

              // ── Summary Cards ──
              if (isWide)
                Row(
                  children: [
                    Expanded(
                        child: _statCard(
                      Icons.payments_rounded,
                      'إجمالي المبيعات',
                      '١٢١,٦٠٠ ر.س',
                      '+١٢.٥%',
                      AppColors.primary,
                      isDark,
                    )),
                    const SizedBox(width: AlhaiSpacing.md),
                    Expanded(
                        child: _statCard(
                      Icons.receipt_long_rounded,
                      'عدد الطلبات',
                      '٤٨',
                      '+٨',
                      AppColors.info,
                      isDark,
                    )),
                    const SizedBox(width: AlhaiSpacing.md),
                    Expanded(
                        child: _statCard(
                      Icons.trending_up_rounded,
                      'متوسط قيمة الطلب',
                      '٢,٥٣٣ ر.س',
                      '+٣.٢%',
                      AppColors.secondary,
                      isDark,
                    )),
                    const SizedBox(width: AlhaiSpacing.md),
                    Expanded(
                        child: _statCard(
                      Icons.star_rounded,
                      'أفضل منتج',
                      'أرز بسمتي',
                      '٥٠ طلب',
                      AppColors.warning,
                      isDark,
                    )),
                  ],
                )
              else
                Wrap(
                  spacing: AlhaiSpacing.sm,
                  runSpacing: AlhaiSpacing.sm,
                  children: [
                    SizedBox(
                      width: isMedium
                          ? (size.width - 60) / 2
                          : double.infinity,
                      child: _statCard(
                        Icons.payments_rounded,
                        'إجمالي المبيعات',
                        '١٢١,٦٠٠ ر.س',
                        '+١٢.٥%',
                        AppColors.primary,
                        isDark,
                      ),
                    ),
                    SizedBox(
                      width: isMedium
                          ? (size.width - 60) / 2
                          : double.infinity,
                      child: _statCard(
                        Icons.receipt_long_rounded,
                        'عدد الطلبات',
                        '٤٨',
                        '+٨',
                        AppColors.info,
                        isDark,
                      ),
                    ),
                    SizedBox(
                      width: isMedium
                          ? (size.width - 60) / 2
                          : double.infinity,
                      child: _statCard(
                        Icons.trending_up_rounded,
                        'متوسط قيمة الطلب',
                        '٢,٥٣٣ ر.س',
                        '+٣.٢%',
                        AppColors.secondary,
                        isDark,
                      ),
                    ),
                    SizedBox(
                      width: isMedium
                          ? (size.width - 60) / 2
                          : double.infinity,
                      child: _statCard(
                        Icons.star_rounded,
                        'أفضل منتج',
                        'أرز بسمتي',
                        '٥٠ طلب',
                        AppColors.warning,
                        isDark,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: isMedium ? AlhaiSpacing.lg : AlhaiSpacing.md),

              // ── Chart ──
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildChart(isDark, isMedium)),
                    const SizedBox(width: AlhaiSpacing.lg),
                    Expanded(flex: 2, child: _buildTopProducts(isDark)),
                  ],
                )
              else ...[
                _buildChart(isDark, isMedium),
                const SizedBox(height: AlhaiSpacing.md),
                _buildTopProducts(isDark),
              ],
              const SizedBox(height: AlhaiSpacing.xl),
            ],
          ),
        ),
    );
  }

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

  Widget _buildChart(bool isDark, bool isMedium) {
    final maxValue = _monthlySales
        .map((s) => s.amount)
        .reduce((a, b) => a > b ? a : b);

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
                maxY: maxValue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${NumberFormat('#,##0').format(rod.toY)} ر.س',
                        TextStyle(
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
                        if (idx < 0 || idx >= _monthlySales.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AlhaiSpacing.xs),
                          child: Text(
                            _monthlySales[idx].month,
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
                  horizontalInterval: maxValue / 4,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.getBorder(isDark),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_monthlySales.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: _monthlySales[index].amount,
                        color: AppColors.primary,
                        width: isMedium ? 20 : 14,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxValue * 1.2,
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

  Widget _buildTopProducts(bool isDark) {
    final topProducts = [
      ('أرز بسمتي ١٠ كيلو', 50, 47500.0),
      ('زيت زيتون بكر ١ لتر', 35, 49000.0),
      ('قهوة عربية ٥٠٠ جرام', 28, 12600.0),
      ('سكر أبيض ٥ كيلو', 25, 4500.0),
      ('حليب بودرة ٢.٥ كيلو', 20, 11000.0),
    ];

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
            final (name, orders, revenue) = topProducts[index];
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
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextPrimary(isDark),
                          ),
                        ),
                        Text(
                          '$orders طلب',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.getTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${NumberFormat('#,##0').format(revenue)} ر.س',
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
