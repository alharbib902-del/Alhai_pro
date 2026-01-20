import 'package:json_annotation/json_annotation.dart';
import '../../models/sales_report.dart';

part 'category_sales_response.g.dart';

/// Response DTO for category sales
@JsonSerializable()
class CategorySalesResponse {
  final String categoryId;
  final String categoryName;
  final int productsSold;
  final double revenue;
  final double profit;

  const CategorySalesResponse({
    required this.categoryId,
    required this.categoryName,
    required this.productsSold,
    required this.revenue,
    required this.profit,
  });

  factory CategorySalesResponse.fromJson(Map<String, dynamic> json) =>
      _$CategorySalesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CategorySalesResponseToJson(this);

  /// Converts to domain model
  CategorySales toDomain() {
    return CategorySales(
      categoryId: categoryId,
      categoryName: categoryName,
      productsSold: productsSold,
      revenue: revenue,
      profit: profit,
    );
  }
}
