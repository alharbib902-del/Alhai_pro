import 'package:alhai_core/alhai_core.dart';

/// خدمة المرتجعات
/// متوافقة مع RefundsRepository من alhai_core
class RefundService {
  final RefundsRepository _refundsRepo;

  RefundService(this._refundsRepo);

  /// إنشاء طلب مرتجع
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
  }) async {
    return await _refundsRepo.createRefund(
      originalSaleId: originalSaleId,
      storeId: storeId,
      cashierId: cashierId,
      customerId: customerId,
      reason: reason,
      method: method,
      items: items,
      notes: notes,
      supervisorId: supervisorId,
    );
  }

  /// الحصول على مرتجع بالـ ID
  Future<Refund> getRefund(String id) async {
    return await _refundsRepo.getRefund(id);
  }

  /// الحصول على قائمة المرتجعات
  Future<Paginated<Refund>> getStoreRefunds(
    String storeId, {
    RefundStatus? status,
    String? cashierId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    return await _refundsRepo.getStoreRefunds(
      storeId,
      status: status,
      cashierId: cashierId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }

  /// الموافقة على المرتجع
  Future<Refund> approveRefund(String refundId, String supervisorId) async {
    return await _refundsRepo.approveRefund(refundId, supervisorId);
  }

  /// رفض المرتجع
  Future<Refund> rejectRefund(
    String refundId,
    String supervisorId,
    String reason,
  ) async {
    return await _refundsRepo.rejectRefund(refundId, supervisorId, reason);
  }

  /// إكمال المرتجع
  Future<Refund> completeRefund(String refundId) async {
    return await _refundsRepo.completeRefund(refundId);
  }

  /// الحصول على ملخص المرتجعات
  Future<RefundsSummary> getStoreSummary(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await _refundsRepo.getStoreSummary(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// البحث عن فاتورة أصلية برقم الإيصال
  Future<OriginalSaleInfo?> findOriginalSale(String receiptNumber) async {
    return await _refundsRepo.findOriginalSale(receiptNumber);
  }

  /// الحصول على المرتجعات المعلقة
  Future<Paginated<Refund>> getPendingRefunds(String storeId) async {
    return await _refundsRepo.getStoreRefunds(
      storeId,
      status: RefundStatus.pending,
    );
  }
}
