import 'package:json_annotation/json_annotation.dart';
import '../../models/sales_report.dart';

part 'product_sales_response.g.dart';

/// Response DTO for product sales
@JsonSerializable()
class ProductSalesResponse {
  final String productId;
  final String productName;
  final String? categoryId;
  final int quantitySold;
  final double revenue;
  final double cost;
  final double profit;

  const ProductSalesResponse({
    required this.productId,
    required this.productName,
    this.categoryId,
    required this.quantitySold,
    required this.revenue,
    required this.cost,
    required this.profit,
  });

  factory ProductSalesResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductSalesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProductSalesResponseToJson(this);

  /// Converts to domain model
  ProductSales toDomain() {
    return ProductSales(
      productId: productId,
      productName: productName,
      categoryId: categoryId,
      quantitySold: quantitySold,
      revenue: revenue,
      cost: cost,
      profit: profit,
    );
  }
}
