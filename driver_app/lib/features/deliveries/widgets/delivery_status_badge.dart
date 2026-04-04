import 'package:flutter/material.dart';

import '../../../shared/widgets/status_badge.dart';

/// Color-coded status badge for delivery status.
/// Wraps the badge in [AnimatedSwitcher] so status changes animate smoothly.
class DeliveryStatusBadge extends StatelessWidget {
  final String status;

  const DeliveryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusInfo(context, status);
    return Semantics(
      label: 'حالة الطلب: $label',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: StatusBadge(
          key: ValueKey(status),
          label: label,
          backgroundColor: color,
          textColor: color,
        ),
      ),
    );
  }

  static (String, Color) _statusInfo(BuildContext context, String status) {
    final cs = Theme.of(context).colorScheme;
    switch (status) {
      case 'assigned':
        return ('تم التعيين', cs.tertiary);
      case 'accepted':
        return ('تم القبول', cs.primary);
      case 'heading_to_pickup':
        return ('في الطريق للمتجر', cs.secondary);
      case 'arrived_at_pickup':
        return ('وصل للمتجر', cs.tertiary);
      case 'picked_up':
        return ('تم الاستلام', cs.primary);
      case 'heading_to_customer':
        return ('في الطريق للعميل', cs.tertiary);
      case 'arrived_at_customer':
        return ('وصل للعميل', cs.tertiary);
      case 'delivered':
        return ('تم التوصيل', cs.primary);
      case 'failed':
        return ('فشل', cs.error);
      case 'cancelled':
        return ('ملغي', cs.outline);
      default:
        return (status, cs.outline);
    }
  }
}
