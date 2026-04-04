import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/services/ai_smart_pricing_service.dart';
import 'package:alhai_ai/src/providers/ai_smart_pricing_providers.dart';

void main() {
  group('priceFilterProvider', () {
    test('initial value is all', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(priceFilterProvider), PriceFilterType.all);
    });

    test('can be updated to canIncrease', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(priceFilterProvider.notifier).state =
          PriceFilterType.canIncrease;
      expect(container.read(priceFilterProvider), PriceFilterType.canIncrease);
    });

    test('can be updated to shouldDecrease', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(priceFilterProvider.notifier).state =
          PriceFilterType.shouldDecrease;
      expect(
          container.read(priceFilterProvider), PriceFilterType.shouldDecrease);
    });
  });

  group('selectedPriceSuggestionProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedPriceSuggestionProvider), isNull);
    });
  });

  group('calculatorPriceProvider', () {
    test('initial value is 0 when no suggestion selected', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(calculatorPriceProvider), 0);
    });
  });

  group('PriceFilterType', () {
    test('has all values', () {
      expect(PriceFilterType.values.length, 3);
      expect(PriceFilterType.values, contains(PriceFilterType.all));
      expect(PriceFilterType.values, contains(PriceFilterType.canIncrease));
      expect(PriceFilterType.values, contains(PriceFilterType.shouldDecrease));
    });
  });
}
