import 'package:json_annotation/json_annotation.dart';
import '../../repositories/inventory_repository.dart';

part 'low_stock_product_response.g.dart';

/// Response DTO for low stock product
@JsonSerializable()
class LowStockProductResponse {
  final String productId;
  final String productName;
  final double currentQty;
  final double minQty;

  const LowStockProductResponse({
    required this.productId,
    required this.productName,
    required this.currentQty,
    required this.minQty,
  });

  factory LowStockProductResponse.fromJson(Map<String, dynamic> json) =>
      _$LowStockProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LowStockProductResponseToJson(this);

  /// Converts to domain model
  LowStockProduct toDomain() {
    return LowStockProduct(
      productId: productId,
      productName: productName,
      currentQty: currentQty,
      minQty: minQty,
    );
  }
}
