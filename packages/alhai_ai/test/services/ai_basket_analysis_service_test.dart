import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_basket_analysis_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiBasketAnalysisService service;
  late MockAppDatabase mockDb;

  setUp(() {
    mockDb = createMockDatabase();
    service = AiBasketAnalysisService(mockDb);
  });

  group('BundleSuggestion', () {
    test('savingsPercent calculates correctly', () {
      const bundle = BundleSuggestion(
        id: 'B1',
        name: 'Test Bundle',
        products: [],
        currentTotalPrice: 100,
        suggestedBundlePrice: 85,
        expectedUplift: 10,
        reasoning: 'Test',
      );

      expect(bundle.savingsPercent, 15.0);
    });

    test('savingsPercent returns 0 when price is 0', () {
      const bundle = BundleSuggestion(
        id: 'B1',
        name: 'Test Bundle',
        products: [],
        currentTotalPrice: 0,
        suggestedBundlePrice: 0,
        expectedUplift: 0,
        reasoning: 'Test',
      );

      expect(bundle.savingsPercent, 0);
    });
  });

  group('getAssociations', () {
    test('returns product associations', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final associations = await service.getAssociations('store-1');

      expect(associations, isNotEmpty);
      expect(associations.length, 10);
    });

    test('associations have valid confidence scores', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final associations = await service.getAssociations('store-1');

      for (final a in associations) {
        expect(a.confidence, greaterThan(0));
        expect(a.confidence, lessThanOrEqualTo(1));
        expect(a.lift, greaterThan(0));
        expect(a.frequency, greaterThan(0));
      }
    });

    test('associations have product names', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final associations = await service.getAssociations('store-1');

      for (final a in associations) {
        expect(a.productAName, isNotEmpty);
        expect(a.productBName, isNotEmpty);
        expect(a.productAId, isNotEmpty);
        expect(a.productBId, isNotEmpty);
      }
    });
  });

  group('getBundleSuggestions', () {
    test('returns bundle suggestions', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final bundles = await service.getBundleSuggestions('store-1');

      expect(bundles, isNotEmpty);
      expect(bundles.length, 4);
    });

    test('bundles have products', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final bundles = await service.getBundleSuggestions('store-1');

      for (final b in bundles) {
        expect(b.products, isNotEmpty);
        expect(b.name, isNotEmpty);
        expect(b.reasoning, isNotEmpty);
      }
    });

    test('bundle price is less than sum of individual prices', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final bundles = await service.getBundleSuggestions('store-1');

      for (final b in bundles) {
        expect(b.suggestedBundlePrice, lessThan(b.currentTotalPrice));
        expect(b.savingsPercent, greaterThan(0));
      }
    });

    test('bundles have positive expected uplift', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final bundles = await service.getBundleSuggestions('store-1');

      for (final b in bundles) {
        expect(b.expectedUplift, greaterThan(0));
      }
    });
  });

  group('getBasketInsights', () {
    test('returns basket insights', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final insights = await service.getBasketInsights('store-1');

      expect(insights.avgBasketSize, greaterThan(0));
      expect(insights.avgBasketValue, greaterThan(0));
      expect(insights.topPairs, isNotEmpty);
      expect(insights.crossSellOpportunities, isNotEmpty);
      expect(insights.categoryMix, isNotEmpty);
      expect(insights.conversionRate, greaterThan(0));
    });

    test('category mix percentages are reasonable', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final insights = await service.getBasketInsights('store-1');

      final total = insights.categoryMix.values.reduce((a, b) => a + b);
      expect(total, closeTo(100, 1));
    });

    test('cross sell opportunities have valid data', () async {
      when(() => mockDb.saleItemsDao).thenReturn(MockSaleItemsDao());

      final insights = await service.getBasketInsights('store-1');

      for (final opp in insights.crossSellOpportunities) {
        expect(opp.triggerProduct, isNotEmpty);
        expect(opp.suggestedProduct, isNotEmpty);
        expect(opp.probability, greaterThan(0));
        expect(opp.probability, lessThanOrEqualTo(1));
        expect(opp.reason, isNotEmpty);
      }
    });
  });
}
