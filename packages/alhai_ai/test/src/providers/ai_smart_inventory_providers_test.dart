import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_ai/src/providers/ai_smart_inventory_providers.dart';
import 'package:alhai_ai/src/services/ai_smart_inventory_service.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  group('abcCategoryFilterProvider', () {
    test('initial value is null (show all)', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      expect(container.read(abcCategoryFilterProvider), isNull);
    });

    test('can be updated to category A', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      container.read(abcCategoryFilterProvider.notifier).state = AbcCategory.a;
      expect(container.read(abcCategoryFilterProvider), AbcCategory.a);
    });

    test('can be updated to category B', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      container.read(abcCategoryFilterProvider.notifier).state = AbcCategory.b;
      expect(container.read(abcCategoryFilterProvider), AbcCategory.b);
    });

    test('can be cleared back to null', () {
      final container = ProviderContainer(
        overrides: [currentStoreIdProvider.overrideWith((ref) => 'test-store')],
      );
      addTearDown(container.dispose);

      container.read(abcCategoryFilterProvider.notifier).state = AbcCategory.a;
      container.read(abcCategoryFilterProvider.notifier).state = null;
      expect(container.read(abcCategoryFilterProvider), isNull);
    });
  });

  group('AbcCategory', () {
    test('has expected values', () {
      expect(AbcCategory.values.length, 3);
      expect(AbcCategory.values, contains(AbcCategory.a));
      expect(AbcCategory.values, contains(AbcCategory.b));
      expect(AbcCategory.values, contains(AbcCategory.c));
    });
  });
}
