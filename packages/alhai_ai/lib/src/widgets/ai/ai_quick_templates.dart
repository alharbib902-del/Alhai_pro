/// القوالب السريعة للمساعد الذكي - AI Quick Templates
///
/// صف أفقي من الرقاقات للاستفسارات السريعة
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_assistant_service.dart';

/// قوالب سريعة للمساعد الذكي
class AiQuickTemplates extends StatelessWidget {
  final List<QuickTemplate> templates;
  final ValueChanged<QuickTemplate> onTap;

  const AiQuickTemplates({
    super.key,
    required this.templates,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'أسئلة سريعة', // Quick questions
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: templates.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AlhaiSpacing.xs),
              itemBuilder: (context, index) {
                final template = templates[index];
                return _buildChip(template, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(QuickTemplate template, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(template),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.primaryBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                template.icon,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                template.titleAr,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
