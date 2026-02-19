/// كارد إحصائيات المرتجعات - Returns Stat Card
///
/// يعرض إحصائية واحدة مع أيقونة، قيمة، وتفاصيل إضافية
/// يدعم الوضع الفاتح والداكن + responsive
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// بيانات الإحصائية
class ReturnsStatData {
  final String title;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? changeLabel;
  final IconData? changeIcon;
  final Color? changeColor;
  final String? badgeText;
  final Color? badgeColor;
  final String? subtitle;
  final double? progressValue;
  final Color? progressColor;
  final String? footerText;

  const ReturnsStatData({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.changeLabel,
    this.changeIcon,
    this.changeColor,
    this.badgeText,
    this.badgeColor,
    this.subtitle,
    this.progressValue,
    this.progressColor,
    this.footerText,
  });
}

/// كارد الإحصائية
class ReturnsStatCard extends StatelessWidget {
  final ReturnsStatData data;
  final bool compact;

  const ReturnsStatCard({
    super.key,
    required this.data,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row + icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: TextStyle(
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.value,
                      style: TextStyle(
                        fontSize: compact ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: compact ? 40 : 48,
                height: compact ? 40 : 48,
                decoration: BoxDecoration(
                  color: isDark ? data.iconBgColor.withValues(alpha: 0.2) : data.iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, size: compact ? 20 : 24, color: data.iconColor),
              ),
            ],
          ),

          if (data.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              data.subtitle!,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMuted,
                fontFamily: data.subtitle!.contains('SKU') ? 'Courier' : null,
              ),
            ),
          ],

          // Progress bar
          if (data.progressValue != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: data.progressValue!,
                minHeight: 6,
                backgroundColor: isDark ? const Color(0xFF374151) : AppColors.grey100,
                valueColor: AlwaysStoppedAnimation(data.progressColor ?? AppColors.primary),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Change label OR badge
          if (data.changeLabel != null)
            Row(
              children: [
                if (data.changeIcon != null) ...[
                  Icon(data.changeIcon!, size: 14, color: data.changeColor ?? AppColors.success),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    data.changeLabel!,
                    style: TextStyle(fontSize: 11, color: data.changeColor ?? AppColors.success),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          if (data.badgeText != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (data.badgeColor ?? AppColors.success).withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 12, color: data.badgeColor ?? AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        data.badgeText!,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: data.badgeColor ?? AppColors.success),
                      ),
                    ],
                  ),
                ),
                if (data.subtitle != null && data.badgeText != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    data.subtitle!,
                    style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
                  ),
                ],
              ],
            ),

          if (data.footerText != null) ...[
            const SizedBox(height: 4),
            Text(
              data.footerText!,
              style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
