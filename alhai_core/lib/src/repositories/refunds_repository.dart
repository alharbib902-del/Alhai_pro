import '../models/paginated.dart';
import '../models/refund.dart';

/// Repository contract for refund operations (v2.5.0)
/// Referenced by: US-5.1, US-5.2, US-5.3
abstract class RefundsRepository {
  /// Creates a new refund request
  Future<Refund> createRefund({
    required String originalSaleId,
    required String storeId,
    required String cashierId,
    String? customerId,
    required RefundReason reason,
    required RefundMethod method,
    required List<RefundItem> items,
    String? notes,
    String? supervisorId,
  });

  /// Gets a refund by ID
  Future<Refund> getRefund(String id);

  /// Gets paginated refunds for a store
  Future<Paginated<Refund>> getStoreRefunds(
    String storeId, {
    int page = 1,
    int limit = 20,
    RefundStatus? status,
    String? cashierId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Approves a pending refund (supervisor)
  Future<Refund> approveRefund(String refundId, String supervisorId);

  /// Rejects a pending refund (supervisor)
  Future<Refund> rejectRefund(
      String refundId, String supervisorId, String reason);

  /// Completes an approved refund
  Future<Refund> completeRefund(String refundId);

  /// Gets refund summary for reporting
  Future<RefundsSummary> getStoreSummary(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Searches for original sale by receipt number
  Future<OriginalSaleInfo?> findOriginalSale(String receiptNumber);
}

/// Refunds summary for reporting
class RefundsSummary {
  final String storeId;
  final double totalRefundedAmount;
  final int totalRefundCount;
  final int pendingCount;
  final Map<RefundReason, int> byReason;
  final Map<RefundMethod, double> byMethod;

  const RefundsSummary({
    required this.storeId,
    required this.totalRefundedAmount,
    required this.totalRefundCount,
    required this.pendingCount,
    required this.byReason,
    required this.byMethod,
  });
}

/// Original sale info for refund lookup
class OriginalSaleInfo {
  final String saleId;
  final String receiptNumber;
  final DateTime saleDate;
  final double totalAmount;
  final List<RefundableItem> items;
  final double alreadyRefundedAmount;

  const OriginalSaleInfo({
    required this.saleId,
    required this.receiptNumber,
    required this.saleDate,
    required this.totalAmount,
    required this.items,
    required this.alreadyRefundedAmount,
  });

  double get availableForRefund => totalAmount - alreadyRefundedAmount;
  bool get canRefund => availableForRefund > 0;
}

/// Refundable item from original sale
class RefundableItem {
  final String productId;
  final String productName;
  final int originalQuantity;
  final int refundedQuantity;
  final double unitPrice;

  const RefundableItem({
    required this.productId,
    required this.productName,
    required this.originalQuantity,
    required this.refundedQuantity,
    required this.unitPrice,
  });

  int get availableQuantity => originalQuantity - refundedQuantity;
  bool get canRefund => availableQuantity > 0;
}
