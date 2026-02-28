import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/promotion.dart';

void main() {
  group('Promotion Model', () {
    Promotion createPromotion({
      String id = 'promo-1',
      PromoType type = PromoType.percentage,
      double value = 10.0,
      double? minOrderAmount,
      double? maxDiscount,
      int? usageLimit,
      int usageCount = 0,
      bool isActive = true,
      DateTime? startDate,
      DateTime? endDate,
    }) {
      return Promotion(
        id: id,
        storeId: 'store-1',
        name: 'Test Promotion',
        code: 'SAVE10',
        type: type,
        value: value,
        minOrderAmount: minOrderAmount,
        maxDiscount: maxDiscount,
        usageLimit: usageLimit,
        usageCount: usageCount,
        startDate: startDate ?? DateTime.now().subtract(const Duration(days: 1)),
        endDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
        isActive: isActive,
        createdAt: DateTime(2026, 1, 15),
      );
    }

    group('isValid', () {
      test('should return true for active promo within date range', () {
        final promo = createPromotion();
        expect(promo.isValid, isTrue);
      });

      test('should return false for inactive promo', () {
        final promo = createPromotion(isActive: false);
        expect(promo.isValid, isFalse);
      });

      test('should return false for expired promo', () {
        final promo = createPromotion(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().subtract(const Duration(days: 1)),
        );
        expect(promo.isValid, isFalse);
      });

      test('should return false for not yet started promo', () {
        final promo = createPromotion(
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 30)),
        );
        expect(promo.isValid, isFalse);
      });

      test('should return false when usage limit exceeded', () {
        final promo = createPromotion(usageLimit: 5, usageCount: 5);
        expect(promo.isValid, isFalse);
      });

      test('should return true when usage is below limit', () {
        final promo = createPromotion(usageLimit: 10, usageCount: 3);
        expect(promo.isValid, isTrue);
      });

      test('should return true when no usage limit set', () {
        final promo = createPromotion(usageLimit: null, usageCount: 100);
        expect(promo.isValid, isTrue);
      });
    });

    group('hasUsageRemaining', () {
      test('should return true when no limit', () {
        final promo = createPromotion(usageLimit: null);
        expect(promo.hasUsageRemaining, isTrue);
      });

      test('should return true when usage is below limit', () {
        final promo = createPromotion(usageLimit: 10, usageCount: 5);
        expect(promo.hasUsageRemaining, isTrue);
      });

      test('should return false when usage equals limit', () {
        final promo = createPromotion(usageLimit: 10, usageCount: 10);
        expect(promo.hasUsageRemaining, isFalse);
      });

      test('should return false when usage exceeds limit', () {
        final promo = createPromotion(usageLimit: 5, usageCount: 8);
        expect(promo.hasUsageRemaining, isFalse);
      });
    });

    group('calculateDiscount', () {
      test('should calculate percentage discount', () {
        final promo = createPromotion(
          type: PromoType.percentage,
          value: 10.0,
        );

        expect(promo.calculateDiscount(200.0), equals(20.0));
      });

      test('should calculate fixed amount discount', () {
        final promo = createPromotion(
          type: PromoType.fixedAmount,
          value: 25.0,
        );

        expect(promo.calculateDiscount(200.0), equals(25.0));
      });

      test('should return 0 for invalid promotion', () {
        final promo = createPromotion(isActive: false);
        expect(promo.calculateDiscount(200.0), equals(0));
      });

      test('should return 0 when order is below minimum', () {
        final promo = createPromotion(
          type: PromoType.percentage,
          value: 10.0,
          minOrderAmount: 100.0,
        );

        expect(promo.calculateDiscount(50.0), equals(0));
      });

      test('should cap discount at maxDiscount', () {
        final promo = createPromotion(
          type: PromoType.percentage,
          value: 50.0,
          maxDiscount: 30.0,
        );

        expect(promo.calculateDiscount(200.0), equals(30.0));
      });

      test('should not cap when discount is below max', () {
        final promo = createPromotion(
          type: PromoType.percentage,
          value: 10.0,
          maxDiscount: 50.0,
        );

        expect(promo.calculateDiscount(200.0), equals(20.0));
      });

      test('should return 0 for buyXGetY type', () {
        final promo = createPromotion(type: PromoType.buyXGetY, value: 1);
        expect(promo.calculateDiscount(200.0), equals(0));
      });
    });

    group('serialization', () {
      test('should create Promotion from JSON', () {
        final json = {
          'id': 'promo-1',
          'storeId': 'store-1',
          'name': 'Test Promo',
          'code': 'SAVE10',
          'type': 'percentage',
          'value': 10.0,
          'minOrderAmount': 50.0,
          'maxDiscount': 30.0,
          'usageLimit': 100,
          'usageCount': 5,
          'startDate': '2026-01-01T00:00:00.000',
          'endDate': '2026-12-31T00:00:00.000',
          'isActive': true,
          'createdAt': '2026-01-01T00:00:00.000',
        };

        final promo = Promotion.fromJson(json);

        expect(promo.id, equals('promo-1'));
        expect(promo.code, equals('SAVE10'));
        expect(promo.type, equals(PromoType.percentage));
        expect(promo.value, equals(10.0));
        expect(promo.usageLimit, equals(100));
        expect(promo.usageCount, equals(5));
      });

      test('should serialize to JSON and back', () {
        final promo = createPromotion(
          minOrderAmount: 50.0,
          maxDiscount: 30.0,
          usageLimit: 100,
        );
        final json = promo.toJson();
        final restored = Promotion.fromJson(json);

        expect(restored.id, equals(promo.id));
        expect(restored.type, equals(promo.type));
        expect(restored.value, equals(promo.value));
        expect(restored.minOrderAmount, equals(50.0));
        expect(restored.maxDiscount, equals(30.0));
      });
    });
  });

  group('PromoType Extensions', () {
    test('displayNameAr should return Arabic names', () {
      expect(PromoType.percentage.displayNameAr, equals('نسبة مئوية'));
      expect(PromoType.fixedAmount.displayNameAr, equals('مبلغ ثابت'));
      expect(PromoType.buyXGetY.displayNameAr, equals('اشتري X واحصل على Y'));
    });

    test('dbValue should return correct database values', () {
      expect(PromoType.percentage.dbValue, equals('percentage'));
      expect(PromoType.fixedAmount.dbValue, equals('fixed_amount'));
      expect(PromoType.buyXGetY.dbValue, equals('buy_x_get_y'));
    });

    test('fromDbValue should parse values correctly', () {
      expect(PromoTypeExt.fromDbValue('percentage'), equals(PromoType.percentage));
      expect(PromoTypeExt.fromDbValue('fixed_amount'), equals(PromoType.fixedAmount));
      expect(PromoTypeExt.fromDbValue('buy_x_get_y'), equals(PromoType.buyXGetY));
      expect(PromoTypeExt.fromDbValue('unknown'), equals(PromoType.percentage));
    });
  });
}
