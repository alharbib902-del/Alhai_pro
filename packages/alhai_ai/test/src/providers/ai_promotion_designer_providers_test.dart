import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_promotion_designer_providers.dart';
import 'package:alhai_ai/src/services/ai_promotion_designer_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('selectedPromotionProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(selectedPromotionProvider), isNull);
    });
  });

  group('promotionTypeFilterProvider', () {
    test('initial value is null (show all)', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(promotionTypeFilterProvider), isNull);
    });

    test('can be updated', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      container.read(promotionTypeFilterProvider.notifier).state =
          PromotionType.percentOff;
      expect(
        container.read(promotionTypeFilterProvider),
        PromotionType.percentOff,
      );
    });
  });

  group('abTestDurationProvider', () {
    test('initial value is 7 days', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(abTestDurationProvider), 7);
    });

    test('can be updated', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      container.read(abTestDurationProvider.notifier).state = 14;
      expect(container.read(abTestDurationProvider), 14);
    });
  });

  group('abTestControlPercentProvider', () {
    test('initial value is 20', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(abTestControlPercentProvider), 20);
    });

    test('can be updated', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      container.read(abTestControlPercentProvider.notifier).state = 30;
      expect(container.read(abTestControlPercentProvider), 30);
    });
  });

  group('abTestPromotionAProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(abTestPromotionAProvider), isNull);
    });
  });

  group('abTestPromotionBProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => 'test-store'),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(abTestPromotionBProvider), isNull);
    });
  });
}
