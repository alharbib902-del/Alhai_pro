/// مقياس المشاعر - Sentiment Gauge Widget
///
/// CustomPaint semicircle gauge: أحمر -> أصفر -> أخضر مع مؤشر
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_sentiment_analysis_service.dart';

/// مقياس المشاعر نصف دائري
class SentimentGauge extends StatefulWidget {
  final double value; // -1.0 to 1.0
  final SentimentScore score;
  final double satisfactionRate;
  final double nps;
  final int totalReviews;

  const SentimentGauge({
    super.key,
    required this.value,
    required this.score,
    required this.satisfactionRate,
    required this.nps,
    required this.totalReviews,
  });

  @override
  State<SentimentGauge> createState() => _SentimentGaugeState();
}

class _SentimentGaugeState extends State<SentimentGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
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
    final l10n = AppLocalizations.of(context)!;
    final label = AiSentimentAnalysisService.getSentimentLabel(widget.score);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
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
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sentiment_satisfied_alt_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مقياس رضا العملاء',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${widget.totalReviews} تقييم',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // Gauge
          SizedBox(
            height: 160,
            width: 260,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(260, 160),
                  painter: _GaugePainter(
                    value: widget.value,
                    animationValue: _animation.value,
                    isDark: isDark,
                    negativeLabel: l10n.negative,
                    neutralLabel: l10n.neutral,
                    positiveLabel: l10n.positive,
                  ),
                );
              },
            ),
          ),

          // Score label
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: _getScoreColor(widget.value),
            ),
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // Stats row
          Row(
            children: [
              _StatItem(
                label: 'نسبة الرضا',
                value: '${widget.satisfactionRate}%',
                color: AppColors.success,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.grey200,
              ),
              _StatItem(
                label: 'NPS',
                value: '${widget.nps.toInt()}',
                color: widget.nps > 30 ? AppColors.success : AppColors.warning,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 36,
                color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.grey200,
              ),
              _StatItem(
                label: 'التقييمات',
                value: '${widget.totalReviews}',
                color: AppColors.info,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _getScoreColor(double value) {
    if (value > 0.5) return AppColors.success;
    if (value > 0.2) return AppColors.primaryLight;
    if (value > -0.2) return AppColors.warning;
    return AppColors.error;
  }
}

/// عنصر إحصائية
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatItem({required this.label, required this.value, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: color,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxxs),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// رسام مقياس نصف دائري
class _GaugePainter extends CustomPainter {
  final double value; // -1.0 to 1.0
  final double animationValue;
  final bool isDark;
  final String negativeLabel;
  final String neutralLabel;
  final String positiveLabel;

  _GaugePainter({
    required this.value,
    required this.animationValue,
    required this.isDark,
    required this.negativeLabel,
    required this.neutralLabel,
    required this.positiveLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final radius = size.width / 2 - 20;
    const startAngle = pi;
    const sweepAngle = pi;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round,
    );

    // Gradient arc segments
    const segments = 50;
    const segmentAngle = sweepAngle / segments;
    for (int i = 0; i < segments; i++) {
      final t = i / segments;
      final angle = startAngle + segmentAngle * i;
      Color segmentColor;
      if (t < 0.2) {
        segmentColor = const Color(0xFFEF4444);
      } else if (t < 0.4) {
        segmentColor = const Color(0xFFF97316);
      } else if (t < 0.6) {
        segmentColor = const Color(0xFFF59E0B);
      } else if (t < 0.8) {
        segmentColor = const Color(0xFF84CC16);
      } else {
        segmentColor = const Color(0xFF22C55E);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        angle,
        segmentAngle + 0.01,
        false,
        Paint()
          ..color = segmentColor.withValues(alpha: 0.7 * animationValue)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Needle
    final normalizedValue = (value + 1) / 2; // 0 to 1
    final needleAngle = startAngle + sweepAngle * normalizedValue * animationValue;
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    // Needle shadow
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    // Needle line
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = isDark ? Colors.white : AppColors.textPrimary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Center circle
    canvas.drawCircle(center, 10, Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white);
    canvas.drawCircle(center, 8, Paint()..color = _getScoreColor(value));
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // Value text
    final scorePercent = ((value + 1) / 2 * 100).toInt();
    final tp = TextPainter(
      text: TextSpan(
        text: '${(scorePercent * animationValue).toInt()}%',
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - radius * 0.5 - tp.height / 2));

    // Scale labels
    final labels = [
      {'text': negativeLabel, 'angle': startAngle + 0.15, 'color': const Color(0xFFEF4444)},
      {'text': neutralLabel, 'angle': startAngle + sweepAngle / 2, 'color': const Color(0xFFF59E0B)},
      {'text': positiveLabel, 'angle': startAngle + sweepAngle - 0.15, 'color': const Color(0xFF22C55E)},
    ];

    for (final label in labels) {
      final angle = label['angle'] as double;
      final color = label['color'] as Color;
      final ltp = TextPainter(
        text: TextSpan(
          text: label['text'] as String,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      final lx = center.dx + (radius + 16) * cos(angle) - ltp.width / 2;
      final ly = center.dy + (radius + 16) * sin(angle) - ltp.height / 2;
      ltp.paint(canvas, Offset(lx, ly));
    }
  }

  static Color _getScoreColor(double value) {
    if (value > 0.5) return const Color(0xFF22C55E);
    if (value > 0.2) return const Color(0xFF84CC16);
    if (value > -0.2) return const Color(0xFFF59E0B);
    if (value > -0.5) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
