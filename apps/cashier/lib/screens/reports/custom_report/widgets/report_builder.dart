/// بطاقة "إعدادات التقرير": اختيار نوع التقرير + طريقة التجميع
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/report_config_notifier.dart';

/// خيار نوع تقرير (بيانات بحتة للرسم)
class _ReportTypeOption {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const _ReportTypeOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class ReportBuilderCard extends ConsumerWidget {
  final bool isDark;

  const ReportBuilderCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(reportConfigProvider);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.mdl),
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AlhaiSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Text(
                l10n.reportSettings,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.getTextPrimary(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Report type
          Text(
            l10n.reportType,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 10),
          _ReportTypeSelector(
            selected: config.reportType,
            isDark: isDark,
            onSelect: (k) =>
                ref.read(reportConfigProvider.notifier).setReportType(k),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          // Group by
          Text(
            l10n.groupBy,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextSecondary(isDark),
            ),
          ),
          const SizedBox(height: 10),
          _GroupBySelector(
            selected: config.groupBy,
            isDark: isDark,
            onSelect: (k) =>
                ref.read(reportConfigProvider.notifier).setGroupBy(k),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _ReportTypeSelector({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final types = <_ReportTypeOption>[
      _ReportTypeOption(
        key: 'sales',
        label: l10n.sales,
        icon: Icons.point_of_sale_rounded,
        color: AppColors.primary,
      ),
      _ReportTypeOption(
        key: 'inventory',
        label: l10n.inventory,
        icon: Icons.inventory_2_rounded,
        color: AppColors.purple,
      ),
      _ReportTypeOption(
        key: 'customers',
        label: l10n.customers,
        icon: Icons.people_rounded,
        color: AppColors.secondary,
      ),
      _ReportTypeOption(
        key: 'payments',
        label: l10n.payments,
        icon: Icons.payment_rounded,
        color: AppColors.success,
      ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final isSelected = selected == type.key;
        return InkWell(
          onTap: () => onSelect(type.key),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: AlhaiSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? type.color.withValues(alpha: isDark ? 0.2 : 0.1)
                  : AppColors.getSurfaceVariant(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? type.color : AppColors.getBorder(isDark),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected
                      ? type.color
                      : AppColors.getTextSecondary(isDark),
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? type.color
                        : AppColors.getTextSecondary(isDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GroupBySelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onSelect;

  const _GroupBySelector({
    required this.selected,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final options = [
      ('day', l10n.daily, Icons.today_rounded),
      ('week', l10n.weekly, Icons.view_week_rounded),
      ('month', l10n.monthly, Icons.calendar_month_rounded),
    ];

    return Row(
      children: options.map((option) {
        final isSelected = selected == option.$1;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: option.$1 != 'month' ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => onSelect(option.$1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.getSurfaceVariant(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.getBorder(isDark),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.$3,
                      size: 16,
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.getTextSecondary(isDark),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option.$2,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.textOnPrimary
                            : AppColors.getTextSecondary(isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
