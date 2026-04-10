import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_return_prediction_providers.dart';
import 'package:alhai_ai/src/services/ai_return_prediction_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('selectedRiskFilterProvider', () {
    test('initial value is null (show all)', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(selectedRiskFilterProvider), isNull);
    });

    test('can be updated to high risk', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedRiskFilterProvider.notifier).state =
          ReturnRiskLevel.high;
      expect(
        container.read(selectedRiskFilterProvider),
        ReturnRiskLevel.high,
      );
    });

    test('can be cleared back to null', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      container.read(selectedRiskFilterProvider.notifier).state =
          ReturnRiskLevel.high;
      container.read(selectedRiskFilterProvider.notifier).state = null;
      expect(container.read(selectedRiskFilterProvider), isNull);
    });
  });

  group('ReturnRiskLevel', () {
    test('has expected values', () {
      expect(ReturnRiskLevel.values.length, greaterThanOrEqualTo(3));
      expect(ReturnRiskLevel.values, contains(ReturnRiskLevel.high));
    });
  });

  group('aiReturnPredictionServiceProvider', () {
    test('provides AiReturnPredictionService instance', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      final service = container.read(aiReturnPredictionServiceProvider);
      expect(service, isA<AiReturnPredictionService>());
    });
  });
}
