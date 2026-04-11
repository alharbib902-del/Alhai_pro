import 'package:alhai_core/alhai_core.dart';

/// خدمة نقل المخزون بين الفروع
/// تستخدم من: cashier, admin_pos
class TransferService {
  final TransfersRepository _transfersRepo;

  TransferService(this._transfersRepo);

  /// الحصول على تحويل بالـ ID
  Future<Transfer> getTransfer(String id) async {
    return await _transfersRepo.getTransfer(id);
  }

  /// الحصول على تحويلات المتجر
  Future<Paginated<Transfer>> getStoreTransfers(
    String storeId, {
    int page = 1,
    int limit = 20,
    TransferStatus? status,
    TransferDirection? direction,
  }) async {
    return await _transfersRepo.getStoreTransfers(
      storeId,
      page: page,
      limit: limit,
      status: status,
      direction: direction,
    );
  }

  /// إنشاء طلب تحويل جديد
  Future<Transfer> createTransfer({
    required String sourceStoreId,
    required String destinationStoreId,
    required List<TransferItem> items,
    String? notes,
  }) async {
    return await _transfersRepo.createTransfer(
      sourceStoreId: sourceStoreId,
      destinationStoreId: destinationStoreId,
      items: items,
      notes: notes,
    );
  }

  /// الموافقة على التحويل (المتجر المستلم)
  Future<Transfer> approveTransfer(String id, String approvedBy) async {
    return await _transfersRepo.approveTransfer(id, approvedBy);
  }

  /// رفض التحويل
  Future<Transfer> rejectTransfer(
    String id,
    String rejectedBy,
    String reason,
  ) async {
    return await _transfersRepo.rejectTransfer(id, rejectedBy, reason);
  }

  /// تحديد التحويل كمشحون
  Future<Transfer> shipTransfer(String id) async {
    return await _transfersRepo.shipTransfer(id);
  }

  /// إتمام التحويل (تم الاستلام)
  Future<Transfer> completeTransfer(String id, String receivedBy) async {
    return await _transfersRepo.completeTransfer(id, receivedBy);
  }

  /// إلغاء التحويل
  Future<Transfer> cancelTransfer(String id, String reason) async {
    return await _transfersRepo.cancelTransfer(id, reason);
  }
}
