import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums/payment_method.dart';

part 'order_payment.freezed.dart';
part 'order_payment.g.dart';

/// Order payment domain model (v2.4.0)
/// Supports split payments - multiple payments per order
@freezed
class OrderPayment with _$OrderPayment {
  const OrderPayment._();

  const factory OrderPayment({
    required String id,
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? referenceNo,
    @Default('completed') String status,
    required DateTime createdAt,
  }) = _OrderPayment;

  factory OrderPayment.fromJson(Map<String, dynamic> json) =>
      _$OrderPaymentFromJson(json);

  /// Check if payment is completed
  bool get isCompleted => status == 'completed';

  /// Check if payment is pending
  bool get isPending => status == 'pending';

  /// Check if payment failed
  bool get isFailed => status == 'failed';

  /// Get status display in Arabic
  String get statusDisplayAr {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'معلق';
      case 'failed':
        return 'فاشل';
      case 'refunded':
        return 'مسترد';
      default:
        return status;
    }
  }
}
