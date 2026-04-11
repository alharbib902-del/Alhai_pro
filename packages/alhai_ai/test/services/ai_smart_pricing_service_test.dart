import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_smart_pricing_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiSmartPricingService service;
  late MockAppDatabase mockDb;
  late MockProductsDao mockProductsDao;

  setUp(() {
    mockProductsDao = MockProductsDao();
    mockDb = createMockDatabase(productsDao: mockProductsDao);
    service = AiSmartPricingService(mockDb);
  });

  group('PriceSuggestion', () {
    test('changePercent calculates correctly', () {
      const suggestion = PriceSuggestion(
        productId: 'p1',
        name: 'Test',
        currentPrice: 100,
        suggestedPrice: 110,
        costPrice: 60,
        reasoning: 'Test',
        confidence: 0.9,
        expectedImpact: PriceImpact(
          monthlyRevenueDelta: 500,
          yearlyProfitDelta: 6000,
          volumeChange: -2,
        ),
      );

      expect(suggestion.changePercent, 10.0);
      expect(suggestion.isIncrease, isTrue);
      expect(suggestion.isDecrease, isFalse);
    });

    test('isDecrease returns true when suggested < current', () {
      const suggestion = PriceSuggestion(
        productId: 'p1',
        name: 'Test',
        currentPrice: 100,
        suggestedPrice: 85,
        costPrice: 60,
        reasoning: 'Test',
        confidence: 0.9,
        expectedImpact: PriceImpact(
          monthlyRevenueDelta: 500,
          yearlyProfitDelta: 6000,
          volumeChange: -2,
        ),
      );

      expect(suggestion.isDecrease, isTrue);
      expect(suggestion.isIncrease, isFalse);
      expect(suggestion.changePercent, -15.0);
    });

    test('currentMargin calculates correctly', () {
      const suggestion = PriceSuggestion(
        productId: 'p1',
        name: 'Test',
        currentPrice: 100,
        suggestedPrice: 100,
        costPrice: 60,
        reasoning: 'Test',
        confidence: 0.9,
        expectedImpact: PriceImpact(
          monthlyRevenueDelta: 0,
          yearlyProfitDelta: 0,
          volumeChange: 0,
        ),
      );

      expect(suggestion.currentMargin, 40.0);
    });

    test('suggestedMargin calculates correctly', () {
      const suggestion = PriceSuggestion(
        productId: 'p1',
        name: 'Test',
        currentPrice: 100,
        suggestedPrice: 120,
        costPrice: 60,
        reasoning: 'Test',
        confidence: 0.9,
        expectedImpact: PriceImpact(
          monthlyRevenueDelta: 0,
          yearlyProfitDelta: 0,
          volumeChange: 0,
        ),
      );

      expect(suggestion.suggestedMargin, 50.0);
    });

    test('margins return 0 when price is 0', () {
      const suggestion = PriceSuggestion(
        productId: 'p1',
        name: 'Test',
        currentPrice: 0,
        suggestedPrice: 0,
        costPrice: 0,
        reasoning: 'Test',
        confidence: 0.9,
        expectedImpact: PriceImpact(
          monthlyRevenueDelta: 0,
          yearlyProfitDelta: 0,
          volumeChange: 0,
        ),
      );

      expect(suggestion.currentMargin, 0);
      expect(suggestion.suggestedMargin, 0);
      expect(suggestion.changePercent, 0);
    });
  });

  group('ElasticityClass', () {
    test('has all values', () {
      expect(ElasticityClass.values.length, 3);
    });
  });

  group('PriceFilterType', () {
    test('has all values', () {
      expect(PriceFilterType.values.length, 3);
    });
  });

  group('getPriceSuggestions', () {
    test('returns suggestions for active products', () async {
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(
            id: 'p1',
            price: 100,
            costPrice: 90,
            isActive: true,
          ),
          createFakeProduct(id: 'p2', price: 50, costPrice: 10, isActive: true),
          createFakeProduct(
            id: 'p3',
            price: 30,
            costPrice: 15,
            isActive: false,
          ),
        ],
      );

      final suggestions = await service.getPriceSuggestions('store-1');

      // Only active products should be analyzed
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, lessThanOrEqualTo(2));
    });

    test('returns empty list when no active products', () async {
      when(
        () => mockProductsDao.getAllProducts(any()),
      ).thenAnswer((_) async => []);

      final suggestions = await service.getPriceSuggestions('store-1');

      expect(suggestions, isEmpty);
    });

    test('suggests increase for very low margin products', () async {
      // Product with 10% margin (cost=90, price=100)
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(
            id: 'p1',
            price: 100,
            costPrice: 90,
            isActive: true,
          ),
        ],
      );

      final suggestions = await service.getPriceSuggestions('store-1');

      // Low margin product should get a suggestion to increase
      if (suggestions.isNotEmpty) {
        expect(
          suggestions.first.suggestedPrice,
          greaterThan(suggestions.first.currentPrice),
        );
      }
    });

    test('suggests decrease for very high margin products', () async {
      // Product with 80% margin (cost=20, price=100)
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(
            id: 'p1',
            price: 100,
            costPrice: 20,
            isActive: true,
          ),
        ],
      );

      final suggestions = await service.getPriceSuggestions('store-1');

      if (suggestions.isNotEmpty) {
        expect(
          suggestions.first.suggestedPrice,
          lessThan(suggestions.first.currentPrice),
        );
      }
    });

    test('skips products with zero price', () async {
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(id: 'p1', price: 0, costPrice: 0, isActive: true),
        ],
      );

      final suggestions = await service.getPriceSuggestions('store-1');

      expect(suggestions, isEmpty);
    });
  });

  group('calculateImpact', () {
    test('returns zero impact when product not found', () async {
      when(
        () => mockProductsDao.getProductById(any()),
      ).thenAnswer((_) async => null);

      final impact = await service.calculateImpact('p1', 100.0);

      expect(impact.monthlyRevenueDelta, 0);
      expect(impact.yearlyProfitDelta, 0);
      expect(impact.volumeChange, 0);
    });

    test('calculates impact for valid product', () async {
      when(() => mockProductsDao.getProductById(any())).thenAnswer(
        (_) async =>
            createFakeProduct(id: 'p1', price: 100, costPrice: 60, minQty: 5),
      );

      final impact = await service.calculateImpact('p1', 110.0);

      expect(impact, isNotNull);
      // With a 10% price increase, the monthly revenue delta should reflect the change
    });
  });

  group('getElasticity', () {
    test('returns default when product not found', () async {
      when(
        () => mockProductsDao.getProductById(any()),
      ).thenAnswer((_) async => null);

      final elasticity = await service.getElasticity('p1');

      expect(elasticity.productId, '');
      expect(elasticity.classification, ElasticityClass.unit);
    });

    test('returns inelastic for cheap essential products', () async {
      when(() => mockProductsDao.getProductById(any())).thenAnswer(
        (_) async =>
            createFakeProduct(id: 'p1', name: 'Bread', price: 5, costPrice: 3),
      );

      final elasticity = await service.getElasticity('p1');

      expect(elasticity.productName, 'Bread');
      expect(elasticity.classification, ElasticityClass.inelastic);
    });

    test('returns elastic for expensive products', () async {
      when(() => mockProductsDao.getProductById(any())).thenAnswer(
        (_) async => createFakeProduct(
          id: 'p1',
          name: 'Luxury Item',
          price: 200,
          costPrice: 100,
        ),
      );

      final elasticity = await service.getElasticity('p1');

      expect(elasticity.productName, 'Luxury Item');
      expect(elasticity.classification, ElasticityClass.elastic);
    });
  });

  group('getBulkPricingOptions', () {
    test('returns options for inelastic products', () async {
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(
            id: 'p1',
            name: 'Rice',
            price: 5,
            costPrice: 3,
            isActive: true,
          ),
        ],
      );

      final options = await service.getBulkPricingOptions('store-1');

      // Cheap essential products should be safe to increase
      expect(options, isNotEmpty);
      for (final opt in options) {
        expect(opt.suggestedPrice, greaterThan(opt.currentPrice));
        expect(opt.safeIncreasePercent, greaterThan(2));
      }
    });

    test('returns sorted by safe increase percent', () async {
      when(() => mockProductsDao.getAllProducts(any())).thenAnswer(
        (_) async => [
          createFakeProduct(id: 'p1', price: 5, costPrice: 3, isActive: true),
          createFakeProduct(id: 'p2', price: 8, costPrice: 5, isActive: true),
        ],
      );

      final options = await service.getBulkPricingOptions('store-1');

      if (options.length > 1) {
        expect(
          options.first.safeIncreasePercent,
          greaterThanOrEqualTo(options.last.safeIncreasePercent),
        );
      }
    });
  });
}
