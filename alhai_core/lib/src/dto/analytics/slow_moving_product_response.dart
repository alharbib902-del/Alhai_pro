import 'package:json_annotation/json_annotation.dart';
import '../../models/analytics.dart';

part 'slow_moving_product_response.g.dart';

/// Response DTO for slow moving product
@JsonSerializable()
class SlowMovingProductResponse {
  final String productId;
  final String productName;
  final String? categoryName;
  final int daysSinceLastSale;
  final int stockQty;
  final double stockValue;
  final double? suggestedDiscount;
  final String? lastSaleDate;

  const SlowMovingProductResponse({
    required this.productId,
    required this.productName,
    this.categoryName,
    required this.daysSinceLastSale,
    required this.stockQty,
    required this.stockValue,
    this.suggestedDiscount,
    this.lastSaleDate,
  });

  factory SlowMovingProductResponse.fromJson(Map<String, dynamic> json) =>
      _$SlowMovingProductResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SlowMovingProductResponseToJson(this);

  /// Converts to domain model
  SlowMovingProduct toDomain() {
    return SlowMovingProduct(
      productId: productId,
      productName: productName,
      categoryName: categoryName,
      daysSinceLastSale: daysSinceLastSale,
      stockQty: stockQty.toDouble(),
      stockValue: stockValue,
      suggestedDiscount: suggestedDiscount ?? 0,
      lastSaleDate: lastSaleDate != null
          ? DateTime.tryParse(lastSaleDate!)
          : null,
    );
  }
}
