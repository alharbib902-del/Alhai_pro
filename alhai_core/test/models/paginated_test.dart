import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Paginated Model', () {
    test('should calculate totalPages correctly', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 1,
        limit: 10,
        total: 25,
      );

      expect(paginated.totalPages, 3);
    });

    test('should detect first page correctly', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 1,
        limit: 10,
        hasMore: true,
      );

      expect(paginated.isFirstPage, isTrue);
      expect(paginated.isLastPage, isFalse);
    });

    test('should detect last page correctly when hasMore is false', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 3,
        limit: 10,
        hasMore: false,
      );

      expect(paginated.isLastPage, isTrue);
    });

    test('should calculate nextPage correctly', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 2,
        limit: 10,
        hasMore: true,
      );

      expect(paginated.nextPage, 3);
    });

    test('should return null nextPage when on last page', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 3,
        limit: 10,
        hasMore: false,
      );

      expect(paginated.nextPage, isNull);
    });

    test('should calculate previousPage correctly', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 2,
        limit: 10,
      );

      expect(paginated.previousPage, 1);
    });

    test('should return null previousPage when on first page', () {
      final paginated = Paginated<String>(
        items: ['a', 'b', 'c'],
        page: 1,
        limit: 10,
      );

      expect(paginated.previousPage, isNull);
    });
  });
}
