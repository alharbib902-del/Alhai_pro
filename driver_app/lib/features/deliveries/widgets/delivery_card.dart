import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/driver_constants.dart';
import 'delivery_status_badge.dart';

/// Card showing a delivery summary in the list.
class DeliveryCard extends StatelessWidget {
  final Map<String, dynamic> delivery;
  final VoidCallback onTap;

  const DeliveryCard({super.key, required this.delivery, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = delivery['status'] as String? ?? '';
    final address = delivery['delivery_address'] as String? ?? 'عنوان غير محدد';
    final fee = delivery['delivery_fee'];
    final order = delivery['orders'] as Map<String, dynamic>?;
    final orderNumber = order?['order_number'] as String? ?? '';
    final customerName = order?['customer_name'] as String? ?? '';

    // Build a descriptive semantics label for screen readers
    final (statusLabel, _) = _statusLabel(context, status);
    final semanticsLabel = [
      if (orderNumber.isNotEmpty) 'طلب رقم $orderNumber',
      if (customerName.isNotEmpty) 'العميل: $customerName',
      'العنوان: $address',
      'الحالة: $statusLabel',
      if (fee != null) 'الأجر: ${(fee as num).toStringAsFixed(0)} ريال',
    ].join('، ');

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
        ),
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
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: AlhaiSpacing.xxs),
                      Text(customerName, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                ],

                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: AlhaiSpacing.xxs),
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
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns a human-readable status label (same mapping as DeliveryStatusBadge).
  static (String, Color) _statusLabel(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case DeliveryStatus.assigned:
        return ('تم التعيين', cs.tertiary);
      case DeliveryStatus.accepted:
        return ('تم القبول', cs.primary);
      case DeliveryStatus.headingToPickup:
        return ('في الطريق للمتجر', cs.secondary);
      case DeliveryStatus.arrivedAtPickup:
        return ('وصل للمتجر', cs.tertiary);
      case DeliveryStatus.pickedUp:
        return ('تم الاستلام', cs.primary);
      case DeliveryStatus.headingToCustomer:
        return ('في الطريق للعميل', cs.tertiary);
      case DeliveryStatus.arrivedAtCustomer:
        return ('وصل للعميل', cs.tertiary);
      case DeliveryStatus.delivered:
        return ('تم التوصيل', cs.primary);
      case DeliveryStatus.failed:
        return ('فشل', cs.error);
      case DeliveryStatus.cancelled:
        return ('ملغي', cs.outline);
      default:
        return (status, cs.outline);
    }
  }
}
