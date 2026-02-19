/// رسم بياني لتوقع العائد على الاستثمار
///
/// يعرض خط ROI التراكمي مع خط التعادل
/// باستخدام CustomPaint
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/ai_promotion_designer_service.dart';

/// رسم بياني لتوقع العائد
class RoiForecastChart extends StatelessWidget {
  final List<RoiForecast> forecasts;
  final String title;

  const RoiForecastChart({
    super.key,
    required this.forecasts,
    this.title = 'توقع العائد على الاستثمار',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    if (forecasts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.border,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.show_chart, color: subtextColor, size: 40),
              const SizedBox(height: 8),
              Text(
                'اختر عرضاً لعرض توقعات ROI',
                style: TextStyle(color: subtextColor, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final maxRoi = forecasts.map((f) => f.cumulativeRoi).reduce(math.max);
    final lastForecast = forecasts.last;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              const Icon(Icons.trending_up, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ROI: ${maxRoi.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ملخص
          Row(
            children: [
              _buildMiniStat(
                l10n.revenue,
                '${(lastForecast.projectedRevenue / 1000).toStringAsFixed(1)}K ر.س',
                AppColors.primary,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                l10n.cost,
                '${(lastForecast.projectedCost / 1000).toStringAsFixed(1)}K ر.س',
                AppColors.error,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                l10n.duration,
                '${forecasts.length} ${l10n.day}',
                AppColors.info,
                isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // الرسم البياني
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _RoiChartPainter(
                forecasts: forecasts,
                isDark: isDark,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('ROI التراكمي', AppColors.primary, isDark),
              const SizedBox(width: 20),
              _buildLegendItem('خط التعادل', AppColors.warning, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textMuted,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// CHART PAINTER
// ============================================================================

class _RoiChartPainter extends CustomPainter {
  final List<RoiForecast> forecasts;
  final bool isDark;

  _RoiChartPainter({required this.forecasts, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (forecasts.isEmpty) return;

    const paddingTop = 10.0;
    const paddingBottom = 25.0;
    const paddingLeft = 40.0;
    final chartWidth = size.width - paddingLeft;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final maxRoi = forecasts.map((f) => f.cumulativeRoi).reduce(math.max);
    final minRoi = forecasts.map((f) => f.cumulativeRoi).reduce(math.min);
    final roiRange = (maxRoi - minRoi).clamp(10.0, double.infinity);

    final stepX = chartWidth / (forecasts.length - 1).clamp(1, forecasts.length);

    // خطوط الشبكة الأفقية
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: isDark ? Colors.white38 : AppColors.textMuted,
      fontSize: 10,
    );

    for (int i = 0; i <= 4; i++) {
      final y = paddingTop + (chartHeight * i / 4);
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width, y),
        gridPaint,
      );

      final roiValue = maxRoi - (roiRange * i / 4);
      final tp = TextPainter(
        text: TextSpan(text: '${roiValue.toStringAsFixed(0)}%', style: labelStyle),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // خط التعادل (ROI = 0)
    if (minRoi <= 0 && maxRoi >= 0) {
      final zeroY = paddingTop + chartHeight - ((0 - minRoi) / roiRange * chartHeight);
      final breakEvenPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final dashPath = Path();
      for (double x = paddingLeft; x < size.width; x += 8) {
        dashPath.moveTo(x, zeroY);
        dashPath.lineTo(x + 4, zeroY);
      }
      canvas.drawPath(dashPath, breakEvenPaint);
    }

    // حساب النقاط
    final points = <Offset>[];
    for (int i = 0; i < forecasts.length; i++) {
      final x = paddingLeft + i * stepX;
      final normalizedY = (forecasts[i].cumulativeRoi - minRoi) / roiRange;
      final y = paddingTop + chartHeight - (normalizedY * chartHeight);
      points.add(Offset(x, y));
    }

    // المنطقة المظللة
    if (points.length >= 2) {
      final areaPath = Path()
        ..moveTo(points.first.dx, paddingTop + chartHeight);
      for (final p in points) {
        areaPath.lineTo(p.dx, p.dy);
      }
      areaPath.lineTo(points.last.dx, paddingTop + chartHeight);
      areaPath.close();

      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.25),
            const Color(0xFF10B981).withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(areaPath, areaPaint);
    }

    // الخط الرئيسي
    final linePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    canvas.drawPath(linePath, linePaint);

    // نقطة النهاية
    if (points.isNotEmpty) {
      final last = points.last;
      canvas.drawCircle(
        last,
        6,
        Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white,
      );
      canvas.drawCircle(
        last,
        4,
        Paint()..color = const Color(0xFF10B981),
      );
    }

    // تسميات المحور السيني
    final daysToShow = [0, forecasts.length ~/ 4, forecasts.length ~/ 2, (forecasts.length * 3) ~/ 4, forecasts.length - 1];
    for (final idx in daysToShow) {
      if (idx >= 0 && idx < forecasts.length) {
        final x = paddingLeft + idx * stepX;
        final tp = TextPainter(
          text: TextSpan(text: 'ي${forecasts[idx].day}', style: labelStyle),
          textDirection: TextDirection.rtl,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - paddingBottom + 6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
