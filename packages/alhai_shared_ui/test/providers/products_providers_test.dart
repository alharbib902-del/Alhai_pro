import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/src/providers/products_providers.dart';

void main() {
  group('ProductsState', () {
    test('should have default values', () {
      const state = ProductsState();
      expect(state.products, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.currentPage, 1);
      expect(state.hasMore, isTrue);
      expect(state.searchQuery, isNull);
      expect(state.categoryId, isNull);
    });

    test('copyWith should update isLoading', () {
      const state = ProductsState();
      final updated = state.copyWith(isLoading: true);
      expect(updated.isLoading, isTrue);
      expect(updated.products, state.products);
    });

    test('copyWith should update error', () {
      const state = ProductsState();
      final updated = state.copyWith(error: 'Some error');
      expect(updated.error, 'Some error');
    });

    test('copyWith should clear error when set to null explicitly', () {
      const state = ProductsState(error: 'Old error');
      // Note: copyWith uses positional null, so error is always replaced
      final updated = state.copyWith();
      // error parameter is not provided, so it becomes null (the default)
      expect(updated.error, isNull);
    });

    test('copyWith should update searchQuery', () {
      const state = ProductsState();
      final updated = state.copyWith(searchQuery: 'test');
      expect(updated.searchQuery, 'test');
    });

    test('copyWith should update categoryId', () {
      const state = ProductsState();
      final updated = state.copyWith(categoryId: 'cat-1');
      expect(updated.categoryId, 'cat-1');
    });

    test('copyWith should update currentPage', () {
      const state = ProductsState();
      final updated = state.copyWith(currentPage: 3);
      expect(updated.currentPage, 3);
    });

    test('copyWith should update hasMore', () {
      const state = ProductsState();
      final updated = state.copyWith(hasMore: false);
      expect(updated.hasMore, isFalse);
    });
  });
}
