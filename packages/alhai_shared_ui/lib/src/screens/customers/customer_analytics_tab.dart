import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/theme/app_sizes.dart';

/// Analytics Tab - displays charts (bar/pie placeholders) and
/// analytics stat cards for a customer.
class CustomerAnalyticsTab extends StatelessWidget {
  final List<TransactionsTableData> invoiceTransactions;
  final double totalPurchases;
  final bool isMobile;
  final bool isDesktop;
  final bool isDark;

  const CustomerAnalyticsTab({
    super.key,
    required this.invoiceTransactions,
    required this.totalPurchases,
    required this.isMobile,
    required this.isDesktop,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Charts row
        if (isMobile)
          Column(
            children: [
              _buildChartPlaceholder(
                isDark,
                l10n.monthly,
                Icons.bar_chart_rounded,
                AppColors.primary,
                'Monthly Spending',
              ),
              const SizedBox(height: 12),
              _buildChartPlaceholder(
                isDark,
                l10n.categories,
                Icons.pie_chart_outline_rounded,
                const Color(0xFF8B5CF6),
                'Purchase Distribution',
              ),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildChartPlaceholder(
                  isDark,
                  l10n.monthly,
                  Icons.bar_chart_rounded,
                  AppColors.primary,
                  'Monthly Spending',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChartPlaceholder(
                  isDark,
                  l10n.categories,
                  Icons.pie_chart_outline_rounded,
                  const Color(0xFF8B5CF6),
                  'Purchase Distribution',
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        // Stats cards row
        _buildAnalyticsStatsGrid(isDark, l10n, isMobile),
      ],
    );
  }

  Widget _buildChartPlaceholder(
    bool isDark,
    String subtitle,
    IconData icon,
    Color color,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 24),
          // Placeholder chart bars
          SizedBox(
            height: 160,
            child: icon == Icons.bar_chart_rounded
                ? _buildBarChartPlaceholder(isDark, color)
                : _buildPieChartPlaceholder(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartPlaceholder(bool isDark, Color color) {
    final values = [0.4, 0.7, 0.55, 0.85, 0.65, 0.9];
    final months = ['Sep', 'Oct', 'Nov', 'Dec', 'Jan', 'Feb'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(values.length, (i) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration:
                      Duration(milliseconds: 400 + i * 100),
                  height: 120 * values[i],
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  months[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.getTextMuted(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPieChartPlaceholder(bool isDark) {
    final items = [
      {
        'label': 'Groceries',
        'pct': 45,
        'color': AppColors.primary
      },
      {'label': 'Dairy', 'pct': 25, 'color': AppColors.info},
      {'label': 'Meat', 'pct': 18, 'color': AppColors.warning},
      {
        'label': 'Other',
        'pct': 12,
        'color': const Color(0xFF8B5CF6)
      },
    ];
    return Row(
      children: [
        // Circle placeholder
        Expanded(
          child: Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: PieChartPainter(
                  items
                      .map((e) => PieSegment(
                            value:
                                (e['pct'] as int).toDouble(),
                            color: e['color'] as Color,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
        // Legend
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${item['label']} ${item['pct']}%',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          AppColors.getTextSecondary(isDark),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAnalyticsStatsGrid(
      bool isDark, AppLocalizations l10n, bool isMobile) {
    // Compute real analytics from transactions
    final invoiceCount = invoiceTransactions.length;
    final avgSale = invoiceCount > 0
        ? (totalPurchases / invoiceCount).toStringAsFixed(0)
        : '0';

    final stats = [
      {
        'icon': Icons.receipt_outlined,
        'label': l10n.averageSale,
        'value': '$avgSale ${l10n.sar}',
        'change': '$invoiceCount txns',
        'color': AppColors.primary,
        'isPositive': true,
      },
      {
        'icon': Icons.calendar_month_outlined,
        'label': l10n.monthly,
        'value': '${(invoiceCount / 3).toStringAsFixed(1)}x',
        'change': '',
        'color': AppColors.info,
        'isPositive': true,
      },
      {
        'icon': Icons.trending_up_rounded,
        'label': l10n.salesAnalytics,
        'value': '${totalPurchases.toStringAsFixed(0)} ${l10n.sar}',
        'change': 'total',
        'color': AppColors.success,
        'isPositive': true,
      },
      {
        'icon': Icons.favorite_outline_rounded,
        'label': l10n.topSelling,
        'value': '-',
        'change': '',
        'color': const Color(0xFF8B5CF6),
        'isPositive': true,
      },
    ];

    if (isMobile) {
      return Column(
        children: stats.map((s) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildAnalyticStatCard(s, isDark),
          );
        }).toList(),
      );
    }

    return Row(
      children: stats.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: entry.key < stats.length - 1 ? 12 : 0,
            ),
            child: _buildAnalyticStatCard(entry.value, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAnalyticStatCard(
      Map<String, dynamic> stat, bool isDark) {
    final color = stat['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.getBorder(isDark)),
        boxShadow: isDark ? null : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius:
                  BorderRadius.circular(AppSizes.radiusMd),
            ),
            alignment: Alignment.center,
            child: Icon(stat['icon'] as IconData,
                size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            stat['label'] as String,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.getTextMuted(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.getTextPrimary(isDark),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat['change'] as String,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: (stat['isPositive'] as bool)
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single segment in a pie chart.
class PieSegment {
  final double value;
  final Color color;
  const PieSegment({required this.value, required this.color});
}

/// Custom painter for a donut-style pie chart.
class PieChartPainter extends CustomPainter {
  final List<PieSegment> segments;

  PieChartPainter(this.segments);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.55;
    final total =
        segments.fold<double>(0, (s, e) => s + e.value);

    double startAngle = -math.pi / 2; // start from top

    for (final segment in segments) {
      final sweepAngle =
          (segment.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
            center: center,
            radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) =>
      false;
}
