/// مخطط تحليل ABC - ABC Analysis Chart
///
/// مخطط باريتو باستخدام CustomPaint (أشرطة + خط تراكمي)
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_smart_inventory_service.dart';

/// مخطط تحليل ABC
class AbcAnalysisChart extends StatelessWidget {
  final List<AbcItem> items;
  final ValueChanged<AbcItem>? onItemTap;

  const AbcAnalysisChart({
    super.key,
    required this.items,
    this.onItemTap,
  });

  Color _getCategoryColor(AbcCategory category) {
    switch (category) {
      case AbcCategory.a:
        return const Color(0xFF10B981); // Green
      case AbcCategory.b:
        return const Color(0xFFF59E0B); // Yellow
      case AbcCategory.c:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getCategoryLabel(AbcCategory category) {
    switch (category) {
      case AbcCategory.a:
        return 'فئة أ'; // Category A
      case AbcCategory.b:
        return 'فئة ب'; // Category B
      case AbcCategory.c:
        return 'فئة ج'; // Category C
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                'مخطط باريتو - تحليل ABC', // Pareto Chart - ABC Analysis
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildLegend(isDark),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // Pareto chart
          SizedBox(
            height: 220,
            child: CustomPaint(
              size: Size.infinite,
              painter: _ParetoPainter(
                items: items,
                isDark: isDark,
                getCategoryColor: _getCategoryColor,
              ),
            ),
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // Items list
          ...items.take(8).map((item) => _AbcItemRow(
                item: item,
                isDark: isDark,
                color: _getCategoryColor(item.category),
                categoryLabel: _getCategoryLabel(item.category),
                onTap: () => onItemTap?.call(item),
              )),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendDot(
            color: _getCategoryColor(AbcCategory.a),
            label: 'A',
            isDark: isDark),
        const SizedBox(width: AlhaiSpacing.xs),
        _LegendDot(
            color: _getCategoryColor(AbcCategory.b),
            label: 'B',
            isDark: isDark),
        const SizedBox(width: AlhaiSpacing.xs),
        _LegendDot(
            color: _getCategoryColor(AbcCategory.c),
            label: 'C',
            isDark: isDark),
      ],
    );
  }
}

/// رسام مخطط باريتو - Pareto Painter
class _ParetoPainter extends CustomPainter {
  final List<AbcItem> items;
  final bool isDark;
  final Color Function(AbcCategory) getCategoryColor;

  _ParetoPainter({
    required this.items,
    required this.isDark,
    required this.getCategoryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final maxItems = math.min(items.length, 12);
    final barWidth = (size.width - 40) / maxItems - 4;
    final chartHeight = size.height - 30;
    final maxPercentage = items.map((i) => i.percentage).reduce(math.max);

    // Draw bars
    for (int i = 0; i < maxItems; i++) {
      final item = items[i];
      final barHeight =
          (item.percentage / maxPercentage) * (chartHeight * 0.85);
      final x = 30 + i * (barWidth + 4);
      final y = chartHeight - barHeight;

      final barPaint = Paint()
        ..color = getCategoryColor(item.category)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, barPaint);

      // Product name label (rotated)
      final nameSpan = TextSpan(
        text:
            item.name.length > 6 ? '${item.name.substring(0, 6)}..' : item.name,
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.5)
              : const Color(0xFF9CA3AF),
          fontSize: 8,
        ),
      );
      final namePainter = TextPainter(
        text: nameSpan,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: barWidth + 10);

      namePainter.paint(
        canvas,
        Offset(x + barWidth / 2 - namePainter.width / 2, chartHeight + 4),
      );
    }

    // Draw cumulative line
    final linePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < maxItems; i++) {
      final item = items[i];
      final x = 30 + i * (barWidth + 4) + barWidth / 2;
      final y = chartHeight - (item.cumulativePercentage / 100) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dot
      final dotPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
    canvas.drawPath(path, linePaint);

    // Y-axis labels
    final percentages = [0, 25, 50, 75, 100];
    for (final pct in percentages) {
      final y = chartHeight - (pct / 100) * chartHeight;
      final span = TextSpan(
        text: '$pct%',
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.3)
              : const Color(0xFFD1D5DB),
          fontSize: 9,
        ),
      );
      final painter = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, Offset(0, y - painter.height / 2));

      // Grid line
      final gridPaint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(28, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParetoPainter oldDelegate) {
    return oldDelegate.items != items || oldDelegate.isDark != isDark;
  }
}

/// صف عنصر ABC - ABC Item Row
class _AbcItemRow extends StatelessWidget {
  final AbcItem item;
  final bool isDark;
  final Color color;
  final String categoryLabel;
  final VoidCallback? onTap;

  const _AbcItemRow({
    required this.item,
    required this.isDark,
    required this.color,
    required this.categoryLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.xxs, vertical: 6),
          child: Row(
            children: [
              // Category badge
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    item.category == AbcCategory.a
                        ? 'A'
                        : item.category == AbcCategory.b
                            ? 'B'
                            : 'C',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Name
              Expanded(
                flex: 3,
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Revenue
              Expanded(
                flex: 2,
                child: Text(
                  '${(item.revenue / 1000).toStringAsFixed(1)}K',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              // Percentage bar
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: item.percentage / 25,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.grey200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: AlhaiSpacing.xs),
              SizedBox(
                width: 40,
                child: Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// نقطة المفتاح - Legend Dot
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? Colors.white.withValues(alpha: 0.5)
                : AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
