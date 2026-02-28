/// بطاقة الأنماط الموسمية - Seasonal Patterns Card
///
/// عرض أنماط المبيعات حسب يوم الأسبوع مع رسم بياني عمودي
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_sales_forecasting_service.dart';

/// بطاقة الأنماط الموسمية
class SeasonalPatternsCard extends StatelessWidget {
  final List<SeasonalPattern> patterns;

  const SeasonalPatternsCard({
    super.key,
    required this.patterns,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_view_week_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أنماط المبيعات الأسبوعية', // Weekly sales patterns
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'أداء المبيعات حسب يوم الأسبوع', // Sales performance by day
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // الرسم البياني العمودي
          if (patterns.isNotEmpty)
            SizedBox(
              height: 160,
              child: _buildBarChart(isDark),
            ),

          const SizedBox(height: 16),

          // القائمة
          ...patterns.map((p) => _buildPatternRow(p, isDark)),
        ],
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    final maxMultiplier = patterns.map((p) => p.multiplier).reduce(max);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: patterns.map((pattern) {
        final heightFraction = pattern.multiplier / maxMultiplier;
        final isPeak = pattern.isPeak;
        final isLow = pattern.isLow;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // النسبة
                Text(
                  '${(pattern.multiplier * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPeak
                        ? AppColors.primary
                        : isLow
                            ? AppColors.error
                            : isDark
                                ? Colors.white54
                                : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // العمود
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 100 * heightFraction,
                  decoration: BoxDecoration(
                    gradient: isPeak
                        ? const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF059669), Color(0xFF10B981)],
                          )
                        : isLow
                            ? LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.error.withValues(alpha: 0.6),
                                  AppColors.error.withValues(alpha: 0.3),
                                ],
                              )
                            : LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  (isDark ? Colors.white24 : AppColors.grey300),
                                  (isDark ? Colors.white12 : AppColors.grey200),
                                ],
                              ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ),
                const SizedBox(height: 6),
                // اسم اليوم
                Text(
                  _shortDayName(pattern.name),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isPeak ? FontWeight.w600 : FontWeight.w400,
                    color: isPeak
                        ? AppColors.primary
                        : isDark
                            ? Colors.white54
                            : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternRow(SeasonalPattern pattern, bool isDark) {
    final isPeak = pattern.isPeak;
    final isLow = pattern.isLow;
    final icon = isPeak
        ? Icons.trending_up_rounded
        : isLow
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final color = isPeak
        ? AppColors.primary
        : isLow
            ? AppColors.error
            : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pattern.description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDayName(String name) {
    // اختصار أسماء الأيام العربية
    final map = {
      'الإثنين': 'إثن',
      'الثلاثاء': 'ثلا',
      'الأربعاء': 'أرب',
      'الخميس': 'خمي',
      'الجمعة': 'جمع',
      'السبت': 'سبت',
      'الأحد': 'أحد',
    };
    return map[name] ?? name;
  }
}
