import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/store_settings.dart';

void main() {
  group('StoreSettings Model', () {
    StoreSettings createSettings({
      String id = 'settings-1',
      double taxRate = 15.0,
      int lowStockThreshold = 10,
      bool enableLoyalty = true,
      int loyaltyPointsPerRial = 1,
      bool autoPrintReceipt = true,
      String currency = 'SAR',
    }) {
      return StoreSettings(
        id: id,
        storeId: 'store-1',
        taxRate: taxRate,
        lowStockThreshold: lowStockThreshold,
        enableLoyalty: enableLoyalty,
        loyaltyPointsPerRial: loyaltyPointsPerRial,
        autoPrintReceipt: autoPrintReceipt,
        currency: currency,
      );
    }

    group('calculateTax', () {
      test('should calculate 15% tax correctly', () {
        final settings = createSettings(taxRate: 15.0);
        expect(settings.calculateTax(100.0), closeTo(15.0, 0.001));
      });

      test('should calculate 0% tax', () {
        final settings = createSettings(taxRate: 0);
        expect(settings.calculateTax(100.0), equals(0));
      });

      test('should calculate tax for large amounts', () {
        final settings = createSettings(taxRate: 15.0);
        expect(settings.calculateTax(1000.0), closeTo(150.0, 0.001));
      });

      test('should return 0 for 0 subtotal', () {
        final settings = createSettings(taxRate: 15.0);
        expect(settings.calculateTax(0), equals(0));
      });
    });

    group('calculateLoyaltyPoints', () {
      test('should calculate points with 1 point per rial', () {
        final settings = createSettings(loyaltyPointsPerRial: 1);
        expect(settings.calculateLoyaltyPoints(100.0), equals(100));
      });

      test('should calculate points with 2 points per rial', () {
        final settings = createSettings(loyaltyPointsPerRial: 2);
        expect(settings.calculateLoyaltyPoints(100.0), equals(50));
      });

      test('should return 0 when loyalty disabled', () {
        final settings = createSettings(enableLoyalty: false);
        expect(settings.calculateLoyaltyPoints(100.0), equals(0));
      });

      test('should floor decimal points', () {
        final settings = createSettings(loyaltyPointsPerRial: 3);
        expect(settings.calculateLoyaltyPoints(10.0), equals(3));
      });
    });

    group('currencySymbol', () {
      test('should return SAR symbol', () {
        final settings = createSettings(currency: 'SAR');
        expect(settings.currencySymbol, equals('ر.س'));
      });

      test('should return USD symbol', () {
        final settings = createSettings(currency: 'USD');
        expect(settings.currencySymbol, equals('\$'));
      });

      test('should return EUR symbol', () {
        final settings = createSettings(currency: 'EUR');
        expect(settings.currencySymbol, equals('€'));
      });

      test('should return AED symbol', () {
        final settings = createSettings(currency: 'AED');
        expect(settings.currencySymbol, equals('د.إ'));
      });

      test('should return KWD symbol', () {
        final settings = createSettings(currency: 'KWD');
        expect(settings.currencySymbol, equals('د.ك'));
      });

      test('should return raw currency for unknown', () {
        final settings = createSettings(currency: 'GBP');
        expect(settings.currencySymbol, equals('GBP'));
      });
    });

    group('serialization', () {
      test('should create StoreSettings from JSON', () {
        final json = {
          'id': 'settings-1',
          'storeId': 'store-1',
          'receiptHeader': 'Welcome!',
          'receiptFooter': 'Thank you!',
          'taxRate': 15.0,
          'lowStockThreshold': 10,
          'enableLoyalty': true,
          'loyaltyPointsPerRial': 1,
          'autoPrintReceipt': true,
          'currency': 'SAR',
        };

        final settings = StoreSettings.fromJson(json);

        expect(settings.id, equals('settings-1'));
        expect(settings.receiptHeader, equals('Welcome!'));
        expect(settings.taxRate, equals(15.0));
        expect(settings.enableLoyalty, isTrue);
      });

      test('should use defaults for missing optional fields', () {
        final json = {
          'id': 'settings-1',
          'storeId': 'store-1',
        };

        final settings = StoreSettings.fromJson(json);

        expect(settings.taxRate, equals(15.0));
        expect(settings.lowStockThreshold, equals(10));
        expect(settings.enableLoyalty, isTrue);
        expect(settings.loyaltyPointsPerRial, equals(1));
        expect(settings.autoPrintReceipt, isTrue);
        expect(settings.currency, equals('SAR'));
      });

      test('should serialize to JSON and back', () {
        final settings = createSettings(
          taxRate: 5.0,
          currency: 'AED',
        );
        final json = settings.toJson();
        final restored = StoreSettings.fromJson(json);

        expect(restored.taxRate, equals(5.0));
        expect(restored.currency, equals('AED'));
      });
    });
  });
}
