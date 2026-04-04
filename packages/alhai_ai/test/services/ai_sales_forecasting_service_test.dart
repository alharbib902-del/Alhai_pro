import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_ai/src/services/ai_sales_forecasting_service.dart';
import '../helpers/ai_test_helpers.dart';

void main() {
  late AiSalesForecastingService service;
  late MockAppDatabase mockDb;
  late MockSalesDao mockSalesDao;

  setUpAll(() {
    registerFallbackValue(DateTime.now());
  });

  setUp(() {
    mockSalesDao = MockSalesDao();
    mockDb = createMockDatabase(salesDao: mockSalesDao);
    service = AiSalesForecastingService(mockDb);
  });

  group('DailyForecast', () {
    test('deviation returns null when actual is null', () {
      final forecast = DailyForecast(
        date: DateTime(2024, 1, 1),
        predicted: 100,
        confidence: 0.9,
      );
      expect(forecast.deviation, isNull);
      expect(forecast.errorPercent, isNull);
    });

    test('deviation returns difference when actual is set', () {
      final forecast = DailyForecast(
        date: DateTime(2024, 1, 1),
        predicted: 100,
        actual: 120,
        confidence: 0.9,
      );
      expect(forecast.deviation, 20.0);
    });

    test('errorPercent calculates correct percentage', () {
      final forecast = DailyForecast(
        date: DateTime(2024, 1, 1),
        predicted: 100,
        actual: 120,
        confidence: 0.9,
      );
      expect(forecast.errorPercent, 20.0);
    });

    test('errorPercent returns null when predicted is 0', () {
      final forecast = DailyForecast(
        date: DateTime(2024, 1, 1),
        predicted: 0,
        actual: 120,
        confidence: 0.9,
      );
      expect(forecast.errorPercent, isNull);
    });
  });

  group('SeasonalPattern', () {
    test('isPeak returns true for multiplier > 1.15', () {
      const pattern = SeasonalPattern(
        name: 'Friday',
        multiplier: 1.25,
        description: 'Peak day',
      );
      expect(pattern.isPeak, isTrue);
      expect(pattern.isLow, isFalse);
    });

    test('isLow returns true for multiplier < 0.85', () {
      const pattern = SeasonalPattern(
        name: 'Sunday',
        multiplier: 0.75,
        description: 'Slow day',
      );
      expect(pattern.isPeak, isFalse);
      expect(pattern.isLow, isTrue);
    });

    test('neither peak nor low for multiplier in range', () {
      const pattern = SeasonalPattern(
        name: 'Wednesday',
        multiplier: 1.0,
        description: 'Normal day',
      );
      expect(pattern.isPeak, isFalse);
      expect(pattern.isLow, isFalse);
    });
  });

  group('WhatIfScenario', () {
    test('creates with default values', () {
      const scenario = WhatIfScenario();
      expect(scenario.discountPercent, 0);
      expect(scenario.priceChangePercent, 0);
    });

    test('creates with custom values', () {
      const scenario = WhatIfScenario(
        discountPercent: 10,
        priceChangePercent: -5,
      );
      expect(scenario.discountPercent, 10);
      expect(scenario.priceChangePercent, -5);
    });
  });

  group('ForecastPeriod', () {
    test('has correct values', () {
      expect(ForecastPeriod.values.length, 3);
      expect(ForecastPeriod.daily, isNotNull);
      expect(ForecastPeriod.weekly, isNotNull);
      expect(ForecastPeriod.monthly, isNotNull);
    });
  });

  group('TrendDirection', () {
    test('has correct values', () {
      expect(TrendDirection.values.length, 3);
      expect(TrendDirection.up, isNotNull);
      expect(TrendDirection.down, isNotNull);
      expect(TrendDirection.stable, isNotNull);
    });
  });

  group('generateForecast', () {
    test('generates forecasts with empty sales data', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final result =
          await service.generateForecast('store-1', ForecastPeriod.daily);

      expect(result.forecasts, isNotEmpty);
      expect(result.trend, isNotNull);
      expect(result.seasonalPatterns, isNotEmpty);
      expect(result.accuracy, greaterThan(0));
      expect(result.summary, isNotEmpty);
    });

    test('generates forecasts for weekly period', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final result =
          await service.generateForecast('store-1', ForecastPeriod.weekly);

      expect(result.forecasts, isNotEmpty);
      expect(result.nextWeekTotal, greaterThan(0));
      expect(result.nextMonthTotal, greaterThan(0));
    });

    test('generates forecasts for monthly period', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final result =
          await service.generateForecast('store-1', ForecastPeriod.monthly);

      expect(result.forecasts, isNotEmpty);
    });

    test('uses real sales data when available', () async {
      final now = DateTime.now();
      final sales = List.generate(
        10,
        (i) => createFakeSale(
          id: 'sale-$i',
          total: 1000.0 + i * 100,
          createdAt: now.subtract(Duration(days: 10 - i)),
        ),
      );

      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => sales);

      final result =
          await service.generateForecast('store-1', ForecastPeriod.daily);

      expect(result.forecasts, isNotEmpty);
      expect(result.accuracy, greaterThan(0));
    });
  });

  group('detectSeasonalPatterns', () {
    test('returns patterns even with no sales data', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final patterns = await service.detectSeasonalPatterns('store-1');

      expect(patterns, isNotEmpty);
    });
  });

  group('simulateWhatIf', () {
    test('returns result with discount scenario', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.simulateWhatIf(
        'store-1',
        const WhatIfScenario(discountPercent: 10),
      );

      expect(result.originalRevenue, greaterThan(0));
      expect(result.projectedRevenue, greaterThan(0));
      expect(result.explanation, isNotEmpty);
    });

    test('returns result with price change scenario', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.simulateWhatIf(
        'store-1',
        const WhatIfScenario(priceChangePercent: 5),
      );

      expect(result.explanation, isNotEmpty);
      expect(result.estimatedVolumeChange, isNotNull);
    });

    test('uses actual sales data when sufficient', () async {
      final sales = List.generate(
        5,
        (i) => createFakeSale(
          id: 'sale-$i',
          total: 2000.0,
          createdAt: DateTime.now().subtract(Duration(days: i)),
        ),
      );

      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => sales);

      final result = await service.simulateWhatIf(
        'store-1',
        const WhatIfScenario(discountPercent: 15),
      );

      expect(result.originalRevenue, greaterThan(100));
    });

    test('no changes scenario returns default explanation', () async {
      when(() => mockSalesDao.getSalesByDateRange(any(), any(), any()))
          .thenAnswer((_) async => []);

      final result = await service.simulateWhatIf(
        'store-1',
        const WhatIfScenario(),
      );

      expect(result.explanation, contains('لا توجد تغييرات'));
    });
  });
}
