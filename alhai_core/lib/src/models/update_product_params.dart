import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_product_params.freezed.dart';
part 'update_product_params.g.dart';

/// Parameters for updating an existing product (v3.2)
/// All fields are optional - only provided fields will be updated
@freezed
class UpdateProductParams with _$UpdateProductParams {
  const factory UpdateProductParams({
    /// Product ID to update
    required String id,

    /// New product name (optional)
    String? name,

    /// New product price — INTEGER cents (C-4 Stage B).
    int? price,

    /// New product description (optional)
    String? description,

    /// New product image URL (optional)
    String? imageUrl,

    /// New product barcode (optional)
    String? barcode,

    /// New category ID (optional)
    String? categoryId,

    /// New availability status (optional)
    bool? available,
  }) = _UpdateProductParams;

  factory UpdateProductParams.fromJson(Map<String, dynamic> json) =>
      _$UpdateProductParamsFromJson(json);
}

/// Extension for UpdateProductParams
extension UpdateProductParamsExt on UpdateProductParams {
  /// Convert to Map for API request (excludes null values)
  Map<String, dynamic> toUpdateMap() {
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
