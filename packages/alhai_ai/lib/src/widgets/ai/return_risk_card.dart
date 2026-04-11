/// بطاقة خطر الإرجاع
///
/// تعرض تفاصيل عملية بيع مع مؤشر خطر الإرجاع وعوامل الخطر
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_return_prediction_service.dart';

/// بطاقة خطر الإرجاع
class ReturnRiskCard extends StatelessWidget {
  final ReturnProbability probability;
  final VoidCallback? onTap;

  const ReturnRiskCard({super.key, required this.probability, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final riskColor = Color(
      AiReturnPredictionService.getRiskColorValue(probability.riskLevel),
    );
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: riskColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: riskColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: اسم العميل + مستوى الخطر
              Row(
                children: [
                  // أيقونة العميل
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        probability.customerName.isNotEmpty
                            ? probability.customerName[0]
                            : '؟',
                        style: TextStyle(
                          color: riskColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          probability.customerName,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          probability.transactionId,
                          style: TextStyle(color: subtextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // شارة مستوى الخطر
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AiReturnPredictionService.getRiskLabel(
                        probability.riskLevel,
                      ),
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // مقياس الاحتمالية
              Row(
                children: [
                  Text(
                    'احتمالية الإرجاع',
                    style: TextStyle(color: subtextColor, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${(probability.probability * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: probability.probability,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(riskColor),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 14),

              // المنتج الأعلى خطراً + المبلغ
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: subtextColor,
                      size: 18,
                    ),
                    const SizedBox(width: AlhaiSpacing.xs),
                    Expanded(
                      child: Text(
                        probability.topRiskProduct,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${probability.amount.toStringAsFixed(2)} ر.س',
                      style: TextStyle(
                        color: riskColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // عوامل الخطر
              if (probability.factors.isNotEmpty) ...[
                const SizedBox(height: AlhaiSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: probability.factors.map((factor) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xs,
                        vertical: AlhaiSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? riskColor.withValues(alpha: 0.1)
                            : riskColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: riskColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getFactorIcon(factor),
                            size: 12,
                            color: riskColor,
                          ),
                          const SizedBox(width: AlhaiSpacing.xxs),
                          Text(
                            AiReturnPredictionService.getFactorLabel(factor),
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFactorIcon(ReturnRiskFactor factor) {
    switch (factor) {
      case ReturnRiskFactor.highPriceItem:
        return Icons.attach_money;
      case ReturnRiskFactor.newCustomer:
        return Icons.person_add_outlined;
      case ReturnRiskFactor.endOfDay:
        return Icons.schedule;
      case ReturnRiskFactor.heavilyDiscounted:
        return Icons.discount_outlined;
      case ReturnRiskFactor.previousReturner:
        return Icons.replay;
      case ReturnRiskFactor.bulkPurchase:
        return Icons.shopping_cart_outlined;
    }
  }
}
