/// رسم بياني للتوقعات - Forecast Chart
///
/// رسم بياني خطي يعرض المبيعات الفعلية مقابل المتوقعة
/// مع نطاق الثقة
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_sales_forecasting_service.dart';

/// رسم بياني للتوقعات
class ForecastChart extends StatefulWidget {
  final List<DailyForecast> forecasts;
  final double height;

  const ForecastChart({
    super.key,
    required this.forecasts,
    this.height = 280,
  });

  @override
  State<ForecastChart> createState() => _ForecastChartState();
}

class _ForecastChartState extends State<ForecastChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              const Icon(Icons.show_chart_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                'التوقعات مقابل الفعلي', // Forecast vs Actual
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          // المفتاح
          Row(
            children: [
              _buildLegend(l10n.actual, const Color(0xFF3B82F6), isDark),
              const SizedBox(width: AlhaiSpacing.md),
              _buildLegend(l10n.forecast, AppColors.primary, isDark),
              const SizedBox(width: AlhaiSpacing.md),
              _buildLegend('نطاق الثقة',
                  AppColors.primary.withValues(alpha: 0.2), isDark),
              // Confidence band
            ],
          ),
          const SizedBox(height: AlhaiSpacing.sm),
          // الرسم
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                final box = context.findRenderObject() as RenderBox?;
                if (box == null) return;
                final localX = details.localPosition.dx - 16;
                final chartWidth = box.size.width - 32;
                final index = (localX / chartWidth * widget.forecasts.length)
                    .round()
                    .clamp(0, widget.forecasts.length - 1);
                setState(() => _hoveredIndex = index);
              },
              onPanEnd: (_) => setState(() => _hoveredIndex = null),
              child: CustomPaint(
                painter: _ForecastChartPainter(
                  forecasts: widget.forecasts,
                  isDark: isDark,
                  hoveredIndex: _hoveredIndex,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // تفاصيل النقطة المحددة
          if (_hoveredIndex != null && _hoveredIndex! < widget.forecasts.length)
            _buildTooltip(widget.forecasts[_hoveredIndex!], isDark),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AlhaiSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTooltip(DailyForecast forecast, bool isDark) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: 6),
      margin: const EdgeInsets.only(top: AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            '${forecast.date.day}/${forecast.date.month}',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ),
          if (forecast.actual != null)
            Text(
              'فعلي: ${forecast.actual!.toStringAsFixed(0)} ر.س',
              // Actual
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          Text(
            'متوقع: ${forecast.predicted.toStringAsFixed(0)} ر.س',
            // Predicted
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// رسام الرسم البياني
class _ForecastChartPainter extends CustomPainter {
  final List<DailyForecast> forecasts;
  final bool isDark;
  final int? hoveredIndex;

  _ForecastChartPainter({
    required this.forecasts,
    required this.isDark,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (forecasts.isEmpty) return;

    final allValues = <double>[];
    for (final f in forecasts) {
      allValues.add(f.predicted);
      if (f.actual != null) allValues.add(f.actual!);
    }

    final maxVal = allValues.reduce(max) * 1.1;
    final minVal = allValues.reduce(min) * 0.9;
    final range = maxVal - minVal;
    if (range == 0) return;

    final w = size.width;
    final h = size.height;
    final stepX = forecasts.length > 1 ? w / (forecasts.length - 1) : w;

    double toY(double val) => h - ((val - minVal) / range * h);

    // نطاق الثقة
    final confidencePath = Path();
    for (var i = 0; i < forecasts.length; i++) {
      final x = i * stepX;
      final upper =
          forecasts[i].predicted * (1 + (1 - forecasts[i].confidence) * 0.5);
      if (i == 0) {
        confidencePath.moveTo(x, toY(upper));
      } else {
        confidencePath.lineTo(x, toY(upper));
      }
    }
    for (var i = forecasts.length - 1; i >= 0; i--) {
      final x = i * stepX;
      final lower =
          forecasts[i].predicted * (1 - (1 - forecasts[i].confidence) * 0.5);
      confidencePath.lineTo(x, toY(lower));
    }
    confidencePath.close();

    canvas.drawPath(
      confidencePath,
      Paint()..color = AppColors.primary.withValues(alpha: 0.08),
    );

    // خط المتوقع
    final predictedPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final predictedPath = Path();
    for (var i = 0; i < forecasts.length; i++) {
      final x = i * stepX;
      final y = toY(forecasts[i].predicted);
      if (i == 0) {
        predictedPath.moveTo(x, y);
      } else {
        predictedPath.lineTo(x, y);
      }
    }
    canvas.drawPath(predictedPath, predictedPaint);

    // خط الفعلي
    final actualPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final actualPath = Path();
    var started = false;
    for (var i = 0; i < forecasts.length; i++) {
      if (forecasts[i].actual == null) continue;
      final x = i * stepX;
      final y = toY(forecasts[i].actual!);
      if (!started) {
        actualPath.moveTo(x, y);
        started = true;
      } else {
        actualPath.lineTo(x, y);
      }
    }
    if (started) {
      canvas.drawPath(actualPath, actualPaint);
    }

    // نقطة الخط الفاصل (اليوم)
    final todayIndex = forecasts.indexWhere((f) => f.actual == null);
    if (todayIndex > 0 && todayIndex < forecasts.length) {
      final x = todayIndex * stepX;
      final dashPaint = Paint()
        ..color = isDark ? Colors.white24 : AppColors.grey300
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, 0), Offset(x, h), dashPaint);
    }

    // نقطة التحويم
    if (hoveredIndex != null && hoveredIndex! < forecasts.length) {
      final x = hoveredIndex! * stepX;
      final yP = toY(forecasts[hoveredIndex!].predicted);

      canvas.drawCircle(
        Offset(x, yP),
        6,
        Paint()..color = AppColors.primary.withValues(alpha: 0.3),
      );
      canvas.drawCircle(
        Offset(x, yP),
        4,
        Paint()..color = AppColors.primary,
      );

      if (forecasts[hoveredIndex!].actual != null) {
        final yA = toY(forecasts[hoveredIndex!].actual!);
        canvas.drawCircle(
          Offset(x, yA),
          6,
          Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.3),
        );
        canvas.drawCircle(
          Offset(x, yA),
          4,
          Paint()..color = const Color(0xFF3B82F6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ForecastChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.forecasts != forecasts;
  }
}
