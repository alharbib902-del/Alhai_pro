/// لوحة تكوين اختبار A/B
///
/// تعرض مقارنة جنب إلى جنب بين عرضين ترويجيين
/// مع إعدادات مدة الاختبار ونسبة مجموعة التحكم
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_promotion_designer_service.dart';

/// لوحة اختبار A/B
class AbTestConfigPanel extends StatelessWidget {
  final GeneratedPromotion? promotionA;
  final GeneratedPromotion? promotionB;
  final int testDurationDays;
  final double controlGroupPercent;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<double> onControlPercentChanged;
  final VoidCallback? onLaunch;
  final List<GeneratedPromotion> availablePromotions;
  final ValueChanged<GeneratedPromotion>? onSelectA;
  final ValueChanged<GeneratedPromotion>? onSelectB;

  const AbTestConfigPanel({
    super.key,
    this.promotionA,
    this.promotionB,
    required this.testDurationDays,
    required this.controlGroupPercent,
    required this.onDurationChanged,
    required this.onControlPercentChanged,
    this.onLaunch,
    required this.availablePromotions,
    this.onSelectA,
    this.onSelectB,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.border,
        ),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.science_outlined,
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
                      'اختبار A/B',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'قارن بين عرضين لتحديد الأفضل',
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // المقارنة بين A و B
          Row(
            children: [
              Expanded(
                child: _buildPromotionSlot(
                  context,
                  isDark,
                  'العرض A',
                  promotionA,
                  const Color(0xFF3B82F6),
                  availablePromotions,
                  onSelectA,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.grey100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        'VS',
                        style: TextStyle(
                          color: subtextColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildPromotionSlot(
                  context,
                  isDark,
                  'العرض B',
                  promotionB,
                  const Color(0xFFEF4444),
                  availablePromotions,
                  onSelectB,
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.lg),

          // مدة الاختبار
          Text(
            'مدة الاختبار: $testDurationDays يوم',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF8B5CF6),
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
              thumbColor: const Color(0xFF8B5CF6),
              overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: testDurationDays.toDouble(),
              min: 3,
              max: 30,
              divisions: 27,
              label: '$testDurationDays يوم',
              onChanged: (v) => onDurationChanged(v.round()),
            ),
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // نسبة مجموعة التحكم
          Text(
            'مجموعة التحكم: ${controlGroupPercent.toStringAsFixed(0)}%',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.warning,
              inactiveTrackColor: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.grey200,
              thumbColor: AppColors.warning,
              overlayColor: AppColors.warning.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: controlGroupPercent,
              min: 5,
              max: 50,
              divisions: 9,
              label: '${controlGroupPercent.toStringAsFixed(0)}%',
              onChanged: onControlPercentChanged,
            ),
          ),

          const SizedBox(height: AlhaiSpacing.xs),

          // توزيع المجموعات
          Container(
            padding: const EdgeInsets.all(AlhaiSpacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _buildGroupIndicator(
                  'A',
                  ((100 - controlGroupPercent) / 2),
                  const Color(0xFF3B82F6),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildGroupIndicator(
                  'B',
                  ((100 - controlGroupPercent) / 2),
                  const Color(0xFFEF4444),
                  isDark,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildGroupIndicator(
                  l10n.control,
                  controlGroupPercent,
                  AppColors.warning,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.mdl),

          // زر الإطلاق
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  (promotionA != null && promotionB != null) ? onLaunch : null,
              icon: const Icon(Icons.rocket_launch, size: 18),
              label: const Text('إطلاق اختبار A/B'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.grey200,
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

  Widget _buildPromotionSlot(
    BuildContext context,
    bool isDark,
    String label,
    GeneratedPromotion? promotion,
    Color color,
    List<GeneratedPromotion> options,
    ValueChanged<GeneratedPromotion>? onSelect,
  ) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        if (options.isEmpty || onSelect == null) return;
        showModalBottomSheet(
          context: context,
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) =>
              _buildPromotionPicker(ctx, isDark, options, onSelect),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.sm),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.08)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            style: promotion == null ? BorderStyle.none : BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.xs, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            if (promotion != null) ...[
              Text(
                promotion.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                'ROI: ${promotion.roi.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              Icon(
                Icons.add_circle_outline,
                color: subtextColor,
                size: 28,
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                'اختر عرضاً',
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionPicker(
    BuildContext context,
    bool isDark,
    List<GeneratedPromotion> options,
    ValueChanged<GeneratedPromotion> onSelect,
  ) {
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر عرضاً ترويجياً',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: options.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AlhaiSpacing.xs),
              itemBuilder: (ctx, i) {
                final promo = options[i];
                final typeColor = Color(
                  AiPromotionDesignerService.getPromotionTypeColorValue(
                      promo.type),
                );
                return ListTile(
                  onTap: () {
                    onSelect(promo);
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : AppColors.grey50,
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        AiPromotionDesignerService.getPromotionTypeEmoji(
                            promo.type),
                        style: TextStyle(
                          color: typeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    promo.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'ROI: ${promo.roi.toStringAsFixed(0)}%',
                    style: TextStyle(color: subtextColor, fontSize: 11),
                  ),
                  trailing: Icon(
                    Icons.chevron_left,
                    color: subtextColor,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupIndicator(
      String label, double percent, Color color, bool isDark) {
    return Expanded(
      flex: percent.round().clamp(1, 100),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(0)}%',
              style: TextStyle(
                color: isDark ? Colors.white54 : AppColors.textMuted,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
