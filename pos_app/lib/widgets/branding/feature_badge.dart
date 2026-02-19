/// Feature Badge Widget - شعارات المميزات
///
/// شعارات تعرض مميزات التطبيق (سريع، آمن، سحابي)
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// أنواع الشعارات
enum FeatureBadgeType {
  /// سريع جداً
  fast,

  /// آمن ومحمي
  secure,

  /// سحابي
  cloud,

  /// دعم 24/7
  support,

  /// أدوات تحليل
  analytics,

  /// وقت تشغيل
  uptime,
}

/// بيانات الشعار
class FeatureBadgeData {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;

  const FeatureBadgeData({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
  });

  factory FeatureBadgeData.fromType(FeatureBadgeType type) {
    switch (type) {
      case FeatureBadgeType.fast:
        return const FeatureBadgeData(
          icon: Icons.bolt_rounded,
          title: 'سريع جداً',
          subtitle: 'أداء فائق السرعة',
          color: Color(0xFFF59E0B), // Amber
        );
      case FeatureBadgeType.secure:
        return const FeatureBadgeData(
          icon: Icons.shield_rounded,
          title: 'آمن ومحمي',
          subtitle: 'تشفير متقدم',
          color: Color(0xFF8B5CF6), // Purple
        );
      case FeatureBadgeType.cloud:
        return const FeatureBadgeData(
          icon: Icons.cloud_rounded,
          title: 'سحابي',
          subtitle: 'مزامنة فورية',
          color: Color(0xFF06B6D4), // Cyan
        );
      case FeatureBadgeType.support:
        return const FeatureBadgeData(
          icon: Icons.support_agent_rounded,
          title: '24/7',
          subtitle: 'دعم فني',
          color: AppColors.primary,
        );
      case FeatureBadgeType.analytics:
        return const FeatureBadgeData(
          icon: Icons.analytics_rounded,
          title: '+50',
          subtitle: 'أدوات تحليل',
          color: Color(0xFF3B82F6), // Blue
        );
      case FeatureBadgeType.uptime:
        return const FeatureBadgeData(
          icon: Icons.check_circle_rounded,
          title: '99.9%',
          subtitle: 'وقت التشغيل',
          color: AppColors.success,
        );
    }
  }
}

/// شعار ميزة واحدة
class FeatureBadge extends StatelessWidget {
  final FeatureBadgeType? type;
  final FeatureBadgeData? data;
  final bool compact;
  final bool light;

  const FeatureBadge({
    super.key,
    this.type,
    this.data,
    this.compact = false,
    this.light = true,
  }) : assert(type != null || data != null, 'يجب تحديد type أو data');

  @override
  Widget build(BuildContext context) {
    final badgeData = data ?? FeatureBadgeData.fromType(type!);

    if (compact) {
      return _CompactBadge(data: badgeData, light: light);
    }

    return _FullBadge(data: badgeData, light: light);
  }
}

class _CompactBadge extends StatelessWidget {
  final FeatureBadgeData data;
  final bool light;

  const _CompactBadge({required this.data, required this.light});

  @override
  Widget build(BuildContext context) {
    // كشف الداكن من الثيم إذا لم يكن light
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final useWhiteText = light || isDarkMode;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: useWhiteText
            ? Colors.white.withValues(alpha: 0.15)
            : data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: useWhiteText
              ? Colors.white.withValues(alpha: 0.2)
              : data.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            data.icon,
            color: data.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            data.title,
            style: TextStyle(
              color: useWhiteText ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullBadge extends StatelessWidget {
  final FeatureBadgeData data;
  final bool light;

  const _FullBadge({required this.data, required this.light});

  @override
  Widget build(BuildContext context) {
    // كشف الداكن من الثيم إذا لم يكن light
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final useWhiteText = light || isDarkMode;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: useWhiteText
            ? Colors.white.withValues(alpha: 0.1)
            : data.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: useWhiteText
              ? Colors.white.withValues(alpha: 0.15)
              : data.color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // الأيقونة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: useWhiteText
                  ? Colors.white.withValues(alpha: 0.2)
                  : data.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              color: useWhiteText ? Colors.white : data.color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // العنوان
          Text(
            data.title,
            style: TextStyle(
              color: useWhiteText ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          // العنوان الفرعي
          if (data.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              data.subtitle!,
              style: TextStyle(
                color: useWhiteText
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// صف من شعارات المميزات
class FeatureBadgesRow extends StatelessWidget {
  final List<FeatureBadgeType> types;
  final bool compact;
  final bool light;
  final double spacing;
  final MainAxisAlignment alignment;

  const FeatureBadgesRow({
    super.key,
    this.types = const [
      FeatureBadgeType.fast,
      FeatureBadgeType.secure,
      FeatureBadgeType.cloud,
    ],
    this.compact = false,
    this.light = true,
    this.spacing = 12,
    this.alignment = MainAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: WrapAlignment.center,
      children: types
          .map((type) => FeatureBadge(
                type: type,
                compact: compact,
                light: light,
              ))
          .toList(),
    );
  }
}

/// إحصائيات أسفل شاشة اختيار الفرع
class StatsRow extends StatelessWidget {
  final bool light;

  const StatsRow({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          value: '24/7',
          label: 'دعم فني',
          light: light,
        ),
        _Divider(light: light),
        _StatItem(
          value: '+50',
          label: 'أدوات تحليل',
          light: light,
        ),
        _Divider(light: light),
        _StatItem(
          value: '99.9%',
          label: 'وقت التشغيل',
          light: light,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool light;

  const _StatItem({
    required this.value,
    required this.label,
    required this.light,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: light ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: light
                ? Colors.white.withValues(alpha: 0.8)
                : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool light;

  const _Divider({required this.light});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: light
          ? Colors.white.withValues(alpha: 0.2)
          : AppColors.border,
    );
  }
}
