/// Invoice Revenue Chart Widget - simple painted chart
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

class InvoiceRevenueChart extends StatelessWidget {
  final bool isDark;
  const InvoiceRevenueChart({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.revenueAnalysis,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.last7Days,
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface)),
                    SizedBox(width: AlhaiSpacing.xxs),
                    Icon(Icons.keyboard_arrow_down,
                        size: 16,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AlhaiSpacing.lg),
          SizedBox(
            height: 220,
            child: CustomPaint(
              size: Size.infinite,
              painter: _RevenueChartPainter(
                  isDark: isDark,
                  gridLineColor: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.05)),
            ),
          ),
          SizedBox(height: AlhaiSpacing.sm),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              l10n.sat,
              l10n.sun,
              l10n.mon,
              l10n.tue,
              l10n.wed,
              l10n.thu,
              l10n.fri
            ]
                .map((d) => Text(d,
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMuted)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _RevenueChartPainter extends CustomPainter {
  final bool isDark;
  final Color gridLineColor;
  _RevenueChartPainter({required this.isDark, required this.gridLineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final data = [
      12000.0,
      15000.0,
      11000.0,
      18000.0,
      14000.0,
      22000.0,
      19500.0
    ];
    const maxVal = 25000.0;

    // Grid lines
    final gridPaint = Paint()
      ..color = gridLineColor
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (1 - i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Y-axis labels
    final textStyle = TextStyle(
        fontSize: 10,
        color: isDark ? AppColors.textMutedDark : AppColors.textSecondary);
    for (int i = 0; i <= 4; i++) {
      final value = (maxVal * i / 4).toInt();
      final label = '${(value / 1000).toStringAsFixed(0)}k';
      final textPainter = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr)
        ..layout();
      textPainter.paint(canvas, Offset(-2, size.height * (1 - i / 4) - 6));
    }

    // Line & area
    final points = <Offset>[];
    final step = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      points.add(Offset(i * step, size.height * (1 - data[i] / maxVal)));
    }

    // Area fill
    final areaPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(size.width, size.height);
    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.02)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    // Line
    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()..color = AppColors.primary;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final p in points) {
      canvas.drawCircle(p, 4, dotPaint);
      canvas.drawCircle(p, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
