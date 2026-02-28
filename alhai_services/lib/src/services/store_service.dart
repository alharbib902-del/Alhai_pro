import 'package:alhai_core/alhai_core.dart';

/// خدمة إدارة المتاجر
/// تستخدم من: cashier, admin_pos, customer_app
class StoreService {
  final StoresRepository _storesRepo;

  StoreService(this._storesRepo);

  /// الحصول على متجر بالـ ID
  Future<Store> getStore(String id) async {
    return await _storesRepo.getStore(id);
  }

  /// الحصول على المتجر الحالي للمستخدم
  Future<Store?> getCurrentStore() async {
    return await _storesRepo.getCurrentStore();
  }

  /// الحصول على جميع المتاجر (للأدمن)
  Future<List<Store>> getStores() async {
    return await _storesRepo.getStores();
  }

  /// الحصول على المتاجر القريبة
  Future<List<Store>> getNearbyStores({
    required double lat,
    required double lng,
    double radiusKm = 10,
  }) async {
    return await _storesRepo.getNearbyStores(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
    );
  }

  /// تحديث بيانات المتجر
  Future<Store> updateStore(String id, UpdateStoreParams params) async {
    return await _storesRepo.updateStore(id, params);
  }

  /// التحقق من أن المتجر مفتوح
  Future<bool> isStoreOpen(String storeId) async {
    return await _storesRepo.isStoreOpen(storeId);
  }
}
