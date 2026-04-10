import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakePromotionsRepo implements PromotionsRepository {
  @override Future<List<Promotion>> getActivePromotions(String storeId) async => [];
  @override Future<Paginated<Promotion>> getPromotions(String storeId, {bool? activeOnly, int page = 1, int limit = 20}) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override Future<Promotion> getPromotion(String id) async => throw UnimplementedError();
  @override Future<Promotion?> getByCode(String storeId, String code) async => null;
  @override Future<Promotion> createPromotion({required String storeId, required String name, String? code, required PromoType type, required double value, double? minOrderAmount, double? maxDiscount, int? usageLimit, required DateTime startDate, required DateTime endDate}) async =>
      Promotion(id: 'promo-1', storeId: storeId, name: name, code: code, type: type, value: value, startDate: startDate, endDate: endDate, createdAt: DateTime.now());
  @override Future<Promotion> updatePromotion(String id, {String? name, String? code, PromoType? type, double? value, double? minOrderAmount, double? maxDiscount, int? usageLimit, DateTime? startDate, DateTime? endDate, bool? isActive}) async => throw UnimplementedError();
  @override Future<void> deletePromotion(String id) async {}
  @override Future<Promotion?> validateCode(String storeId, String code, double orderTotal) async => null;
  @override Future<void> incrementUsage(String promotionId) async {}
}

void main() {
  late PromotionService promotionService;
  setUp(() { promotionService = PromotionService(FakePromotionsRepo()); });

  group('PromotionService', () {
    test('should be created', () { expect(promotionService, isNotNull); });

    test('createPromotion should create a promotion', () async {
      final promo = await promotionService.createPromotion(
        storeId: 'store-1', name: 'Summer Sale', code: 'SUMMER',
        type: PromoType.percentage, value: 10.0,
        startDate: DateTime(2026, 6, 1), endDate: DateTime(2026, 8, 31),
      );
      expect(promo.name, equals('Summer Sale'));
      expect(promo.isActive, isTrue);
    });

    test('getActivePromotions should return list', () async {
      final promos = await promotionService.getActivePromotions('store-1');
      expect(promos, isA<List<Promotion>>());
    });

    test('getPromotionByCode should return null for unknown', () async {
      expect(await promotionService.getPromotionByCode('store-1', 'NOEXIST'), isNull);
    });

    test('deletePromotion should not throw', () async {
      await promotionService.deletePromotion('p1');
    });

    test('incrementUsage should not throw', () async {
      await promotionService.incrementUsage('p1');
    });

    test('validatePromoCode should return null for invalid', () async {
      expect(await promotionService.validatePromoCode('s1', 'BAD', 100), isNull);
    });
  });
}
