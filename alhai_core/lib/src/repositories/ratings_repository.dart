import '../models/paginated.dart';

/// Repository contract for rating operations (v2.6.0)
/// Manages ratings for stores, products, and deliveries
abstract class RatingsRepository {
  /// Gets ratings for an entity
  Future<Paginated<Rating>> getRatings(
    RatingEntityType entityType,
    String entityId, {
    int page = 1,
    int limit = 20,
  });

  /// Gets a rating by ID
  Future<Rating> getRating(String id);

  /// Creates a new rating
  Future<Rating> createRating({
    required RatingEntityType entityType,
    required String entityId,
    required String customerId,
    required String orderId,
    required int stars,
    String? comment,
    List<String>? tags,
  });

  /// Updates a rating
  Future<Rating> updateRating(
    String id, {
    int? stars,
    String? comment,
  });

  /// Deletes a rating
  Future<void> deleteRating(String id);

  /// Gets average rating for an entity
  Future<RatingSummary> getRatingSummary(RatingEntityType entityType, String entityId);

  /// Gets ratings by customer
  Future<List<Rating>> getCustomerRatings(String customerId);
}

/// Rating entity type
enum RatingEntityType { store, product, delivery, driver }

/// Rating model
class Rating {
  final String id;
  final RatingEntityType entityType;
  final String entityId;
  final String customerId;
  final String? customerName;
  final String orderId;
  final int stars;
  final String? comment;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Rating({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.customerId,
    this.customerName,
    required this.orderId,
    required this.stars,
    this.comment,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
  });
}

/// Rating summary
class RatingSummary {
  final RatingEntityType entityType;
  final String entityId;
  final double averageRating;
  final int totalRatings;
  final Map<int, int> distribution;

  const RatingSummary({
    required this.entityType,
    required this.entityId,
    required this.averageRating,
    required this.totalRatings,
    required this.distribution,
  });
}
