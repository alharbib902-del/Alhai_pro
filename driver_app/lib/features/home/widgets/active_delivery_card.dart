import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';

import '../../deliveries/widgets/delivery_status_badge.dart';

class ActiveDeliveryCard extends StatelessWidget {
  final String deliveryId;
  final String status;
  final VoidCallback onTap;

  const ActiveDeliveryCard({
    super.key,
    required this.deliveryId,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: BorderDirectional(
              end: BorderSide(
                color: theme.colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Text(
                    'توصيل نشط',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  DeliveryStatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AlhaiSpacing.sm),
              Row(
                children: [
                  Text(
                    'اضغط لعرض التفاصيل',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
