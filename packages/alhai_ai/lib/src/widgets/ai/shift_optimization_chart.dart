/// رسم خريطة حرارية للورديات - Shift Optimization Chart Widget
///
/// CustomPaint heatmap: ساعات(x) * أيام(y) -> كثافة اللون للتوظيف الأمثل
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_staff_analytics_service.dart';

/// خريطة حرارية لتحسين الورديات
class ShiftOptimizationChart extends StatefulWidget {
  final ShiftHeatmapData data;
  final double height;

  const ShiftOptimizationChart({
    super.key,
    required this.data,
    this.height = 300,
  });

  @override
  State<ShiftOptimizationChart> createState() => _ShiftOptimizationChartState();
}

class _ShiftOptimizationChartState extends State<ShiftOptimizationChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredDay;
  int? _hoveredHour;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.border),
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
          Padding(
            padding: const EdgeInsets.all(AlhaiSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_view_week_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خريطة حرارية للورديات',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'كثافة الحركة حسب اليوم والساعة',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Legend
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.quiet,
                        style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textMuted)),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    ...[0.1, 0.3, 0.5, 0.7, 0.9].map((v) {
                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _getHeatColor(v, isDark),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(l10n.busy,
                        style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),

          // Heatmap
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(
                  60, AlhaiSpacing.zero, AlhaiSpacing.md, AlhaiSpacing.xxl),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return MouseRegion(
                        onHover: (event) {
                          _updateHovered(event.localPosition, constraints);
                        },
                        onExit: (_) => setState(() {
                          _hoveredDay = null;
                          _hoveredHour = null;
                        }),
                        child: CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _HeatmapPainter(
                            data: widget.data,
                            animationValue: _animation.value,
                            hoveredDay: _hoveredDay,
                            hoveredHour: _hoveredHour,
                            isDark: isDark,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateHovered(Offset position, BoxConstraints constraints) {
    final cellW = constraints.maxWidth / widget.data.hours.length;
    final cellH = constraints.maxHeight / widget.data.days.length;
    final hour = (position.dx / cellW).floor();
    final day = (position.dy / cellH).floor();

    if (hour >= 0 &&
        hour < widget.data.hours.length &&
        day >= 0 &&
        day < widget.data.days.length) {
      if (_hoveredDay != day || _hoveredHour != hour) {
        setState(() {
          _hoveredDay = day;
          _hoveredHour = hour;
        });
      }
    }
  }

  static Color _getHeatColor(double intensity, bool isDark) {
    if (intensity < 0.25) {
      return isDark
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.primary.withValues(alpha: 0.08);
    } else if (intensity < 0.5) {
      return isDark
          ? AppColors.primary.withValues(alpha: 0.3)
          : AppColors.primary.withValues(alpha: 0.25);
    } else if (intensity < 0.75) {
      return isDark
          ? AppColors.warning.withValues(alpha: 0.5)
          : AppColors.warning.withValues(alpha: 0.45);
    } else {
      return isDark
          ? AppColors.error.withValues(alpha: 0.7)
          : AppColors.error.withValues(alpha: 0.6);
    }
  }
}

/// رسام الخريطة الحرارية
class _HeatmapPainter extends CustomPainter {
  final ShiftHeatmapData data;
  final double animationValue;
  final int? hoveredDay;
  final int? hoveredHour;
  final bool isDark;

  _HeatmapPainter({
    required this.data,
    required this.animationValue,
    this.hoveredDay,
    this.hoveredHour,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / data.hours.length;
    final cellH = size.height / data.days.length;
    const gap = 2.0;

    // Draw cells
    for (int day = 0; day < data.days.length; day++) {
      for (int hour = 0; hour < data.hours.length; hour++) {
        final intensity = data.intensity[day][hour] * animationValue;
        final isHovered = hoveredDay == day && hoveredHour == hour;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            hour * cellW + gap,
            day * cellH + gap,
            cellW - gap * 2,
            cellH - gap * 2,
          ),
          const Radius.circular(4),
        );

        // Cell color
        Color cellColor;
        if (intensity < 0.25) {
          cellColor = isDark
              ? AppColors.primary.withValues(alpha: 0.1 * animationValue)
              : AppColors.primary.withValues(alpha: 0.08 * animationValue);
        } else if (intensity < 0.5) {
          cellColor = isDark
              ? AppColors.primary.withValues(alpha: 0.3 * animationValue)
              : AppColors.primary.withValues(alpha: 0.25 * animationValue);
        } else if (intensity < 0.75) {
          cellColor = isDark
              ? AppColors.warning.withValues(alpha: 0.5 * animationValue)
              : AppColors.warning.withValues(alpha: 0.45 * animationValue);
        } else {
          cellColor = isDark
              ? AppColors.error.withValues(alpha: 0.7 * animationValue)
              : AppColors.error.withValues(alpha: 0.6 * animationValue);
        }

        canvas.drawRRect(rect, Paint()..color = cellColor);

        // Hovered border
        if (isHovered) {
          canvas.drawRRect(
              rect,
              Paint()
                ..color = isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : AppColors.textPrimary
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2);

          // Tooltip
          final tooltipText =
              '${data.days[day]} - ${data.hours[hour]}:00\nكثافة: ${(intensity * 100).toInt()}%';
          final tp = TextPainter(
            text: TextSpan(
              text: tooltipText,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 11,
              ),
            ),
            textDirection: TextDirection.rtl,
          )..layout();

          final tooltipX = hour * cellW + cellW / 2;
          final tooltipY = day * cellH - tp.height - 16;
          final tooltipRect = RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(
                  tooltipX, max(tp.height / 2 + 6, tooltipY + tp.height / 2)),
              width: tp.width + 16,
              height: tp.height + 10,
            ),
            const Radius.circular(6),
          );
          canvas.drawRRect(tooltipRect,
              Paint()..color = isDark ? const Color(0xFF374151) : Colors.white);
          canvas.drawRRect(
              tooltipRect,
              Paint()
                ..color = isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border
                ..style = PaintingStyle.stroke);
          tp.paint(
              canvas,
              Offset(
                tooltipX - tp.width / 2,
                max(6, tooltipY + 1),
              ));
        }
      }
    }

    // Day labels
    for (int day = 0; day < data.days.length; day++) {
      final tp = TextPainter(
        text: TextSpan(
          text: data.days[day],
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas,
          Offset(-tp.width - 8, day * cellH + cellH / 2 - tp.height / 2));
    }

    // Hour labels
    for (int hour = 0; hour < data.hours.length; hour++) {
      if (hour % 2 != 0) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: '${data.hours[hour]}',
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : AppColors.textMuted,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(hour * cellW + cellW / 2 - tp.width / 2, size.height + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.hoveredDay != hoveredDay ||
        oldDelegate.hoveredHour != hoveredHour;
  }
}
