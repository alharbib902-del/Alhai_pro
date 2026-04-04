import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_product_params.freezed.dart';
part 'create_product_params.g.dart';

/// Parameters for creating a new product (v3.2)
@freezed
class CreateProductParams with _$CreateProductParams {
  const factory CreateProductParams({
    /// Product name
    required String name,

    /// Product price
    required double price,

    /// Store ID
    required String storeId,

    /// Product description (optional)
    String? description,

    /// Product image URL (optional)
    String? imageUrl,

    /// Product barcode (optional)
    String? barcode,

    /// Category ID (optional)
    String? categoryId,

    /// Whether product is available
    @Default(true) bool available,
  }) = _CreateProductParams;

  factory CreateProductParams.fromJson(Map<String, dynamic> json) =>
      _$CreateProductParamsFromJson(json);
}
