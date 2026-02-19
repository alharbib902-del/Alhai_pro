/// لوحة "ماذا لو" - What-If Panel
///
/// محاكاة تأثير الخصومات وتغييرات الأسعار على الإيرادات
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/ai_sales_forecasting_service.dart';

/// لوحة "ماذا لو"
class WhatIfPanel extends StatelessWidget {
  final double discountPercent;
  final double priceChangePercent;
  final WhatIfResult? result;
  final bool isLoading;
  final ValueChanged<double> onDiscountChanged;
  final ValueChanged<double> onPriceChanged;

  const WhatIfPanel({
    super.key,
    required this.discountPercent,
    required this.priceChangePercent,
    this.result,
    this.isLoading = false,
    required this.onDiscountChanged,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.science_rounded,
                  color: AppColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'محاكاة "ماذا لو"', // What-If simulation
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'جرب تأثير التغييرات على الإيرادات',
                      // Try the impact of changes on revenue
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // الخصم
          _buildSliderSection(
            label: 'نسبة الخصم', // Discount %
            value: discountPercent,
            min: 0,
            max: 50,
            suffix: '%',
            color: AppColors.secondary,
            isDark: isDark,
            onChanged: onDiscountChanged,
          ),

          const SizedBox(height: 16),

          // تغيير السعر
          _buildSliderSection(
            label: 'تغيير السعر', // Price change
            value: priceChangePercent,
            min: -30,
            max: 30,
            suffix: '%',
            color: AppColors.info,
            isDark: isDark,
            onChanged: onPriceChanged,
          ),

          const SizedBox(height: 20),

          // النتيجة
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (result != null)
            _buildResult(result!, isDark, l10n),
        ],
      ),
    );
  }

  Widget _buildSliderSection({
    required String label,
    required double value,
    required double min,
    required double max,
    required String suffix,
    required Color color,
    required bool isDark,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(0)}$suffix',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.15),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 1).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildResult(WhatIfResult result, bool isDark, AppLocalizations l10n) {
    final isPositive = result.change >= 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.02),
                ]
              : [
                  AppColors.error.withValues(alpha: 0.08),
                  AppColors.error.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPositive
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // المقارنة
          Row(
            children: [
              Expanded(
                child: _buildCompareItem(
                  label: l10n.currentLabel,
                  value: '${result.originalRevenue.toStringAsFixed(0)} ر.س',
                  isDark: isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: isDark ? Colors.white38 : AppColors.textMuted,
                  size: 20,
                ),
              ),
              Expanded(
                child: _buildCompareItem(
                  label: l10n.projected,
                  value: '${result.projectedRevenue.toStringAsFixed(0)} ر.س',
                  isDark: isDark,
                  isHighlighted: true,
                  isPositive: isPositive,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // التغيير
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: isPositive ? AppColors.primary : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                '${isPositive ? '+' : ''}${result.change.toStringAsFixed(0)} ر.س (${result.changePercent.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppColors.primary : AppColors.error,
                ),
              ),
            ],
          ),

          if (result.explanation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              result.explanation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompareItem({
    required String label,
    required String value,
    required bool isDark,
    bool isHighlighted = false,
    bool isPositive = true,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isHighlighted
                ? (isPositive ? AppColors.primary : AppColors.error)
                : (isDark ? Colors.white : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
