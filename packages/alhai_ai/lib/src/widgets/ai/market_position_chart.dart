/// خريطة الموقع السوقي - Market Position Chart Widget
///
/// رسم بياني scatter يوضح موقع المتجر مقارنة بالمنافسين
/// المحور x = مؤشر السعر، المحور y = مؤشر الجودة، حجم الفقاعة = الحصة السوقية
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_competitor_analysis_service.dart';

/// خريطة الموقع السوقي
class MarketPositionChart extends StatefulWidget {
  final MarketPosition position;
  final double height;

  const MarketPositionChart({
    super.key,
    required this.position,
    this.height = 350,
  });

  @override
  State<MarketPositionChart> createState() => _MarketPositionChartState();
}

class _MarketPositionChartState extends State<MarketPositionChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
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
          Padding(
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
                  child: const Icon(Icons.scatter_plot_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خريطة الموقع السوقي',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'السعر مقابل الجودة',
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.position.positionLabelAr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.xxl,
                  AlhaiSpacing.zero, AlhaiSpacing.mdl, AlhaiSpacing.xxl),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return MouseRegion(
                        onHover: (event) {
                          _updateHoveredPoint(event.localPosition, constraints);
                        },
                        onExit: (_) => setState(() => _hoveredIndex = null),
                        child: CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _MarketPositionPainter(
                            points: widget.position.competitors,
                            animationValue: _animation.value,
                            hoveredIndex: _hoveredIndex,
                            isDark: isDark,
                            lowLabel: l10n.low,
                            highLabel: l10n.high,
                            mediumLabel: l10n.medium,
                            qualityLabel: l10n.quality,
                            luxuryLabel: l10n.luxury,
                            economicLabel: l10n.economic,
                            ourStoreLabel: l10n.ourStore,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          // Legend
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.md,
                AlhaiSpacing.zero, AlhaiSpacing.md, AlhaiSpacing.sm),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: widget.position.competitors.map((point) {
                final color = point.isUs
                    ? AppColors.primary
                    : _getCompetitorColor(point.name);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: point.isUs
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                        boxShadow: point.isUs
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 4)
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      point.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            point.isUs ? FontWeight.w700 : FontWeight.w500,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _updateHoveredPoint(Offset position, BoxConstraints constraints) {
    final points = widget.position.competitors;
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;

    for (int i = 0; i < points.length; i++) {
      final px = points[i].priceIndex * w;
      final py = h - (points[i].qualityIndex * h);
      final distance = (Offset(px, py) - position).distance;
      final radius = max(15.0, points[i].marketShare * 120);
      if (distance <= radius) {
        if (_hoveredIndex != i) {
          setState(() => _hoveredIndex = i);
        }
        return;
      }
    }
    if (_hoveredIndex != null) {
      setState(() => _hoveredIndex = null);
    }
  }

  static Color _getCompetitorColor(String name) {
    final colors = {
      'بنده': const Color(0xFFF97316),
      'الدانوب': const Color(0xFF3B82F6),
      'كارفور': const Color(0xFFEF4444),
      'التميمي': const Color(0xFF8B5CF6),
      'العثيم': const Color(0xFF14B8A6),
    };
    return colors[name] ?? AppColors.grey400;
  }
}

/// رسام خريطة الموقع
class _MarketPositionPainter extends CustomPainter {
  final List<MarketPositionPoint> points;
  final double animationValue;
  final int? hoveredIndex;
  final bool isDark;
  final String lowLabel;
  final String highLabel;
  final String mediumLabel;
  final String qualityLabel;
  final String luxuryLabel;
  final String economicLabel;
  final String ourStoreLabel;

  _MarketPositionPainter({
    required this.points,
    required this.animationValue,
    this.hoveredIndex,
    required this.isDark,
    required this.lowLabel,
    required this.highLabel,
    required this.mediumLabel,
    required this.qualityLabel,
    required this.luxuryLabel,
    required this.economicLabel,
    required this.ourStoreLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawAxisLabels(canvas, size);
    _drawQuadrantLabels(canvas, size);
    _drawPoints(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Center lines (dashed)
    final centerPaint = Paint()
      ..color =
          isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.grey300
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    for (double i = 0; i < size.width; i += 8) {
      canvas.drawLine(
          Offset(i, cy), Offset(min(i + 4, size.width), cy), centerPaint);
    }
    for (double i = 0; i < size.height; i += 8) {
      canvas.drawLine(
          Offset(cx, i), Offset(cx, min(i + 4, size.height)), centerPaint);
    }
  }

  void _drawAxisLabels(Canvas canvas, Size size) {
    final color =
        isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted;

    // X axis labels
    final xLabels = [lowLabel, '', mediumLabel, '', highLabel];
    for (int i = 0; i < xLabels.length; i++) {
      if (xLabels[i].isEmpty) continue;
      final tp = TextPainter(
        text: TextSpan(
            text: xLabels[i], style: TextStyle(color: color, fontSize: 10)),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
          canvas, Offset(size.width * i / 4 - tp.width / 2, size.height + 8));
    }

    // Y axis labels
    final yLabels = [highLabel, '', mediumLabel, '', lowLabel];
    for (int i = 0; i < yLabels.length; i++) {
      if (yLabels[i].isEmpty) continue;
      final tp = TextPainter(
        text: TextSpan(
            text: yLabels[i], style: TextStyle(color: color, fontSize: 10)),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(
          canvas, Offset(-tp.width - 6, size.height * i / 4 - tp.height / 2));
    }

    // X axis title
    final xTitle = TextPainter(
      text: TextSpan(
        text: 'السعر ',
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    xTitle.paint(
        canvas, Offset(size.width / 2 - xTitle.width / 2, size.height + 22));

    // Y axis title
    final yTitle = TextPainter(
      text: TextSpan(
        text: qualityLabel,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    canvas.save();
    canvas.translate(-30, size.height / 2 + yTitle.width / 2);
    canvas.rotate(-pi / 2);
    yTitle.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawQuadrantLabels(Canvas canvas, Size size) {
    final color =
        isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.grey200;
    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : AppColors.textMuted.withValues(alpha: 0.5);

    final quadrants = [
      {
        'label': 'قيمة ممتازة',
        'x': size.width * 0.20,
        'y': size.height * 0.20,
        'color': AppColors.success
      },
      {
        'label': luxuryLabel,
        'x': size.width * 0.75,
        'y': size.height * 0.20,
        'color': AppColors.info
      },
      {
        'label': economicLabel,
        'x': size.width * 0.20,
        'y': size.height * 0.80,
        'color': AppColors.warning
      },
      {
        'label': 'مبالغ فيه',
        'x': size.width * 0.75,
        'y': size.height * 0.80,
        'color': AppColors.error
      },
    ];

    for (final q in quadrants) {
      final tp = TextPainter(
        text: TextSpan(
          text: q['label'] as String,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(q['x'] as double, q['y'] as double),
          width: tp.width + 16,
          height: tp.height + 8,
        ),
        const Radius.circular(6),
      );
      canvas.drawRRect(bgRect, Paint()..color = color);
      tp.paint(
          canvas,
          Offset(
            (q['x'] as double) - tp.width / 2,
            (q['y'] as double) - tp.height / 2,
          ));
    }
  }

  void _drawPoints(Canvas canvas, Size size) {
    final competitorColors = {
      ourStoreLabel: AppColors.primary,
      'بنده': const Color(0xFFF97316),
      'الدانوب': const Color(0xFF3B82F6),
      'كارفور': const Color(0xFFEF4444),
      'التميمي': const Color(0xFF8B5CF6),
      'العثيم': const Color(0xFF14B8A6),
    };

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final x = point.priceIndex * size.width * animationValue;
      final y =
          size.height - (point.qualityIndex * size.height * animationValue);
      final radius = max(15.0, point.marketShare * 120) * animationValue;
      final color = competitorColors[point.name] ?? AppColors.grey400;
      final isHovered = hoveredIndex == i;
      final actualRadius = isHovered ? radius * 1.2 : radius;

      // Glow
      if (point.isUs || isHovered) {
        canvas.drawCircle(
          Offset(x, y),
          actualRadius + 6,
          Paint()..color = color.withValues(alpha: 0.2),
        );
      }

      // Main circle
      canvas.drawCircle(
        Offset(x, y),
        actualRadius,
        Paint()..color = color.withValues(alpha: point.isUs ? 0.85 : 0.6),
      );

      // Border
      canvas.drawCircle(
        Offset(x, y),
        actualRadius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = point.isUs ? 3 : 2,
      );

      // Star for us
      if (point.isUs) {
        final starPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(x, y), 4, starPaint);
      }

      // Label
      final tp = TextPainter(
        text: TextSpan(
          text: point.name,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.8)
                : AppColors.textPrimary,
            fontSize: isHovered ? 12 : 10,
            fontWeight: point.isUs ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y + actualRadius + 4));

      // Tooltip on hover
      if (isHovered) {
        final tooltipText =
            '${point.name}\nسعر: ${(point.priceIndex * 100).toInt()}% | جودة: ${(point.qualityIndex * 100).toInt()}%\nحصة: ${(point.marketShare * 100).toInt()}%';
        final tooltipTp = TextPainter(
          text: TextSpan(
            text: tooltipText,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 11,
            ),
          ),
          textDirection: TextDirection.rtl,
        )..layout();

        final tooltipRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y - actualRadius - tooltipTp.height - 16),
            width: tooltipTp.width + 20,
            height: tooltipTp.height + 12,
          ),
          const Radius.circular(8),
        );
        canvas.drawRRect(
          tooltipRect,
          Paint()..color = isDark ? const Color(0xFF374151) : Colors.white,
        );
        canvas.drawRRect(
          tooltipRect,
          Paint()
            ..color = color.withValues(alpha: 0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        tooltipTp.paint(
            canvas,
            Offset(
              x - tooltipTp.width / 2,
              y - actualRadius - tooltipTp.height - 10,
            ));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MarketPositionPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}
