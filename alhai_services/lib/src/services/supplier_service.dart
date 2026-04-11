import 'package:alhai_core/alhai_core.dart';

/// خدمة الموردين
/// متوافقة مع SuppliersRepository, PurchasesRepository من alhai_core
class SupplierService {
  final SuppliersRepository _suppliersRepo;
  final PurchasesRepository _purchasesRepo;

  SupplierService(this._suppliersRepo, this._purchasesRepo);

  // ==================== الموردين ====================

  /// الحصول على قائمة الموردين
  Future<Paginated<Supplier>> getSuppliers(
    String storeId, {
    bool? activeOnly,
    int page = 1,
    int limit = 20,
  }) async {
    return await _suppliersRepo.getSuppliers(
      storeId,
      activeOnly: activeOnly,
      page: page,
      limit: limit,
    );
  }

  /// الحصول على مورد بالـ ID
  Future<Supplier> getSupplier(String id) async {
    return await _suppliersRepo.getSupplier(id);
  }

  /// إضافة مورد جديد
  Future<Supplier> createSupplier(CreateSupplierParams params) async {
    return await _suppliersRepo.createSupplier(params);
  }

  /// تحديث مورد
  Future<Supplier> updateSupplier(
    String id,
    UpdateSupplierParams params,
  ) async {
    return await _suppliersRepo.updateSupplier(id, params);
  }

  /// حذف مورد
  Future<void> deleteSupplier(String id) async {
    await _suppliersRepo.deleteSupplier(id);
  }

  /// الحصول على الموردين الذين لديهم رصيد
  Future<List<Supplier>> getSuppliersWithBalance(String storeId) async {
    return await _suppliersRepo.getSuppliersWithBalance(storeId);
  }

  // ==================== المشتريات ====================

  /// إنشاء أمر شراء
  Future<PurchaseOrder> createPurchaseOrder(
    CreatePurchaseOrderParams params,
  ) async {
    return await _purchasesRepo.createPurchaseOrder(params);
  }

  /// الحصول على أوامر الشراء
  Future<Paginated<PurchaseOrder>> getPurchaseOrders(
    String storeId, {
    String? supplierId,
    PurchaseOrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    return await _purchasesRepo.getPurchaseOrders(
      storeId,
      supplierId: supplierId,
      status: status,
      page: page,
      limit: limit,
    );
  }

  /// الحصول على أمر شراء بالـ ID
  Future<PurchaseOrder> getPurchaseOrder(String id) async {
    return await _purchasesRepo.getPurchaseOrder(id);
  }

  /// استلام البضاعة
  Future<PurchaseOrder> receiveItems(
    String purchaseId,
    List<ReceivedItem> items,
  ) async {
    return await _purchasesRepo.receiveItems(purchaseId, items);
  }

  /// إلغاء أمر الشراء
  Future<void> cancelPurchaseOrder(String purchaseId, {String? reason}) async {
    await _purchasesRepo.cancelPurchaseOrder(purchaseId, reason: reason);
  }

  /// تسجيل دفعة لأمر الشراء
  Future<PurchaseOrder> recordPayment(String purchaseId, double amount) async {
    return await _purchasesRepo.recordPayment(purchaseId, amount);
  }
}
