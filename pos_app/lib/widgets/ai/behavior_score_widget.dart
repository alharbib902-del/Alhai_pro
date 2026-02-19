/// ويدجت درجة السلوك - Behavior Score Widget
///
/// دائرة تقدم تعرض درجة سلوك الكاشير مع ترميز الألوان
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/ai_fraud_detection_service.dart';

/// ويدجت درجة السلوك
class BehaviorScoreWidget extends StatelessWidget {
  final BehaviorScore score;
  final VoidCallback? onTap;
  final bool compact;

  const BehaviorScoreWidget({
    super.key,
    required this.score,
    this.onTap,
    this.compact = false,
  });

  Color _getScoreColor() {
    if (score.score >= 70) return const Color(0xFF22C55E); // Green
    if (score.score >= 40) return const Color(0xFFF59E0B); // Yellow
    return const Color(0xFFEF4444); // Red
  }

  String _getScoreLabel(AppLocalizations l10n) {
    if (score.score >= 70) return l10n.good;
    if (score.score >= 40) return 'تحت المراقبة'; // Under Watch
    return l10n.danger;
  }

  IconData _getTrendIcon() {
    switch (score.trend) {
      case BehaviorTrend.up:
        return Icons.trending_up_rounded;
      case BehaviorTrend.down:
        return Icons.trending_down_rounded;
      case BehaviorTrend.stable:
        return Icons.trending_flat_rounded;
    }
  }

  Color _getTrendColor() {
    switch (score.trend) {
      case BehaviorTrend.up:
        return AppColors.success;
      case BehaviorTrend.down:
        return AppColors.error;
      case BehaviorTrend.stable:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final scoreColor = _getScoreColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: compact ? _buildCompact(isDark, scoreColor, l10n) : _buildFull(isDark, scoreColor, l10n),
        ),
      ),
    );
  }

  Widget _buildCompact(bool isDark, Color scoreColor, AppLocalizations l10n) {
    return Row(
      children: [
        // Circular score
        SizedBox(
          width: 48,
          height: 48,
          child: CustomPaint(
            painter: _CircularScorePainter(
              score: score.score,
              color: scoreColor,
              backgroundColor: scoreColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                score.score.toInt().toString(),
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                score.name,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(_getTrendIcon(), size: 14, color: _getTrendColor()),
                  const SizedBox(width: 4),
                  Text(
                    _getScoreLabel(l10n),
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Alert count badge
        if (score.alertCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${score.alertCount}',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFull(bool isDark, Color scoreColor, AppLocalizations l10n) {
    return Column(
      children: [
        // Header
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: scoreColor.withValues(alpha: 0.15),
              child: Text(
                score.name.isNotEmpty ? score.name[0] : '?',
                style: TextStyle(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    score.name,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${score.totalTransactions} معاملة', // X transactions
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(_getTrendIcon(), size: 20, color: _getTrendColor()),
          ],
        ),

        const SizedBox(height: 16),

        // Circular progress
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _CircularScorePainter(
              score: score.score,
              color: scoreColor,
              backgroundColor: scoreColor.withValues(alpha: 0.15),
              strokeWidth: 6,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score.score.toInt().toString(),
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getScoreLabel(l10n),
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Factor bars
        ...score.factors.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FactorBar(
                label: entry.key,
                value: entry.value,
                isDark: isDark,
              ),
            )),
      ],
    );
  }
}

/// رسام الدائرة - Circular Score Painter
class _CircularScorePainter extends CustomPainter {
  final double score;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  _CircularScorePainter({
    required this.score,
    required this.color,
    required this.backgroundColor,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularScorePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}

/// شريط عامل - Factor Bar
class _FactorBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 - 1.0
  final bool isDark;

  const _FactorBar({
    required this.label,
    required this.value,
    required this.isDark,
  });

  Color _getBarColor() {
    if (value >= 0.7) return AppColors.success;
    if (value >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(_getBarColor()),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
