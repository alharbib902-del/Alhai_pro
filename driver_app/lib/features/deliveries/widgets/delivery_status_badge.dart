import 'package:flutter/material.dart';

/// Color-coded status badge for delivery status.
class DeliveryStatusBadge extends StatelessWidget {
  final String status;

  const DeliveryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = _statusInfo(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static (String, Color) _statusInfo(String status) {
    switch (status) {
      case 'assigned':
        return ('تم التعيين', Colors.orange);
      case 'accepted':
        return ('تم القبول', Colors.blue);
      case 'heading_to_pickup':
        return ('في الطريق للمتجر', Colors.indigo);
      case 'arrived_at_pickup':
        return ('وصل للمتجر', Colors.purple);
      case 'picked_up':
        return ('تم الاستلام', Colors.teal);
      case 'heading_to_customer':
        return ('في الطريق للعميل', Colors.deepOrange);
      case 'arrived_at_customer':
        return ('وصل للعميل', Colors.amber.shade700);
      case 'delivered':
        return ('تم التوصيل', Colors.green);
      case 'failed':
        return ('فشل', Colors.red);
      case 'cancelled':
        return ('ملغي', Colors.grey);
      default:
        return (status, Colors.grey);
    }
  }
}
