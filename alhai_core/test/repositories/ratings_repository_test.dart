import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/repositories/ratings_repository.dart';

/// Tests for Rating, RatingSummary, RatingEntityType
/// defined in ratings_repository.dart.
/// RatingsRepository is an abstract interface - no implementation to test yet.
void main() {
  group('Rating Model', () {
    test('should construct with all required fields', () {
      final rating = Rating(
        id: 'rating-1',
        entityType: RatingEntityType.store,
        entityId: 'store-1',
        customerId: 'customer-1',
        customerName: 'Ahmed',
        orderId: 'order-1',
        stars: 5,
        comment: 'Excellent service',
        tags: const ['fast', 'quality'],
        createdAt: DateTime(2026, 1, 15),
      );

      expect(rating.id, equals('rating-1'));
      expect(rating.entityType, equals(RatingEntityType.store));
      expect(rating.stars, equals(5));
      expect(rating.comment, equals('Excellent service'));
      expect(rating.tags, hasLength(2));
    });

    test('should default tags to empty list', () {
      final rating = Rating(
        id: 'rating-1',
        entityType: RatingEntityType.product,
        entityId: 'product-1',
        customerId: 'customer-1',
        orderId: 'order-1',
        stars: 4,
        createdAt: DateTime(2026, 1, 15),
      );

      expect(rating.tags, isEmpty);
      expect(rating.comment, isNull);
      expect(rating.customerName, isNull);
      expect(rating.updatedAt, isNull);
    });
  });

  group('RatingSummary', () {
    test('should construct with all required fields', () {
      const summary = RatingSummary(
        entityType: RatingEntityType.store,
        entityId: 'store-1',
        averageRating: 4.5,
        totalRatings: 100,
        distribution: {
          5: 50,
          4: 30,
          3: 10,
          2: 5,
          1: 5,
        },
      );

      expect(summary.averageRating, equals(4.5));
      expect(summary.totalRatings, equals(100));
      expect(summary.distribution[5], equals(50));
      expect(summary.distribution[1], equals(5));
    });

    test('should handle no ratings', () {
      const summary = RatingSummary(
        entityType: RatingEntityType.product,
        entityId: 'product-1',
        averageRating: 0,
        totalRatings: 0,
        distribution: {},
      );

      expect(summary.averageRating, equals(0));
      expect(summary.totalRatings, equals(0));
      expect(summary.distribution, isEmpty);
    });
  });

  group('RatingEntityType', () {
    test('should have all expected values', () {
      expect(RatingEntityType.values, hasLength(4));
      expect(RatingEntityType.values, contains(RatingEntityType.store));
      expect(RatingEntityType.values, contains(RatingEntityType.product));
      expect(RatingEntityType.values, contains(RatingEntityType.delivery));
      expect(RatingEntityType.values, contains(RatingEntityType.driver));
    });
  });
}
