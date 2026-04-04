/// حاسبة تأثير الربح - Profit Impact Calculator
///
/// عرض تأثير تغيير السعر على الإيرادات والأرباح
/// مع slider للتحكم بالسعر ومقارنة قبل وبعد
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_smart_pricing_service.dart';

/// حاسبة تأثير الربح
class ProfitImpactCalculator extends StatelessWidget {
  final PriceSuggestion suggestion;
  final double currentSliderPrice;
  final PriceImpact? impact;
  final bool isLoading;
  final ValueChanged<double> onPriceChanged;
  final VoidCallback? onApply;

  const ProfitImpactCalculator({
    super.key,
    required this.suggestion,
    required this.currentSliderPrice,
    this.impact,
    this.isLoading = false,
    required this.onPriceChanged,
    this.onApply,
  });

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
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حاسبة التأثير', // Impact calculator
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    suggestion.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // Slider للسعر
          _buildPriceSlider(isDark),

          const SizedBox(height: AlhaiSpacing.mdl),

          // النتائج
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AlhaiSpacing.md),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (impact != null)
            _buildImpactResults(isDark),

          const SizedBox(height: AlhaiSpacing.md),

          // زر التطبيق
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'تطبيق السعر ${currentSliderPrice.toStringAsFixed(2)} ر.س',
                // Apply price X SAR
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSlider(bool isDark) {
    final minPrice = suggestion.costPrice * 1.05; // لا يقل عن 5% فوق التكلفة
    final maxPrice = suggestion.currentPrice * 1.5; // لا يزيد عن 50% فوق الحالي
    final changePercent = suggestion.currentPrice > 0
        ? ((currentSliderPrice - suggestion.currentPrice) /
            suggestion.currentPrice *
            100)
        : 0.0;
    final isUp = changePercent >= 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'السعر الجديد', // New price
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${currentSliderPrice.toStringAsFixed(2)} ر.س',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AlhaiSpacing.xxs),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withValues(alpha: 0.15),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: currentSliderPrice.clamp(minPrice, maxPrice),
            min: minPrice,
            max: maxPrice,
            divisions: ((maxPrice - minPrice) / 0.5).round().clamp(1, 200),
            onChanged: onPriceChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'التكلفة + 5%: ${minPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : AppColors.textMuted,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xxxs),
              decoration: BoxDecoration(
                color: isUp
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${isUp ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isUp ? AppColors.primary : AppColors.error,
                ),
              ),
            ),
            Text(
              '+50%: ${maxPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white38 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactResults(bool isDark) {
    final imp = impact!;
    return Column(
      children: [
        // صف المقارنة
        Row(
          children: [
            Expanded(
              child: _buildMetric(
                label: 'الإيرادات الشهرية', // Monthly revenue
                value:
                    '${imp.monthlyRevenueDelta >= 0 ? '+' : ''}${imp.monthlyRevenueDelta.toStringAsFixed(0)}',
                suffix: 'ر.س',
                isPositive: imp.monthlyRevenueDelta >= 0,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: _buildMetric(
                label: 'الربح السنوي', // Yearly profit
                value:
                    '${imp.yearlyProfitDelta >= 0 ? '+' : ''}${imp.yearlyProfitDelta.toStringAsFixed(0)}',
                suffix: 'ر.س',
                isPositive: imp.yearlyProfitDelta >= 0,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: AlhaiSpacing.sm),
            Expanded(
              child: _buildMetric(
                label: 'حجم المبيعات', // Sales volume
                value:
                    '${imp.volumeChange >= 0 ? '+' : ''}${imp.volumeChange.toStringAsFixed(1)}',
                suffix: '%',
                isPositive: imp.volumeChange >= 0,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required String suffix,
    required bool isPositive,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white38 : AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AlhaiSpacing.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$value $suffix',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isPositive ? AppColors.primary : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
