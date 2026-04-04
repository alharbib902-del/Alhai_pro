/// جداول البيانات - App Data Tables
///
/// جداول بيانات احترافية للويب
library;

import 'adaptive_icon.dart';
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'app_empty_state.dart';

/// جدول بيانات موحد
class AppDataTable<T> extends StatelessWidget {
  /// البيانات
  final List<T> data;

  /// الأعمدة
  final List<AppDataColumn<T>> columns;

  /// عند اختيار صف
  final ValueChanged<T>? onRowTap;

  /// عند الضغط المطول
  final ValueChanged<T>? onRowLongPress;

  /// هل يمكن اختيار الصفوف؟
  final bool selectable;

  /// الصفوف المحددة
  final Set<T>? selectedRows;

  /// عند تغيير التحديد
  final ValueChanged<Set<T>>? onSelectionChanged;

  /// ترتيب حسب العمود
  final int? sortColumnIndex;

  /// ترتيب تصاعدي
  final bool sortAscending;

  /// عند تغيير الترتيب
  final void Function(int columnIndex, bool ascending)? onSort;

  /// رسالة الفراغ
  final Widget? emptyWidget;

  /// جاري التحميل
  final bool isLoading;

  /// ارتفاع الصف
  final double rowHeight;

  /// ارتفاع الهيدر
  final double headerHeight;

  /// Fixed Header
  final bool fixedHeader;

