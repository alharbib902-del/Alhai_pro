import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_services/alhai_services.dart';

class FakeRatingsRepo implements RatingsRepository {
  @override Future<Paginated<Rating>> getRatings(RatingEntityType entityType, String entityId, {int page = 1, int limit = 20}) async => Paginated(items: [], total: 0, page: page, limit: limit);
  @override Future<Rating> getRating(String id) async => throw UnimplementedError();
  @override Future<Rating> createRating({required RatingEntityType entityType, required String entityId, required String customerId, required String orderId, required int stars, String? comment, List<String>? tags}) async => throw UnimplementedError();
  @override Future<Rating> updateRating(String id, {int? stars, String? comment}) async => throw UnimplementedError();
  @override Future<void> deleteRating(String id) async {}
  @override Future<RatingSummary> getRatingSummary(RatingEntityType entityType, String entityId) async =>
      RatingSummary(entityType: entityType, entityId: entityId, averageRating: 4.5, totalRatings: 10, distribution: {5: 5, 4: 3, 3: 1, 2: 1, 1: 0});
  @override Future<List<Rating>> getCustomerRatings(String customerId) async => [];
}

void main() {
  late RatingService ratingService;
  setUp(() { ratingService = RatingService(FakeRatingsRepo()); });

  group('RatingService', () {
    test('should be created', () { expect(ratingService, isNotNull); });

    test('getRatings should return paginated', () async {
      final result = await ratingService.getRatings(RatingEntityType.store, 'store-1');
      expect(result, isA<Paginated<Rating>>());
    });

    test('getRatingSummary should return summary', () async {
      final summary = await ratingService.getRatingSummary(RatingEntityType.store, 'store-1');
      expect(summary.averageRating, equals(4.5));
      expect(summary.totalRatings, equals(10));
    });

    test('getStoreRatingSummary should delegate', () async {
      final summary = await ratingService.getStoreRatingSummary('store-1');
      expect(summary.entityType, equals(RatingEntityType.store));
    });

    test('getProductRatingSummary should delegate', () async {
      final summary = await ratingService.getProductRatingSummary('prod-1');
      expect(summary.entityType, equals(RatingEntityType.product));
    });

    test('getDriverRatingSummary should delegate', () async {
      final summary = await ratingService.getDriverRatingSummary('driver-1');
      expect(summary.entityType, equals(RatingEntityType.driver));
    });

    test('getCustomerRatings should return list', () async {
      final ratings = await ratingService.getCustomerRatings('cust-1');
      expect(ratings, isA<List<Rating>>());
    });

    test('deleteRating should not throw', () async {
      await ratingService.deleteRating('r1');
    });
  });
}
