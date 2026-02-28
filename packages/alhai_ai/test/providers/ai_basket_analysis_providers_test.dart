import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_basket_analysis_providers.dart';

void main() {
  group('minConfidenceFilterProvider', () {
    test('initial value is 0.5', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(minConfidenceFilterProvider), 0.5);
    });

    test('can be updated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(minConfidenceFilterProvider.notifier).state = 0.8;
      expect(container.read(minConfidenceFilterProvider), 0.8);
    });

    test('can be set to 0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(minConfidenceFilterProvider.notifier).state = 0.0;
      expect(container.read(minConfidenceFilterProvider), 0.0);
    });

    test('can be set to 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(minConfidenceFilterProvider.notifier).state = 1.0;
      expect(container.read(minConfidenceFilterProvider), 1.0);
    });
  });
}
