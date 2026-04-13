import 'package:flutter/material.dart';

import '../../../core/constants/driver_constants.dart';
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
