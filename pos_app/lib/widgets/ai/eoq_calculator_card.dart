/// بطاقة حاسبة EOQ - EOQ Calculator Card
///
/// تعرض نتيجة EOQ مع عرض بصري ومدخلات لمعاملات التكلفة
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_smart_inventory_service.dart';

/// بطاقة حاسبة EOQ
class EoqCalculatorCard extends StatelessWidget {
  final EoqResult result;
  final VoidCallback? onOrderNow;

  const EoqCalculatorCard({
    super.key,
    required this.result,
    this.onOrderNow,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result.category != null)
                      Text(
                        result.category!,
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              // EOQ value
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'EOQ',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${result.eoq}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Key metrics grid
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'نقطة إعادة الطلب', // Reorder Point
                  value: '${result.reorderPoint}',
                  icon: Icons.flag_rounded,
                  color: AppColors.warning,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'مخزون الأمان', // Safety Stock
                  value: '${result.safetyStock}',
                  icon: Icons.shield_rounded,
                  color: AppColors.info,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  label: 'الطلب السنوي', // Annual Demand
                  value: '${result.annualDemand.toInt()}',
                  icon: Icons.show_chart_rounded,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricBox(
                  label: 'التكلفة السنوية', // Annual Cost
                  value: '${result.totalAnnualCost.toInt()} ر.س', // SAR
                  icon: Icons.payments_rounded,
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Cost details
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _CostItem(
                    label: 'تكلفة الطلب', // Order Cost
                    value: '${result.orderCost.toStringAsFixed(1)} ر.س',
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey200,
                ),
                Expanded(
                  child: _CostItem(
                    label: 'تكلفة التخزين', // Holding Cost
                    value: '${result.holdingCost.toStringAsFixed(1)} ر.س',
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Order now button
          if (onOrderNow != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onOrderNow,
                icon: const Icon(Icons.add_shopping_cart_rounded, size: 16),
                label: Text(
                  'طلب ${result.eoq} وحدة', // Order X units
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// صندوق المقياس - Metric Box
class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MetricBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر التكلفة - Cost Item
class _CostItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _CostItem({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
