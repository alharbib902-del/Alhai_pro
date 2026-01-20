import 'package:flutter/material.dart';

/// Alhai Activity Item - Dashboard activity/notification item (v1.1.0)
/// Used in: admin_pos, super_admin dashboards
class AlhaiActivityItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? time;
  final Widget? leading;
  final AlhaiActivityType type;
  final VoidCallback? onTap;

  const AlhaiActivityItem({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    this.leading,
    this.type = AlhaiActivityType.info,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon or avatar
            leading ??
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    type.icon,
                    size: 20,
                    color: type.color,
                  ),
                ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Time
            if (time != null) ...[
              const SizedBox(width: 8),
              Text(
                time!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Activity type enum
enum AlhaiActivityType {
  info,
  success,
  warning,
  error,
  order,
  payment,
  user,
  product,
}

/// Extension for AlhaiActivityType
extension AlhaiActivityTypeExt on AlhaiActivityType {
  IconData get icon {
    switch (this) {
      case AlhaiActivityType.info:
        return Icons.info_outline;
      case AlhaiActivityType.success:
        return Icons.check_circle_outline;
      case AlhaiActivityType.warning:
        return Icons.warning_amber_outlined;
      case AlhaiActivityType.error:
        return Icons.error_outline;
      case AlhaiActivityType.order:
        return Icons.shopping_bag_outlined;
      case AlhaiActivityType.payment:
        return Icons.payments_outlined;
      case AlhaiActivityType.user:
        return Icons.person_outline;
      case AlhaiActivityType.product:
        return Icons.inventory_2_outlined;
    }
  }

  Color get color {
    switch (this) {
      case AlhaiActivityType.info:
        return Colors.blue;
      case AlhaiActivityType.success:
        return Colors.green;
      case AlhaiActivityType.warning:
        return Colors.orange;
      case AlhaiActivityType.error:
        return Colors.red;
      case AlhaiActivityType.order:
        return Colors.purple;
      case AlhaiActivityType.payment:
        return Colors.teal;
      case AlhaiActivityType.user:
        return Colors.indigo;
      case AlhaiActivityType.product:
        return Colors.brown;
    }
  }
}

/// Activity list card
class AlhaiActivityList extends StatelessWidget {
  final String title;
  final List<AlhaiActivityItem> items;
  final VoidCallback? onViewAll;
  final bool isLoading;

  const AlhaiActivityList({
    super.key,
    required this.title,
    required this.items,
    this.onViewAll,
    this.isLoading = false,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('عرض الكل'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Items
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'لا توجد أنشطة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...items,
        ],
      ),
    );
  }
}
