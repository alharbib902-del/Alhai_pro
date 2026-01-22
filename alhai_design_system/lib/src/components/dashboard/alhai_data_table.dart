import 'package:flutter/material.dart';

/// Alhai Data Table - Dashboard data table (v1.1.0)
/// Used in: admin_pos, super_admin dashboards
class AlhaiDataTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> data;
  final Widget Function(T item, int columnIndex) cellBuilder;
  final void Function(T item)? onRowTap;
  final bool isLoading;
  final int loadingRowCount;
  final bool showHeader;
  final EdgeInsets? padding;

  const AlhaiDataTable({
    super.key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
    this.onRowTap,
    this.isLoading = false,
    this.loadingRowCount = 5,
    this.showHeader = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            if (showHeader)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: columns.map((col) {
                    return Expanded(
                      child: Text(
                        col,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 8),
            // Body
            if (isLoading)
              ...List.generate(loadingRowCount, (_) => _buildSkeletonRow(context))
            else if (data.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لا توجد بيانات',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...data.map((item) => _buildDataRow(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, T item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onRowTap != null ? () => onRowTap!(item) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: List.generate(columns.length, (index) {
            return Expanded(child: cellBuilder(item, index));
          }),
        ),
      ),
    );
  }

  Widget _buildSkeletonRow(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: columns.map((_) {
          return Expanded(
            child: Container(
              height: 16,
              margin: const EdgeInsets.only(left: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Simple table cell text widget
class AlhaiTableCell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final bool isBold;

  const AlhaiTableCell({
    super.key,
    required this.text,
    this.style,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: style ??
          theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
