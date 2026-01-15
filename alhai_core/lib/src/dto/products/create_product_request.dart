import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/create_product_params.dart';

part 'create_product_request.freezed.dart';
part 'create_product_request.g.dart';

/// DTO for create product request to API (snake_case) - Complete v3.2
@freezed
class CreateProductRequest with _$CreateProductRequest {
  const CreateProductRequest._();

  const factory CreateProductRequest({
    required String name,
    required double price,
    @JsonKey(name: 'store_id') required String storeId,
    @JsonKey(name: 'cost_price') double? costPrice,
    @JsonKey(name: 'stock_qty') @Default(0) int stockQty,
    @JsonKey(name: 'min_qty') @Default(1) int minQty,
    String? unit,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    String? barcode,
    String? sku,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'track_inventory') @Default(true) bool trackInventory,
  }) = _CreateProductRequest;

  factory CreateProductRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProductRequestFromJson(json);

  /// Creates DTO from Domain params
  factory CreateProductRequest.fromDomain(CreateProductParams params) {
    return CreateProductRequest(
      name: params.name,
      price: params.price,
      storeId: params.storeId,
      description: params.description,
      imageUrl: params.imageUrl,
      barcode: params.barcode,
      categoryId: params.categoryId,
      isActive: params.available,
    );
  }
}

