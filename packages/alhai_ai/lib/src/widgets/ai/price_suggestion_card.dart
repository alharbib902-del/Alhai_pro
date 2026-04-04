/// بطاقة اقتراح السعر - Price Suggestion Card
///
/// عرض اقتراح سعر لمنتج مع المقارنة والتأثير المتوقع
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_smart_pricing_service.dart';

/// بطاقة اقتراح السعر
class PriceSuggestionCard extends StatelessWidget {
  final PriceSuggestion suggestion;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const PriceSuggestionCard({
    super.key,
    required this.suggestion,
    this.isSelected = false,
    this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.05)
                : isDark
                    ? const Color(0xFF1E293B)
                    : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.5)
                  : isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border,
              width: isSelected ? 1.5 : 1,
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
              // رأس البطاقة
              Row(
                children: [
                  // أيقونة المنتج
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      suggestion.icon,
                      color: isDark ? Colors.white54 : AppColors.grey500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // الاسم
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AlhaiSpacing.xxxs),
                        // شارة الثقة
                        _buildConfidenceBadge(isDark),
                      ],
                    ),
                  ),
                  // التغيير
                  _buildChangeArrow(isDark),
                ],
              ),

              const SizedBox(height: AlhaiSpacing.sm),

              // السعر الحالي مقابل المقترح
              Row(
                children: [
                  Expanded(
                    child: _buildPriceColumn(
                      label: l10n.currentLabel,
                      price: suggestion.currentPrice,
                      margin: suggestion.currentMargin,
                      isDark: isDark,
                      isHighlighted: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: suggestion.isIncrease
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                  ),
                  Expanded(
                    child: _buildPriceColumn(
                      label: l10n.suggested,
                      price: suggestion.suggestedPrice,
                      margin: suggestion.suggestedMargin,
                      isDark: isDark,
                      isHighlighted: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // السبب
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  suggestion.reasoning,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // التأثير الشهري
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'التأثير الشهري المتوقع:', // Expected monthly impact
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${suggestion.expectedImpact.monthlyRevenueDelta >= 0 ? '+' : ''}${suggestion.expectedImpact.monthlyRevenueDelta.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: suggestion.expectedImpact.monthlyRevenueDelta >= 0
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(bool isDark) {
    final confidenceText = suggestion.confidence >= 0.9
        ? 'ثقة عالية' // High confidence
        : suggestion.confidence >= 0.7
            ? 'ثقة متوسطة' // Medium confidence
            : 'ثقة منخفضة'; // Low confidence
    final color = suggestion.confidence >= 0.9
        ? AppColors.primary
        : suggestion.confidence >= 0.7
            ? AppColors.warning
            : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: AlhaiSpacing.xxxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$confidenceText (${(suggestion.confidence * 100).toStringAsFixed(0)}%)',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildChangeArrow(bool isDark) {
    final isUp = suggestion.isIncrease;
    final color = isUp ? AppColors.primary : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AlhaiSpacing.xxxs),
          Text(
            '${suggestion.changePercent.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn({
    required String label,
    required double price,
    required double margin,
    required bool isDark,
    required bool isHighlighted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xxxs),
        Text(
          '${price.toStringAsFixed(2)} ر.س',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isHighlighted
                ? AppColors.primary
                : isDark
                    ? Colors.white
                    : AppColors.textPrimary,
          ),
        ),
        Text(
          'هامش: ${margin.toStringAsFixed(1)}%', // Margin
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
