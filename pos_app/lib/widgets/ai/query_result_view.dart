/// عرض نتيجة الاستعلام
///
/// يعرض النتائج بناءً على نوعها: رقم، جدول، أو رسم بياني
/// باستخدام CustomPaint للرسوم البيانية
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_chat_with_data_service.dart';

/// عرض نتيجة الاستعلام
class QueryResultView extends StatelessWidget {
  final QueryResult result;

  const QueryResultView({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + وقت التنفيذ
          Row(
            children: [
              Icon(
                _getResultIcon(),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${result.executionTimeMs}ms',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // الاستعلام الأصلي
          Text(
            '> ${result.query.query}',
            style: TextStyle(
              color: isDark ? Colors.white38 : AppColors.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),

          const SizedBox(height: 16),

          // المحتوى حسب النوع
          _buildContent(isDark, textColor, subtextColor),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark, Color textColor, Color subtextColor) {
    switch (result.resultType) {
      case QueryResultType.number:
        return _buildNumberView(isDark, textColor, subtextColor);
      case QueryResultType.table:
        return _buildTableView(isDark, textColor, subtextColor);
      case QueryResultType.barChart:
        return _buildBarChartView(isDark);
      case QueryResultType.lineChart:
        return _buildLineChartView(isDark);
      case QueryResultType.pieChart:
        return _buildPieChartView(isDark, textColor, subtextColor);
    }
  }

  // ============================================================================
  // NUMBER VIEW
  // ============================================================================

  Widget _buildNumberView(bool isDark, Color textColor, Color subtextColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              result.singleValue ?? '0',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (result.singleUnit != null && result.singleUnit!.isNotEmpty)
              Text(
                result.singleUnit!,
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // TABLE VIEW
  // ============================================================================

  Widget _buildTableView(bool isDark, Color textColor, Color subtextColor) {
    if (result.tableHeaders == null || result.tableRows == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          isDark
              ? Colors.white.withValues(alpha: 0.04)
              : AppColors.grey50,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        border: TableBorder(
          horizontalInside: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.grey200,
            width: 0.5,
          ),
        ),
        columns: result.tableHeaders!
            .map((h) => DataColumn(
                  label: Text(
                    h,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ))
            .toList(),
        rows: result.tableRows!
            .map((row) => DataRow(
                  cells: row
                      .map((cell) => DataCell(
                            Text(
                              cell,
                              style: TextStyle(
                                color: subtextColor,
                                fontSize: 13,
                              ),
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }

  // ============================================================================
  // BAR CHART VIEW
  // ============================================================================

  Widget _buildBarChartView(bool isDark) {
    if (result.chartData == null || result.chartData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 220,
      child: CustomPaint(
        size: const Size(double.infinity, 220),
        painter: _BarChartPainter(
          data: result.chartData!,
          isDark: isDark,
        ),
      ),
    );
  }

  // ============================================================================
  // LINE CHART VIEW
  // ============================================================================

  Widget _buildLineChartView(bool isDark) {
    if (result.chartData == null || result.chartData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _LineChartPainter(
          data: result.chartData!,
          isDark: isDark,
        ),
      ),
    );
  }

  // ============================================================================
  // PIE CHART VIEW
  // ============================================================================

  Widget _buildPieChartView(bool isDark, Color textColor, Color subtextColor) {
    if (result.chartData == null || result.chartData!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _PieChartPainter(
              data: result.chartData!,
              isDark: isDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: result.chartData!.map((d) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: d.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${d.label}: ${d.value.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getResultIcon() {
    switch (result.resultType) {
      case QueryResultType.number:
        return Icons.pin;
      case QueryResultType.table:
        return Icons.table_chart;
      case QueryResultType.barChart:
        return Icons.bar_chart;
      case QueryResultType.lineChart:
        return Icons.show_chart;
      case QueryResultType.pieChart:
        return Icons.pie_chart;
    }
  }
}

// ============================================================================
// BAR CHART PAINTER
// ============================================================================

class _BarChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final bool isDark;

  _BarChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const paddingBottom = 35.0;
    const paddingTop = 10.0;
    const paddingLeft = 45.0;
    final chartWidth = size.width - paddingLeft - 10;
    final chartHeight = size.height - paddingBottom - paddingTop;

    final maxValue = data.map((d) => d.value).reduce(math.max);
    final barWidth = (chartWidth / data.length) * 0.6;
    final gap = (chartWidth / data.length) * 0.4;

    // خطوط الشبكة
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
      fontSize: 9,
    );

    for (int i = 0; i <= 4; i++) {
      final y = paddingTop + (chartHeight * i / 4);
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - 10, y), gridPaint);

      final val = maxValue - (maxValue * i / 4);
      final tp = TextPainter(
        text: TextSpan(
          text: val >= 1000 ? '${(val / 1000).toStringAsFixed(0)}K' : val.toStringAsFixed(0),
          style: labelStyle,
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // الأعمدة
    for (int i = 0; i < data.length; i++) {
      final x = paddingLeft + i * (barWidth + gap) + gap / 2;
      final barHeight = (data[i].value / maxValue) * chartHeight;
      final y = paddingTop + chartHeight - barHeight;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            data[i].color,
            data[i].color.withValues(alpha: 0.7),
          ],
        ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(rect, barPaint);

      // التسمية
      final tp = TextPainter(
        text: TextSpan(text: data[i].label, style: labelStyle),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(x + barWidth / 2 - tp.width / 2, size.height - paddingBottom + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// LINE CHART PAINTER
// ============================================================================

class _LineChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final bool isDark;

  _LineChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    const paddingBottom = 30.0;
    const paddingTop = 10.0;
    final chartHeight = size.height - paddingBottom - paddingTop;

    final maxValue = data.map((d) => d.value).reduce(math.max);
    final minValue = data.map((d) => d.value).reduce(math.min);
    final range = (maxValue - minValue).clamp(1.0, double.infinity);
    final stepX = size.width / (data.length - 1).clamp(1, data.length);

    // خطوط الشبكة
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = paddingTop + (chartHeight * i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // حساب النقاط
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = (data[i].value - minValue) / range;
      final y = paddingTop + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));
    }

    // المنطقة المظللة
    if (points.length >= 2) {
      final areaPath = Path()..moveTo(points.first.dx, paddingTop + chartHeight);
      for (final p in points) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath.lineTo(points.last.dx, paddingTop + chartHeight);
      areaPath.close();

      final color = data.first.color;
      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, areaPaint);
    }

    // الخط
    final color = data.first.color;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // النقاط + التسميات
    final labelStyle = TextStyle(
      color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
      fontSize: 9,
    );

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
        points[i],
        5,
        Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white,
      );
      canvas.drawCircle(points[i], 3.5, Paint()..color = color);

      final tp = TextPainter(
        text: TextSpan(text: data[i].label, style: labelStyle),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
        canvas,
        Offset(points[i].dx - tp.width / 2, size.height - paddingBottom + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ============================================================================
// PIE CHART PAINTER
// ============================================================================

class _PieChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final bool isDark;

  _PieChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final total = data.fold<double>(0, (sum, d) => sum + d.value);

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final sweepAngle = (data[i].value / total) * 2 * math.pi;

      final paint = Paint()
        ..color = data[i].color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // خط فاصل
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = isDark ? const Color(0xFF1E293B) : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // تسمية النسبة
      final midAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.65;
      final labelX = center.dx + labelRadius * math.cos(midAngle);
      final labelY = center.dy + labelRadius * math.sin(midAngle);

      if (data[i].value / total > 0.08) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${data[i].value.toStringAsFixed(0)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout();
        tp.paint(canvas, Offset(labelX - tp.width / 2, labelY - tp.height / 2));
      }

      startAngle += sweepAngle;
    }

    // الدائرة الداخلية (Donut)
    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
