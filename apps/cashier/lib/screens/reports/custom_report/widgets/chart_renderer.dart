/// رسم بياني بسيط (bar chart) لبيانات التقرير
///
/// يُبنى عبر [CustomPainter] بدون أي حزم خارجية. يتوافق مع RTL
/// وداكن/فاتح. يُعرض تحت جدول [ReportPreview] ويُخفى تلقائيّاً إذا
/// كانت القيم كلها صفر.
library;

import 'package:flutter/material.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/report_data_provider.dart';

class ChartRenderer extends StatelessWidget {
  final ReportResult result;
  final bool isDark;

  const ChartRenderer({super.key, required this.result, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (result.rows.isEmpty) return const SizedBox.shrink();

    // لا نعرض الرسم إذا كانت كل القيم صفر (مثلاً تقرير عملاء)
    final hasValues = result.rows.any((r) => ((r['value'] as double?) ?? 0) > 0);
    if (!hasValues) return const SizedBox.shrink();

    final maxValue = result.rows
        .map((r) => (r['value'] as double?) ?? 0)
        .fold<double>(0, (a, b) => a > b ? a : b);

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
                  color: AppColors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.valueLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _BarChartPainter(
                rows: result.rows,
                maxValue: maxValue,
                barColor: AppColors.primary,
                labelColor: AppColors.getTextMuted(isDark),
                isDark: isDark,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> rows;
  final double maxValue;
  final Color barColor;
  final Color labelColor;
  final bool isDark;

  _BarChartPainter({
    required this.rows,
    required this.maxValue,
    required this.barColor,
    required this.labelColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (rows.isEmpty || maxValue <= 0) return;

    final n = rows.length;
    const labelH = 22.0;
    final chartH = size.height - labelH;
    const gap = 6.0;
    final barW = (size.width - gap * (n + 1)) / n;
    if (barW <= 0) return;

    final paint = Paint()
      ..color = barColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    for (var i = 0; i < n; i++) {
      final row = rows[i];
      final v = (row['value'] as double?) ?? 0;
      final h = maxValue > 0 ? (v / maxValue) * chartH : 0.0;
      final x = gap + i * (barW + gap);
      final y = chartH - h;

      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW, h),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rect, paint);

      // P2 #9 (2026-04-24): previously the label was cut with
      // `substring(length - 7)` which mangled multi-byte Arabic glyphs and
      // chopped off the wrong end for RTL labels. Use the text painter's
      // built-in `ellipsis` + `maxLines: 1` so the engine handles both
      // direction and grapheme boundaries correctly.
      final label = (row['label'] as String? ?? '');
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: labelColor, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '\u2026',
      )..layout(maxWidth: barW + gap);
      textPainter.paint(
        canvas,
        Offset(x + (barW - textPainter.width) / 2, chartH + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) =>
      old.rows != rows || old.maxValue != maxValue || old.isDark != isDark;
}
