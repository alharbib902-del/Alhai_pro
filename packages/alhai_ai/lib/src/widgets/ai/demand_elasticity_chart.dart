/// رسم بياني لمرونة الطلب - Demand Elasticity Chart
///
/// رسم بياني يعرض العلاقة بين السعر والطلب (منحنى الطلب)
/// مع تحديد السعر الحالي والمقترح
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_smart_pricing_service.dart';

/// رسم بياني لمرونة الطلب
class DemandElasticityChart extends StatelessWidget {
  final DemandElasticity? elasticity;
  final double currentPrice;
  final double suggestedPrice;
  final double height;

  const DemandElasticityChart({
    super.key,
    this.elasticity,
    required this.currentPrice,
    required this.suggestedPrice,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.border,
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
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.ssid_chart_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرونة الطلب السعرية', // Price demand elasticity
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    if (elasticity != null) _buildElasticityBadge(isDark, l10n),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // الرسم البياني
          SizedBox(
            height: height - 100,
            child: CustomPaint(
              painter: _DemandCurvePainter(
                elasticity: elasticity?.elasticity ?? 1.0,
                currentPrice: currentPrice,
                suggestedPrice: suggestedPrice,
                isDark: isDark,
                priceLabel: l10n.price,
                demandLabel: l10n.demand,
              ),
              size: Size.infinite,
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sm),

          // المفتاح
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot('السعر الحالي', const Color(0xFF3B82F6), isDark),
              // Current price
              const SizedBox(width: AlhaiSpacing.md),
              _buildLegendDot('السعر المقترح', AppColors.primary, isDark),
              // Suggested price
            ],
          ),

          // الوصف
          if (elasticity != null) ...[
            const SizedBox(height: AlhaiSpacing.sm),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                elasticity!.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildElasticityBadge(bool isDark, AppLocalizations l10n) {
    final e = elasticity!;
    final label = e.classification == ElasticityClass.inelastic
        ? 'غير مرن' // Inelastic
        : e.classification == ElasticityClass.elastic
        ? l10n.elastic
        : l10n.unit;
    final color = e.classification == ElasticityClass.inelastic
        ? AppColors.primary
        : e.classification == ElasticityClass.elastic
        ? AppColors.warning
        : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(top: AlhaiSpacing.xxxs),
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label (${e.elasticity.toStringAsFixed(2)})',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
}

/// رسام منحنى الطلب
class _DemandCurvePainter extends CustomPainter {
  final double elasticity;
  final double currentPrice;
  final double suggestedPrice;
  final bool isDark;
  final String priceLabel;
  final String demandLabel;

  _DemandCurvePainter({
    required this.elasticity,
    required this.currentPrice,
    required this.suggestedPrice,
    required this.isDark,
    required this.priceLabel,
    required this.demandLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const padding = 30.0;
    final chartW = w - padding * 2;
    final chartH = h - padding * 2;

    // المحاور
    final axisPaint = Paint()
      ..color = isDark ? Colors.white24 : AppColors.grey300
      ..strokeWidth = 1;

    // المحور Y (السعر)
    canvas.drawLine(
      const Offset(padding, padding),
      Offset(padding, h - padding),
      axisPaint,
    );
    // المحور X (الطلب)
    canvas.drawLine(
      Offset(padding, h - padding),
      Offset(w - padding, h - padding),
      axisPaint,
    );

    // تسمية المحاور
    final labelStyle = TextStyle(
      fontSize: 10,
      color: isDark ? Colors.white38 : AppColors.textMuted,
    );

    _drawText(
      canvas,
      priceLabel,
      const Offset(padding - 10, padding - 15),
      labelStyle,
    );
    _drawText(
      canvas,
      demandLabel,
      Offset(w - padding - 10, h - padding + 8),
      labelStyle,
    );

    // منحنى الطلب
    final curvePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final curvePath = Path();
    const steps = 50;

    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      // منحنى الطلب: Q = A * P^(-elasticity)
      // تبسيط: X يمثل الكمية (الطلب), Y يمثل السعر
      final x = padding + t * chartW;
      final priceNormalized = 1.0 - t; // السعر ينخفض من اليسار لليمين
      final demand = pow(max(0.01, priceNormalized), -elasticity.abs() * 0.5);
      final y = padding + chartH * (1 - min(1, max(0, demand / 3)));

      if (i == 0) {
        curvePath.moveTo(x, y);
      } else {
        curvePath.lineTo(x, y);
      }
    }
    canvas.drawPath(curvePath, curvePaint);

    // تحديد نقطة السعر الحالي
    if (currentPrice > 0) {
      final maxP = max(currentPrice, suggestedPrice) * 1.5;
      final normalizedCurrent = currentPrice / maxP;
      final currentX = padding + (1 - normalizedCurrent) * chartW;
      final currentDemand = pow(
        max(0.01, normalizedCurrent),
        -elasticity.abs() * 0.5,
      );
      final currentY =
          padding + chartH * (1 - min(1, max(0, currentDemand / 3)));

      // نقطة السعر الحالي
      canvas.drawCircle(
        Offset(currentX, currentY),
        8,
        Paint()..color = const Color(0xFF3B82F6).withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        Offset(currentX, currentY),
        5,
        Paint()..color = const Color(0xFF3B82F6),
      );

      // نقطة السعر المقترح
      final normalizedSuggested = suggestedPrice / maxP;
      final suggestedX = padding + (1 - normalizedSuggested) * chartW;
      final suggestedDemand = pow(
        max(0.01, normalizedSuggested),
        -elasticity.abs() * 0.5,
      );
      final suggestedY =
          padding + chartH * (1 - min(1, max(0, suggestedDemand / 3)));

      canvas.drawCircle(
        Offset(suggestedX, suggestedY),
        8,
        Paint()..color = AppColors.primary.withValues(alpha: 0.2),
      );
      canvas.drawCircle(
        Offset(suggestedX, suggestedY),
        5,
        Paint()..color = AppColors.primary,
      );

      // خط متقطع بين النقطتين
      final dashPaint = Paint()
        ..color = isDark ? Colors.white24 : AppColors.grey300
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(suggestedX, suggestedY),
        dashPaint,
      );
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final span = TextSpan(text: text, style: style);
    final painter = TextPainter(text: span, textDirection: TextDirection.rtl);
    painter.layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _DemandCurvePainter oldDelegate) {
    return oldDelegate.elasticity != elasticity ||
        oldDelegate.currentPrice != currentPrice ||
        oldDelegate.suggestedPrice != suggestedPrice;
  }
}
