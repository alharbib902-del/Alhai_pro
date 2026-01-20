import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/product.dart';

part 'product_response.freezed.dart';
part 'product_response.g.dart';

/// DTO for product response from API (snake_case) - Complete v3.2
@freezed
class ProductResponse with _$ProductResponse {
  const ProductResponse._();

  const factory ProductResponse({
    required String id,
    @JsonKey(name: 'store_id') required String storeId,
    required String name,
    String? sku,
    String? barcode,
    required double price,
    @JsonKey(name: 'cost_price') double? costPrice,
    @JsonKey(name: 'stock_qty') required int stockQty,
    @JsonKey(name: 'min_qty') @Default(1) int minQty,
    String? unit,
    String? description,
    @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
    @JsonKey(name: 'image_url') String? imageUrl,
    // R2 Image Storage (Cloudflare CDN)
    @JsonKey(name: 'image_thumbnail') String? imageThumbnail, // 300×300
    @JsonKey(name: 'image_medium') String? imageMedium,       // 600×600
    @JsonKey(name: 'image_large') String? imageLarge,         // 1200×1200
    @JsonKey(name: 'image_hash') String? imageHash,           // Versioning
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'track_inventory') @Default(true) bool trackInventory,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ProductResponse;

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);

  /// Maps DTO to Domain model
  Product toDomain() {
    return Product(
      id: id,
      storeId: storeId,
      name: name,
      sku: sku,
      barcode: barcode,
      price: price,
      costPrice: costPrice,
      stockQty: stockQty,
      minQty: minQty,
      unit: unit,
      description: description,
      // ignore: deprecated_member_use_from_same_package
      imageUrl: imageUrl,
      imageThumbnail: imageThumbnail,
      imageMedium: imageMedium,
      imageLarge: imageLarge,
      imageHash: imageHash,
      categoryId: categoryId,
      isActive: isActive,
      trackInventory: trackInventory,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}
