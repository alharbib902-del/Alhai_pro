import '../models/order_payment.dart';
import '../models/enums/payment_method.dart';

/// Repository contract for order payment operations (v2.4.0)
/// Supports split payments - multiple payments per order
abstract class OrderPaymentsRepository {
  /// Gets all payments for an order
  Future<List<OrderPayment>> getOrderPayments(String orderId);

  /// Gets total paid amount for an order
  Future<double> getTotalPaid(String orderId);

  /// Gets remaining balance for an order
  Future<double> getRemainingBalance(String orderId, double orderTotal);

  /// Adds a payment to an order
  Future<OrderPayment> addPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
    String? referenceNo,
  });

  /// Gets payment by ID
  Future<OrderPayment> getPayment(String id);

  /// Gets payments by method for reporting
  Future<List<OrderPayment>> getPaymentsByMethod(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
    PaymentMethod? method,
  });
}
