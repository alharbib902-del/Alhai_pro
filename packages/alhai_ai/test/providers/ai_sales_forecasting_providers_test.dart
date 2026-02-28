import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/services/ai_sales_forecasting_service.dart';
import 'package:alhai_ai/src/providers/ai_sales_forecasting_providers.dart';

void main() {
  group('selectedForecastPeriodProvider', () {
    test('initial value is daily', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(selectedForecastPeriodProvider),
        ForecastPeriod.daily,
      );
    });

    test('can be updated to weekly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedForecastPeriodProvider.notifier).state =
          ForecastPeriod.weekly;

      expect(
        container.read(selectedForecastPeriodProvider),
        ForecastPeriod.weekly,
      );
    });

    test('can be updated to monthly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(selectedForecastPeriodProvider.notifier).state =
          ForecastPeriod.monthly;

      expect(
        container.read(selectedForecastPeriodProvider),
        ForecastPeriod.monthly,
      );
    });
  });

  group('whatIfDiscountProvider', () {
    test('initial value is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(whatIfDiscountProvider), 0);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(whatIfDiscountProvider.notifier).state = 15.0;
      expect(container.read(whatIfDiscountProvider), 15.0);
    });
  });

  group('whatIfPriceChangeProvider', () {
    test('initial value is 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(whatIfPriceChangeProvider), 0);
    });

    test('can be updated to positive value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(whatIfPriceChangeProvider.notifier).state = 10.0;
      expect(container.read(whatIfPriceChangeProvider), 10.0);
    });

    test('can be updated to negative value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(whatIfPriceChangeProvider.notifier).state = -5.0;
      expect(container.read(whatIfPriceChangeProvider), -5.0);
    });
  });

  group('ForecastPeriod', () {
    test('has all values', () {
      expect(ForecastPeriod.values.length, 3);
      expect(ForecastPeriod.values, contains(ForecastPeriod.daily));
      expect(ForecastPeriod.values, contains(ForecastPeriod.weekly));
      expect(ForecastPeriod.values, contains(ForecastPeriod.monthly));
    });
  });
}
