import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_settings.freezed.dart';
part 'store_settings.g.dart';

/// Store settings domain model (v2.4.0)
@freezed
class StoreSettings with _$StoreSettings {
  const StoreSettings._();

  /// Default currency symbol (Saudi Riyal).
  /// Use this constant instead of hardcoding 'ر.س' throughout the codebase.
  static const String defaultCurrencySymbol = 'ر.س';

  /// Default currency code
  static const String defaultCurrencyCode = 'SAR';

  const factory StoreSettings({
    required String id,
    required String storeId,
    String? receiptHeader,
    String? receiptFooter,
    @Default(15.0) double taxRate,
    @Default(10) int lowStockThreshold,
    @Default(true) bool enableLoyalty,
    @Default(1) int loyaltyPointsPerRial,
    @Default(true) bool autoPrintReceipt,
    @Default('SAR') String currency,
    DateTime? updatedAt,
  }) = _StoreSettings;

  factory StoreSettings.fromJson(Map<String, dynamic> json) =>
      _$StoreSettingsFromJson(json);

  /// Calculate tax amount for a given subtotal
  double calculateTax(double subtotal) => subtotal * (taxRate / 100);

  /// Calculate loyalty points earned for a given amount
  int calculateLoyaltyPoints(double amount) {
    if (!enableLoyalty) return 0;
    return (amount / loyaltyPointsPerRial).floor();
  }

  /// Get currency symbol
  String get currencySymbol {
    switch (currency) {
      case 'SAR':
        return defaultCurrencySymbol;
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'AED':
        return 'د.إ';
      case 'KWD':
        return 'د.ك';
      default:
        return currency;
    }
  }
}
