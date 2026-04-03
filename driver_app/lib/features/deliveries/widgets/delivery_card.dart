import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';

import 'delivery_status_badge.dart';

/// Card showing a delivery summary in the list.
class DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;
  final VoidCallback onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = delivery['status'] as String? ?? '';
    final address = delivery['delivery_address'] as String? ?? 'عنوان غير محدد';
    final fee = delivery['delivery_fee'];
    final order = delivery['orders'] as Map<String, dynamic>?;
    final orderNumber = order?['order_number'] as String? ?? '';
    final customerName = order?['customer_name'] as String? ?? '';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: order number + status badge
              Row(
                children: [
                  if (orderNumber.isNotEmpty)
                    Text(
                      '#$orderNumber',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const Spacer(),
                  DeliveryStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.xs),

              // Customer name
              if (customerName.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: theme.colorScheme.outline),
                    const SizedBox(width: AlhaiSpacing.xxs),
                    Text(
                      customerName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AlhaiSpacing.xxs),
              ],

              // Address
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: theme.colorScheme.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (fee != null) ...[
                    const SizedBox(width: AlhaiSpacing.xs),
                    Text(
                      '${(fee as num).toStringAsFixed(0)} ر.س',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
