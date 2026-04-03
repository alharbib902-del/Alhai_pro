import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Product domain model (v3.2 - Complete)
@freezed
class Product with _$Product {
  const Product._();

  const factory Product({
    required String id,
    required String storeId,
    required String name,
    String? sku,
    String? barcode,
    required double price,
    double? costPrice,
    required double stockQty,
    @Default(0) double minQty,
    String? unit,
    String? description,
    @Deprecated('Use imageThumbnail, imageMedium, or imageLarge')
    String? imageUrl,
    // R2 Image Storage (Cloudflare CDN)
    String? imageThumbnail, // 300×300 - for Grid/List
    String? imageMedium,    // 600×600 - for Quick View
    String? imageLarge,     // 1200×1200 - for Detail/Zoom
    String? imageHash,      // For cache versioning
    String? categoryId,
    required bool isActive,
    @Default(true) bool trackInventory,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  /// Calculate profit margin percentage
  double? get profitMargin {
    if (costPrice == null || costPrice == 0) return null;
    return ((price - costPrice!) / costPrice!) * 100;
  }

  /// Check if product is low on stock
  bool get isLowStock => stockQty <= minQty;

  /// Check if product is out of stock
  bool get isOutOfStock => stockQty <= 0;
}
