import 'package:alhai_core/alhai_core.dart';

/// خدمة إعدادات المتجر
/// تستخدم من: cashier, admin_pos
class SettingsService {
  final StoreSettingsRepository _settingsRepo;

  SettingsService(this._settingsRepo);

  /// الحصول على إعدادات المتجر
  Future<StoreSettings?> getSettings(String storeId) async {
    return await _settingsRepo.getSettings(storeId);
  }

  /// الحصول على الإعدادات أو إنشاء افتراضية
  Future<StoreSettings> getOrCreateSettings(String storeId) async {
    return await _settingsRepo.getOrCreateSettings(storeId);
  }

  /// إنشاء إعدادات جديدة
  Future<StoreSettings> createSettings({
    required String storeId,
    String? receiptHeader,
    String? receiptFooter,
    double? taxRate,
    int? lowStockThreshold,
    bool? enableLoyalty,
    int? loyaltyPointsPerRial,
    bool? autoPrintReceipt,
    String? currency,
  }) async {
    return await _settingsRepo.createSettings(
      storeId: storeId,
      receiptHeader: receiptHeader,
      receiptFooter: receiptFooter,
      taxRate: taxRate,
      lowStockThreshold: lowStockThreshold,
      enableLoyalty: enableLoyalty,
      loyaltyPointsPerRial: loyaltyPointsPerRial,
      autoPrintReceipt: autoPrintReceipt,
      currency: currency,
    );
  }

  /// تحديث إعدادات المتجر
  Future<StoreSettings> updateSettings(
    String storeId, {
    String? receiptHeader,
    String? receiptFooter,
    double? taxRate,
    int? lowStockThreshold,
    bool? enableLoyalty,
    int? loyaltyPointsPerRial,
    bool? autoPrintReceipt,
    String? currency,
  }) async {
    return await _settingsRepo.updateSettings(
      storeId,
      receiptHeader: receiptHeader,
      receiptFooter: receiptFooter,
      taxRate: taxRate,
      lowStockThreshold: lowStockThreshold,
      enableLoyalty: enableLoyalty,
      loyaltyPointsPerRial: loyaltyPointsPerRial,
      autoPrintReceipt: autoPrintReceipt,
      currency: currency,
    );
  }

  /// إعادة الإعدادات للافتراضي
  Future<StoreSettings> resetToDefaults(String storeId) async {
    return await _settingsRepo.resetToDefaults(storeId);
  }
}
