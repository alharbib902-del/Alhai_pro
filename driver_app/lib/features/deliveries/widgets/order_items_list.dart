import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';

/// Displays order items in a list.
class OrderItemsList extends StatelessWidget {
  final List<dynamic> items;

  const OrderItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Text(
            'لا توجد عناصر',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'عناصر الطلب',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length} عنصر',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            Divider(color: theme.colorScheme.outlineVariant),
            for (final item in items) _buildItem(context, item),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, dynamic item) {
    final theme = Theme.of(context);
    final data = item as Map<String, dynamic>;
    final name = data['product_name'] as String? ?? 'منتج';
    final qty = data['quantity'] ?? data['qty'] ?? 1;
    final notes = data['notes'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AlhaiRadius.xs),
            ),
            child: Text(
              'x$qty',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.bodyMedium),
                if (notes != null && notes.isNotEmpty)
                  Text(
                    notes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
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
