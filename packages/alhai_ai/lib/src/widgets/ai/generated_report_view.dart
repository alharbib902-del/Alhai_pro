/// عرض التقرير المولد - Generated Report View Widget
///
/// عرض ديناميكي: جدول أو رسم بياني أو رقم حسب نوع التقرير
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_smart_reports_service.dart';

/// عرض التقرير المولد
class GeneratedReportView extends StatelessWidget {
  final GeneratedReport report;

  const GeneratedReportView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(isDark),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey100,
          ),
          // Summary
          _buildSummary(isDark),
          // Chart/Table/Number
          Expanded(child: _buildVisualization(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.xs),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getChartIcon(), color: Colors.white, size: 20),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.titleAr,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                Text(
                  'تم التوليد ${_formatTime(report.generatedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (report.totalValue != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_formatNumber(report.totalValue!)} ${report.unit ?? ''}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark) {
    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.md, AlhaiSpacing.zero, AlhaiSpacing.md, AlhaiSpacing.sm),
      padding: const EdgeInsets.all(AlhaiSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF8B5CF6).withValues(alpha: 0.08)
            : const Color(0xFF8B5CF6).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF8B5CF6)),
          const SizedBox(width: AlhaiSpacing.xs),
          Expanded(
            child: Text(
              report.summary,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualization(bool isDark) {
    switch (report.chartType) {
      case ChartType.barChart:
        return _BarChartView(data: report.data, isDark: isDark, unit: report.unit);
      case ChartType.lineChart:
        return _LineChartView(data: report.data, isDark: isDark, unit: report.unit);
      case ChartType.pieChart:
        return _PieChartView(data: report.data, isDark: isDark, unit: report.unit);
      case ChartType.table:
        return _TableView(data: report.data, isDark: isDark, unit: report.unit);
      case ChartType.number:
        return _NumberView(data: report.data, isDark: isDark, unit: report.unit);
      case ChartType.heatmap:
        return _BarChartView(data: report.data, isDark: isDark, unit: report.unit);
    }
  }

  IconData _getChartIcon() {
    switch (report.chartType) {
      case ChartType.barChart: return Icons.bar_chart_rounded;
      case ChartType.lineChart: return Icons.show_chart_rounded;
      case ChartType.pieChart: return Icons.pie_chart_rounded;
      case ChartType.table: return Icons.table_chart_rounded;
      case ChartType.number: return Icons.pin_rounded;
      case ChartType.heatmap: return Icons.grid_on_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}

/// رسم بياني أعمدة
class _BarChartView extends StatelessWidget {
  final List<ReportDataRow> data;
  final bool isDark;
  final String? unit;

  const _BarChartView({required this.data, required this.isDark, this.unit});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final maxValue = data.map((d) => d.value).reduce(max);

    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((entry) {
                final ratio = maxValue > 0 ? entry.value.value / maxValue : 0.0;
                final colors = _getBarGradient(entry.key);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          entry.value.value.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: colors,
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: data.map((d) {
                return SizedBox(
                  width: 50,
                  child: Text(
                    d.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getBarGradient(int index) {
    final gradients = [
      [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      [const Color(0xFF6366F1), const Color(0xFF818CF8)],
      [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
      [const Color(0xFF10B981), const Color(0xFF34D399)],
    ];
    return gradients[index % gradients.length];
  }
}

/// رسم بياني خطي
class _LineChartView extends StatelessWidget {
  final List<ReportDataRow> data;
  final bool isDark;
  final String? unit;

  const _LineChartView({required this.data, required this.isDark, this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: CustomPaint(
        size: Size.infinite,
        painter: _LineChartPainter(data: data, isDark: isDark),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ReportDataRow> data;
  final bool isDark;

  _LineChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.map((d) => d.value).reduce(max);
    final minVal = data.map((d) => d.value).reduce(min);
    final range = maxVal - minVal;
    final stepX = size.width / (data.length - 1);

    // Grid
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Area fill
    final areaPath = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = range > 0
          ? size.height - ((data[i].value - minVal) / range * size.height * 0.85 + size.height * 0.05)
          : size.height / 2;
      if (i == 0) {
        areaPath.moveTo(x, y);
      } else {
        areaPath.lineTo(x, y);
      }
    }
    final areaFillPath = Path.from(areaPath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final areaGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF8B5CF6).withValues(alpha: 0.25),
        const Color(0xFF8B5CF6).withValues(alpha: 0.02),
      ],
    );
    canvas.drawPath(
      areaFillPath,
      Paint()..shader = areaGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(areaPath, linePaint);

    // Previous value line (if exists)
    if (data.any((d) => d.previousValue != null)) {
      final prevPath = Path();
      for (int i = 0; i < data.length; i++) {
        final x = i * stepX;
        final pv = data[i].previousValue ?? data[i].value;
        final y = range > 0
            ? size.height - ((pv - minVal) / range * size.height * 0.85 + size.height * 0.05)
            : size.height / 2;
        if (i == 0) {
          prevPath.moveTo(x, y);
        } else {
          prevPath.lineTo(x, y);
        }
      }
      canvas.drawPath(prevPath, Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.grey300
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round);
    }

    // Dots
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = range > 0
          ? size.height - ((data[i].value - minVal) / range * size.height * 0.85 + size.height * 0.05)
          : size.height / 2;
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = const Color(0xFF8B5CF6));
      canvas.drawCircle(Offset(x, y), 2, Paint()..color = Colors.white);
    }

    // Labels
    for (int i = 0; i < data.length; i++) {
      if (i % max(1, data.length ~/ 6) != 0 && i != data.length - 1) continue;
      final x = i * stepX;
      final tp = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height + 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// رسم بياني دائري
class _PieChartView extends StatelessWidget {
  final List<ReportDataRow> data;
  final bool isDark;
  final String? unit;

  const _PieChartView({required this.data, required this.isDark, this.unit});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    final colors = [
      const Color(0xFF8B5CF6), const Color(0xFF3B82F6), const Color(0xFF10B981),
      const Color(0xFFF97316), const Color(0xFFEF4444), const Color(0xFF14B8A6),
      const Color(0xFFF59E0B), const Color(0xFF6366F1),
    ];

    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              size: const Size(200, 200),
              painter: _PieChartPainter(
                data: data,
                total: total,
                colors: colors,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.asMap().entries.map((entry) {
                final percent = total > 0 ? (entry.value.value / total * 100) : 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[entry.key % colors.length],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: AlhaiSpacing.xs),
                      Expanded(
                        child: Text(
                          entry.value.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<ReportDataRow> data;
  final double total;
  final List<Color> colors;
  final bool isDark;

  _PieChartPainter({required this.data, required this.total, required this.colors, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 10;
    double startAngle = -pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweep = total > 0 ? (data[i].value / total * 2 * pi) : 0.0;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()..color = colors[i % colors.length],
      );
      // Gap between slices
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        true,
        Paint()
          ..color = isDark ? const Color(0xFF1E293B) : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      startAngle += sweep;
    }

    // Center hole (donut)
    canvas.drawCircle(center, radius * 0.55,
      Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white);

    // Center text
    final tp = TextPainter(
      text: TextSpan(
        text: total.toStringAsFixed(0),
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// عرض جدولي
class _TableView extends StatelessWidget {
  final List<ReportDataRow> data;
  final bool isDark;
  final String? unit;

  const _TableView({required this.data, required this.isDark, this.unit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      child: ListView.separated(
        itemCount: data.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey100,
        ),
        itemBuilder: (context, index) {
          final row = data[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Text(
                    row.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '${row.value.toStringAsFixed(1)} ${unit ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                if (row.previousValue != null) ...[
                  const SizedBox(width: AlhaiSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AlhaiSpacing.xxxs),
                    decoration: BoxDecoration(
                      color: row.changePercent >= 0
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${row.changePercent >= 0 ? '+' : ''}${row.changePercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: row.changePercent >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// عرض رقم واحد كبير
class _NumberView extends StatelessWidget {
  final List<ReportDataRow> data;
  final bool isDark;
  final String? unit;

  const _NumberView({required this.data, required this.isDark, this.unit});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final row = data.first;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            row.label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
            ).createShader(bounds),
            child: Text(
              '${_formatLargeNumber(row.value)} ${unit ?? ''}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
          if (row.previousValue != null) ...[
            const SizedBox(height: AlhaiSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: row.changePercent >= 0
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    row.changePercent >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    size: 16,
                    color: row.changePercent >= 0 ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${row.changePercent >= 0 ? '+' : ''}${row.changePercent.toStringAsFixed(1)}% عن الشهر السابق',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: row.changePercent >= 0 ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatLargeNumber(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(2)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }
}
