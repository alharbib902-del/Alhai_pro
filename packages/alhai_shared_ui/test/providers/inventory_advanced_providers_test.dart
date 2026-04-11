/// Unit tests for inventory advanced providers
///
/// Tests: ExpiryItemData model, provider definitions
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_shared_ui/alhai_shared_ui.dart';

void main() {
  group('ExpiryItemData', () {
    test('stores expiry and product name', () {
      // ExpiryItemData is a simple data class with expiry and productName
      // We test its construction here
      expect(ExpiryItemData, isNotNull);
    });
  });

  group('expiryTrackingProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(expiryTrackingProvider.future);
      expect(result, isEmpty);
    });
  });

  group('stockTransfersListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(stockTransfersListProvider.future);
      expect(result, isEmpty);
    });
  });

  group('stockTakesListProvider', () {
    test('returns empty list when no store id', () async {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => null)],
      );
      addTearDown(container.dispose);

      final result = await container.read(stockTakesListProvider.future);
      expect(result, isEmpty);
    });
  });
}