  const AppDataTable({
    super.key,
    required this.data,
    required this.columns,
    this.onRowTap,
    this.onRowLongPress,
    this.selectable = false,
    this.selectedRows,
    this.onSelectionChanged,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.emptyWidget,
    this.isLoading = false,
    this.rowHeight = AppTableSize.rowHeight,
    this.headerHeight = AppTableSize.headerHeight,
    this.fixedHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppLoadingState(
          message: AppLocalizations.of(context)!.loadingData);
    }

    if (data.isEmpty) {
      return emptyWidget ?? AppEmptyState.noData(context);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Divider
          const Divider(height: 1),

          // Body
          Expanded(
            child: ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => _buildRow(data[index], index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: headerHeight,
      decoration: const BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg - 1),
        ),
      ),
      child: Row(
        children: [
          // Checkbox Column
          if (selectable)
            SizedBox(
              width: 56,
              child: Checkbox(
                value: selectedRows?.length == data.length && data.isNotEmpty,
                tristate: true,
                onChanged: (value) {
                  if (value == true) {
                    onSelectionChanged?.call(data.toSet());
                  } else {
                    onSelectionChanged?.call({});
                  }
                },
              ),
            ),

          // Data Columns
          ...columns.asMap().entries.map((entry) {
            final index = entry.key;
            final column = entry.value;
            final isSorted = sortColumnIndex == index;

            return Expanded(
              flex: column.flex,
              child: InkWell(
                onTap: column.sortable && onSort != null
                    ? () => onSort!(index, isSorted ? !sortAscending : true)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTableSize.cellPaddingH,
                  ),
                  alignment: _getAlignment(column.alignment),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        column.title,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (column.sortable) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          isSorted
                              ? (sortAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward)
                              : Icons.unfold_more,
                          size: 16,
                          color: isSorted
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow(T item, int index) {
    final isSelected = selectedRows?.contains(item) ?? false;
    final isEven = index.isEven;

    return Material(
      color: isSelected
          ? AppColors.primarySurface
          : isEven
              ? AppColors.surface
              : AppColors.grey50.withValues(alpha: 0.5),
      child: InkWell(
        onTap: onRowTap != null ? () => onRowTap!(item) : null,
        onLongPress:
            onRowLongPress != null ? () => onRowLongPress!(item) : null,
        child: SizedBox(
          height: rowHeight,
          child: Row(
            children: [
              // Checkbox
              if (selectable)
                SizedBox(
                  width: 56,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      final newSelection = Set<T>.from(selectedRows ?? {});
                      if (value == true) {
                        newSelection.add(item);
                      } else {
                        newSelection.remove(item);
                      }
                      onSelectionChanged?.call(newSelection);
                    },
                  ),
                ),

              // Data Cells
              ...columns.map((column) {
                return Expanded(
                  flex: column.flex,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTableSize.cellPaddingH,
                    ),
                    alignment: _getAlignment(column.alignment),
                    child: column.builder(item),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  AlignmentGeometry _getAlignment(ColumnAlignment alignment) {
    switch (alignment) {
      case ColumnAlignment.start:
        return AlignmentDirectional.centerEnd;
      case ColumnAlignment.center:
        return Alignment.center;
      case ColumnAlignment.end:
        return AlignmentDirectional.centerStart;
    }
  }
}

/// تعريف عمود الجدول
class AppDataColumn<T> {
  /// عنوان العمود
  final String title;

  /// بناء الخلية
  final Widget Function(T item) builder;

  /// العرض النسبي
  final int flex;

  /// قابل للترتيب
  final bool sortable;

  /// المحاذاة
  final ColumnAlignment alignment;

  const AppDataColumn({
    required this.title,
    required this.builder,
    this.flex = 1,
    this.sortable = false,
    this.alignment = ColumnAlignment.start,
  });
}

/// محاذاة العمود
enum ColumnAlignment { start, center, end }

/// Pagination Widget
class AppPagination extends StatelessWidget {
  /// الصفحة الحالية (تبدأ من 1)
  final int currentPage;

  /// إجمالي الصفحات
  final int totalPages;

  /// عند تغيير الصفحة
  final ValueChanged<int> onPageChanged;

  /// عدد العناصر في الصفحة
  final int pageSize;

  /// خيارات عدد العناصر
  final List<int> pageSizeOptions;

  /// عند تغيير عدد العناصر
  final ValueChanged<int>? onPageSizeChanged;

  /// إجمالي العناصر
  final int? totalItems;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.pageSize = 10,
    this.pageSizeOptions = const [10, 25, 50, 100],
    this.onPageSizeChanged,
    this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Page Size Selector
          if (onPageSizeChanged != null) ...[
            Text(
              l10n.display,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: pageSize,
                  items: pageSizeOptions.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text('$size'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onPageSizeChanged!(value);
                    }
                  },
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.item,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],

          const Spacer(),

          // Items Info
          if (totalItems != null)
            Text(
              _getItemsInfo(),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

          const SizedBox(width: AppSpacing.lg),

          // Navigation Buttons
          Row(
            children: [
              // First Page
              IconButton(
                onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
                icon: const AdaptiveIcon(Icons.first_page),
                iconSize: 20,
                tooltip: 'الصفحة الأولى',
              ),

              // Previous Page
              IconButton(
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
                icon: const AdaptiveIcon(Icons.chevron_right),
                iconSize: 20,
                tooltip: 'الصفحة السابقة',
              ),

              // Page Numbers
              ..._buildPageNumbers(),

              // Next Page
              IconButton(
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
                icon: const AdaptiveIcon(Icons.chevron_left),
                iconSize: 20,
                tooltip: 'الصفحة التالية',
              ),

              // Last Page
              IconButton(
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(totalPages)
                    : null,
                icon: const AdaptiveIcon(Icons.last_page),
                iconSize: 20,
                tooltip: 'الصفحة الأخيرة',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getItemsInfo() {
    final start = (currentPage - 1) * pageSize + 1;
    final end = (start + pageSize - 1).clamp(1, totalItems!);
    return '$start-$end من $totalItems';
  }

  List<Widget> _buildPageNumbers() {
    final pages = <Widget>[];
    const maxVisible = 5;

    int startPage = (currentPage - maxVisible ~/ 2).clamp(1, totalPages);
    int endPage = (startPage + maxVisible - 1).clamp(1, totalPages);

    if (endPage - startPage < maxVisible - 1) {
      startPage = (endPage - maxVisible + 1).clamp(1, totalPages);
    }

    for (int i = startPage; i <= endPage; i++) {
      pages.add(
        InkWell(
          onTap: i != currentPage ? () => onPageChanged(i) : null,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i == currentPage ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              '$i',
              style: AppTypography.labelMedium.copyWith(
                color:
                    i == currentPage ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return pages;
  }
}
