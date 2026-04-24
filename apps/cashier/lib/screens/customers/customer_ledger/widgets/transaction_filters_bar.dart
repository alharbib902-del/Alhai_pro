/// شريط فلاتر الحركات — تاريخ + نوع
///
/// يعتمد على [ledgerFiltersProvider] (StateNotifier) لإدارة الحالة بدل
/// setState. كل chip يبعث update على الـ notifier.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiSpacing;

import '../providers/ledger_filters_notifier.dart';

class TransactionFiltersBar extends ConsumerWidget {
  /// يُستدعى عند طلب المستخدم اختيار مدى تاريخ مخصّص (يعرض picker)
  final Future<void> Function() onSelectCustomDateRange;

  const TransactionFiltersBar({
    super.key,
    required this.onSelectCustomDateRange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final filters = ref.watch(ledgerFiltersProvider);
    final notifier = ref.read(ledgerFiltersProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppSizes.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterGroupHeader(
            l10n.date,
            Icons.calendar_today_outlined,
            colorScheme,
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(
                  l10n.allPeriods,
                  filters.dateFilter == LedgerDateFilter.all,
                  () => notifier.setDateFilter(LedgerDateFilter.all),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.thisMonthPeriod,
                  filters.dateFilter == LedgerDateFilter.thisMonth,
                  () => notifier.setDateFilter(LedgerDateFilter.thisMonth),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.threeMonths,
                  filters.dateFilter == LedgerDateFilter.threeMonths,
                  () => notifier.setDateFilter(LedgerDateFilter.threeMonths),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.dateFromTo,
                  filters.dateFilter == LedgerDateFilter.custom,
                  onSelectCustomDateRange,
                  colorScheme,
                  icon: Icons.date_range_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AlhaiSpacing.md),
          _buildFilterGroupHeader(
            l10n.type,
            Icons.filter_list_rounded,
            colorScheme,
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(
                  l10n.allMovements,
                  filters.typeFilter == LedgerTypeFilter.all,
                  () => notifier.setTypeFilter(LedgerTypeFilter.all),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.invoices,
                  filters.typeFilter == LedgerTypeFilter.invoice,
                  () => notifier.setTypeFilter(LedgerTypeFilter.invoice),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.payment,
                  filters.typeFilter == LedgerTypeFilter.payment,
                  () => notifier.setTypeFilter(LedgerTypeFilter.payment),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.returns,
                  filters.typeFilter == LedgerTypeFilter.returnType,
                  () => notifier.setTypeFilter(LedgerTypeFilter.returnType),
                  colorScheme,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                _buildChip(
                  l10n.adjustments,
                  filters.typeFilter == LedgerTypeFilter.adjustment,
                  () => notifier.setTypeFilter(LedgerTypeFilter.adjustment),
                  colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGroupHeader(
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.outline),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme, {
    IconData? icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AlhaiSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
