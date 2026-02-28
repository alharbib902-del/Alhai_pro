import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_smart_inventory_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiSmartInventoryService service;
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = createMockDatabase();
    service = AiSmartInventoryService(mockDb);
  });

  group('AbcCategory', () {
    test('has all values', () {
      expect(AbcCategory.values.length, 3);
      expect(AbcCategory.a, isNotNull);
      expect(AbcCategory.b, isNotNull);
      expect(AbcCategory.c, isNotNull);
    });
  });

  group('UrgencyLevel', () {
    test('has all values', () {
      expect(UrgencyLevel.values.length, 4);
    });
  });

  group('WasteSuggestedAction', () {
    test('has all values', () {
      expect(WasteSuggestedAction.values.length, 4);
    });
  });

  group('calculateEoq', () {
    test('returns list of EOQ results', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final results = await service.calculateEoq('store-1');

      expect(results, isNotEmpty);
      expect(results.length, 6);

      for (final r in results) {
        expect(r.productId, isNotEmpty);
        expect(r.name, isNotEmpty);
        expect(r.eoq, greaterThan(0));
        expect(r.reorderPoint, greaterThan(0));
        expect(r.safetyStock, greaterThan(0));
        expect(r.annualDemand, greaterThan(0));
      }
    });

    test('EOQ results have consistent data', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final results = await service.calculateEoq('store-1');

      for (final r in results) {
        // Safety stock should be less than reorder point
        expect(r.safetyStock, lessThan(r.reorderPoint));
        // Total annual cost should be positive
        expect(r.totalAnnualCost, greaterThan(0));
      }
    });
  });

  group('getAbcAnalysis', () {
    test('returns ABC items with correct categories', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final items = await service.getAbcAnalysis('store-1');

      expect(items, isNotEmpty);
      expect(items.length, 12);

      final aItems = items.where((i) => i.category == AbcCategory.a).toList();
      final bItems = items.where((i) => i.category == AbcCategory.b).toList();
      final cItems = items.where((i) => i.category == AbcCategory.c).toList();

      expect(aItems, isNotEmpty);
      expect(bItems, isNotEmpty);
      expect(cItems, isNotEmpty);
    });

    test('ABC items have valid revenue data', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final items = await service.getAbcAnalysis('store-1');

      for (final item in items) {
        expect(item.revenue, greaterThan(0));
        expect(item.percentage, greaterThan(0));
        expect(item.cumulativePercentage, greaterThan(0));
      }
    });

    test('category A items have highest revenue percentage', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final items = await service.getAbcAnalysis('store-1');

      final aItems = items.where((i) => i.category == AbcCategory.a).toList();
      final cItems = items.where((i) => i.category == AbcCategory.c).toList();

      final aAvg = aItems.map((i) => i.percentage).reduce((a, b) => a + b) /
          aItems.length;
      final cAvg = cItems.map((i) => i.percentage).reduce((a, b) => a + b) /
          cItems.length;

      expect(aAvg, greaterThan(cAvg));
    });
  });

  group('getWastePredictions', () {
    test('returns waste predictions', () async {
      when(() => mockDb.inventoryDao).thenReturn(MockInventoryDao());

      final predictions = await service.getWastePredictions('store-1');

      expect(predictions, isNotEmpty);
      expect(predictions.length, 5);
    });

    test('predictions have valid expiry data', () async {
      when(() => mockDb.inventoryDao).thenReturn(MockInventoryDao());

      final predictions = await service.getWastePredictions('store-1');

      for (final p in predictions) {
        expect(p.daysToExpiry, greaterThanOrEqualTo(0));
        expect(p.currentStock, greaterThan(0));
        expect(p.sellRate, greaterThan(0));
        expect(p.predictedWaste, greaterThanOrEqualTo(0));
      }
    });

    test('short expiry products have discount or donate actions', () async {
      when(() => mockDb.inventoryDao).thenReturn(MockInventoryDao());

      final predictions = await service.getWastePredictions('store-1');

      final urgent = predictions.where((p) => p.daysToExpiry <= 3).toList();
      for (final p in urgent) {
        expect(
          p.suggestedAction,
          anyOf(WasteSuggestedAction.discount, WasteSuggestedAction.donate),
        );
      }
    });
  });

  group('getReorderSuggestions', () {
    test('returns reorder suggestions', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final suggestions = await service.getReorderSuggestions('store-1');

      expect(suggestions, isNotEmpty);
      expect(suggestions.length, 4);
    });

    test('critical urgency items have low current stock', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final suggestions = await service.getReorderSuggestions('store-1');

      final critical =
          suggestions.where((s) => s.urgency == UrgencyLevel.critical).toList();
      for (final s in critical) {
        expect(s.currentStock, lessThan(s.reorderPoint));
      }
    });

    test('all suggestions have positive suggested quantity', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());

      final suggestions = await service.getReorderSuggestions('store-1');

      for (final s in suggestions) {
        expect(s.suggestedQty, greaterThan(0));
        expect(s.estimatedCost, greaterThan(0));
      }
    });
  });

  group('getSummary', () {
    test('returns complete summary', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());
      when(() => mockDb.inventoryDao).thenReturn(MockInventoryDao());

      final summary = await service.getSummary('store-1');

      expect(summary.totalProducts, greaterThan(0));
      expect(summary.abcACount, greaterThan(0));
      expect(summary.abcBCount, greaterThan(0));
      expect(summary.abcCCount, greaterThan(0));
      expect(summary.expiringCount, greaterThanOrEqualTo(0));
      expect(summary.reorderCount, greaterThan(0));
    });

    test('ABC counts sum to total products', () async {
      when(() => mockDb.productsDao).thenReturn(MockProductsDao());
      when(() => mockDb.inventoryDao).thenReturn(MockInventoryDao());

      final summary = await service.getSummary('store-1');

      expect(
        summary.abcACount + summary.abcBCount + summary.abcCCount,
        summary.totalProducts,
      );
    });
  });
}
