/// بطاقة أداء الموظف - Staff Performance Card Widget
///
/// حلقة النقاط، صف المقاييس الرئيسية، اتجاه الأداء
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_staff_analytics_service.dart';

/// بطاقة أداء الموظف
class StaffPerformanceCard extends StatefulWidget {
  final StaffPerformance staff;
  final int rank;
  final VoidCallback? onTap;

  const StaffPerformanceCard({
    super.key,
    required this.staff,
    required this.rank,
    this.onTap,
  });

  @override
  State<StaffPerformanceCard> createState() => _StaffPerformanceCardState();
}

class _StaffPerformanceCardState extends State<StaffPerformanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.staff.score / 100)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.staff.score >= 90) return AppColors.success;
    if (widget.staff.score >= 80) return AppColors.primary;
    if (widget.staff.score >= 70) return AppColors.warning;
    return AppColors.error;
  }

  String _rankBadge(AppLocalizations l10n) {
    switch (widget.rank) {
      case 1:
        return 'نجم المتجر';
      case 2:
        return l10n.outstanding;
      case 3:
        return 'جيد جداً';
      default:
        return l10n.good;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? _scoreColor.withValues(alpha: 0.4)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border),
            width: _isHovered ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? _scoreColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: _isHovered ? 14 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar and score ring
              Row(
                children: [
                  // Score ring + avatar
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _ScoreRingPainter(
                            progress: _scoreAnimation.value,
                            color: _scoreColor,
                            isDark: isDark,
                          ),
                          child: Center(
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: _scoreColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  widget.staff.avatarInitial,
                                  style: TextStyle(
                                    color: _scoreColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.staff.nameAr,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AlhaiSpacing.xs, vertical: 3),
                              decoration: BoxDecoration(
                                color: _scoreColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.staff.score.toStringAsFixed(1),
                                style: TextStyle(
                                  color: _scoreColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        Row(
                          children: [
                            Text(
                              widget.staff.role,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.xs),
                            if (widget.rank <= 3)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: AlhaiSpacing.xxxs),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: widget.rank == 1
                                        ? [
                                            const Color(0xFFFFD700),
                                            const Color(0xFFFFA000)
                                          ]
                                        : widget.rank == 2
                                            ? [
                                                const Color(0xFFC0C0C0),
                                                const Color(0xFF9E9E9E)
                                              ]
                                            : [
                                                const Color(0xFFCD7F32),
                                                const Color(0xFFA0522D)
                                              ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '#${widget.rank} ${_rankBadge(l10n)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AlhaiSpacing.md),

              // Key metrics row
              Row(
                children: [
                  _MetricItem(
                    label: l10n.sales,
                    value:
                        '${(widget.staff.salesVolume / 1000).toStringAsFixed(1)}K',
                    icon: Icons.attach_money_rounded,
                    isDark: isDark,
                  ),
                  _MetricItem(
                    label: 'متوسط الفاتورة',
                    value: '${widget.staff.avgTicket.toStringAsFixed(0)} ر.س',
                    icon: Icons.receipt_rounded,
                    isDark: isDark,
                  ),
                  _MetricItem(
                    label: 'عمليات/ساعة',
                    value: widget.staff.transactionsPerHour.toStringAsFixed(1),
                    icon: Icons.speed_rounded,
                    isDark: isDark,
                  ),
                  _MetricItem(
                    label: 'نسبة الإلغاء',
                    value: '${widget.staff.voidRate.toStringAsFixed(1)}%',
                    icon: Icons.cancel_rounded,
                    isDark: isDark,
                    valueColor:
                        widget.staff.voidRate > 3 ? AppColors.error : null,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Performance trend (mini sparkline)
              SizedBox(
                height: 30,
                child: CustomPaint(
                  size: const Size(double.infinity, 30),
                  painter: _SparklinePainter(
                    values: widget.staff.weeklyScores,
                    color: _scoreColor,
                    isDark: isDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// عنصر مقياس
class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color? valueColor;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              size: 14,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : AppColors.textMuted),
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color:
                  valueColor ?? (isDark ? Colors.white : AppColors.textPrimary),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.4)
                  : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// رسام حلقة النقاط
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _ScoreRingPainter(
      {required this.progress, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background ring
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color =
              isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.grey200
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4);

    // Progress ring
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// رسام خط الأداء المصغر
class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final bool isDark;

  _SparklinePainter(
      {required this.values, required this.color, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(max);
    final minV = values.reduce(min);
    final range = maxV - minV;
    final stepX = size.width / (values.length - 1);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = range > 0
          ? size.height -
              ((values[i] - minV) / range * size.height * 0.8 +
                  size.height * 0.1)
          : size.height / 2;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Fill
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.02)
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    // Line
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round);

    // Last dot
    final lastX = (values.length - 1) * stepX;
    final lastY = range > 0
        ? size.height -
            ((values.last - minV) / range * size.height * 0.8 +
                size.height * 0.1)
        : size.height / 2;
    canvas.drawCircle(Offset(lastX, lastY), 3, Paint()..color = color);
    canvas.drawCircle(Offset(lastX, lastY), 1.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
