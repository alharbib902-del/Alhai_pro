import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated.freezed.dart';
part 'paginated.g.dart';

/// Generic paginated response wrapper (v3.2)
/// Used for all paginated API responses
@Freezed(genericArgumentFactories: true)
class Paginated<T> with _$Paginated<T> {
  const factory Paginated({
    /// List of items for current page
    required List<T> items,
    
    /// Current page number (1-indexed)
    required int page,
    
    /// Items per page limit
    required int limit,
    
    /// Total items count (if available from API)
    int? total,
    
    /// Whether more pages exist
    @Default(false) bool hasMore,
  }) = _Paginated<T>;

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PaginatedFromJson(json, fromJsonT);
}

/// Extension for Paginated helpers
extension PaginatedExt<T> on Paginated<T> {
  /// Calculate total pages if total is available
  int? get totalPages {
    if (total == null || limit == 0) return null;
    return (total! / limit).ceil();
  }
  
  /// Check if this is the first page
  bool get isFirstPage => page == 1;
  
  /// Check if this is the last page
  bool get isLastPage => !hasMore;
  
  /// Get next page number (null if no more)
  int? get nextPage => hasMore ? page + 1 : null;
  
  /// Get previous page number (null if first)
  int? get previousPage => page > 1 ? page - 1 : null;
}
