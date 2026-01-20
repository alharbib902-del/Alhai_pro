import '../models/store_settings.dart';

/// Repository contract for store settings operations (v2.4.0)
abstract class StoreSettingsRepository {
  /// Gets settings for a store
  Future<StoreSettings?> getSettings(String storeId);

  /// Gets settings or creates default if not exists
  Future<StoreSettings> getOrCreateSettings(String storeId);

  /// Creates settings for a store
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
  });

  /// Updates store settings
  Future<StoreSettings> updateSettings(String storeId, {
    String? receiptHeader,
    String? receiptFooter,
    double? taxRate,
    int? lowStockThreshold,
    bool? enableLoyalty,
    int? loyaltyPointsPerRial,
    bool? autoPrintReceipt,
    String? currency,
  });

  /// Resets settings to defaults
  Future<StoreSettings> resetToDefaults(String storeId);
}
