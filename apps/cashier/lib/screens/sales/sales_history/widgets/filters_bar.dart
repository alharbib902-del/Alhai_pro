/// Filters bar: search + date chips
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/sales_history_providers.dart';

/// شريط الفلاتر: حقل بحث + شرائح تاريخ.
class SalesHistoryFiltersBar extends ConsumerStatefulWidget {
  const SalesHistoryFiltersBar({super.key});

  @override
  ConsumerState<SalesHistoryFiltersBar> createState() =>
      _SalesHistoryFiltersBarState();
}

class _SalesHistoryFiltersBarState
    extends ConsumerState<SalesHistoryFiltersBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(salesHistoryNotifierProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(salesHistoryNotifierProvider).valueOrNull;
    final filter = state?.dateFilter ?? SalesDateFilter.today;
    final customRange = state?.customRange;

    return Column(
      children: [
        _SearchField(controller: _searchController, isDark: isDark, l10n: l10n),
        const SizedBox(height: AlhaiSpacing.sm),
        _DateFilterChips(
          currentFilter: filter,
          currentRange: customRange,
          isDark: isDark,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.isDark,
    required this.l10n,
  });

  final TextEditingController controller;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: AppColors.getTextPrimary(isDark)),
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        hintStyle: TextStyle(color: AppColors.getTextMuted(isDark)),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: AppColors.getTextMuted(isDark),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              onPressed: controller.clear,
              icon: Icon(
                Icons.clear_rounded,
                color: AppColors.getTextMuted(isDark),
              ),
              tooltip: l10n.clearField,
            );
          },
        ),
        filled: true,
        fillColor: AppColors.getSurface(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorder(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getBorder(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DateFilterChips extends ConsumerWidget {
  const _DateFilterChips({
    required this.currentFilter,
    required this.currentRange,
    required this.isDark,
    required this.l10n,
  });

  final SalesDateFilter currentFilter;
  final DateTimeRange? currentRange;
  final bool isDark;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(salesHistoryNotifierProvider.notifier);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: l10n.today,
            selected: currentFilter == SalesDateFilter.today,
            isDark: isDark,
            onTap: () => notifier.setDateFilter(SalesDateFilter.today),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _FilterChip(
            label: l10n.thisWeek,
            selected: currentFilter == SalesDateFilter.week,
            isDark: isDark,
            onTap: () => notifier.setDateFilter(SalesDateFilter.week),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _FilterChip(
            label: l10n.thisMonthPeriod,
            selected: currentFilter == SalesDateFilter.month,
            isDark: isDark,
            onTap: () => notifier.setDateFilter(SalesDateFilter.month),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _FilterChip(
            label: l10n.allPeriods,
            selected: currentFilter == SalesDateFilter.all,
            isDark: isDark,
            onTap: () => notifier.setDateFilter(SalesDateFilter.all),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          _FilterChip(
            label: l10n.dateFromTo,
            selected: currentFilter == SalesDateFilter.custom,
            isDark: isDark,
            icon: Icons.date_range_outlined,
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: currentRange,
              );
              if (picked != null) {
                await notifier.setCustomRange(picked);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : AppColors.getSurfaceVariant(isDark),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.getBorder(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.getTextSecondary(isDark),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppColors.textOnPrimary
                    : AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
