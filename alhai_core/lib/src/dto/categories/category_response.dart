import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/category.dart';

part 'category_response.freezed.dart';
part 'category_response.g.dart';

/// DTO for category response from API (snake_case)
@freezed
class CategoryResponse with _$CategoryResponse {
  const CategoryResponse._();

  const factory CategoryResponse({
    required String id,
    required String name,
    @JsonKey(name: 'parent_id') String? parentId,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _CategoryResponse;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      _$CategoryResponseFromJson(json);

  /// Maps DTO to Domain model
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      parentId: parentId,
      imageUrl: imageUrl,
      sortOrder: sortOrder,
      isActive: isActive,
    );
  }
}
