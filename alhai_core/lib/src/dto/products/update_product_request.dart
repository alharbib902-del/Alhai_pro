import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/update_product_params.dart';

part 'update_product_request.freezed.dart';
part 'update_product_request.g.dart';

/// DTO for update product request to API (snake_case)
/// Only non-null fields are sent to API
@freezed
class UpdateProductRequest with _$UpdateProductRequest {
  const UpdateProductRequest._();

  const factory UpdateProductRequest({
    String? name,
    // C-4 Stage B: int cents on the wire (matches int-cents Supabase schema).
    int? price,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? barcode,
    @JsonKey(name: 'category_id') String? categoryId,
    bool? available,
  }) = _UpdateProductRequest;

  factory UpdateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductRequestFromJson(json);

  /// Creates DTO from Domain params (excludes null values)
  factory UpdateProductRequest.fromDomain(UpdateProductParams params) {
    return UpdateProductRequest(
      name: params.name,
      price: params.price,
      description: params.description,
      imageUrl: params.imageUrl,
      barcode: params.barcode,
      categoryId: params.categoryId,
      available: params.available,
    );
  }

  /// Convert to Map excluding null values for PATCH request
  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (price != null) map['price'] = price;
    if (description != null) map['description'] = description;
    if (imageUrl != null) map['image_url'] = imageUrl;
    if (barcode != null) map['barcode'] = barcode;
    if (categoryId != null) map['category_id'] = categoryId;
    if (available != null) map['available'] = available;
    return map;
  }
}
