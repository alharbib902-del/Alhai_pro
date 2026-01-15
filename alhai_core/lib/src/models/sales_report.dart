import 'package:freezed_annotation/freezed_annotation.dart';

part 'sales_report.freezed.dart';
part 'sales_report.g.dart';

/// Daily/Period sales summary
@freezed
class SalesSummary with _$SalesSummary {
  const SalesSummary._();

  const factory SalesSummary({
    required DateTime date,
    required int ordersCount,
    required int itemsSold,
    required double revenue,
    required double cost,
    required double profit,
    @Default(0) double discounts,
    @Default(0) double returns,
  }) = _SalesSummary;

  factory SalesSummary.fromJson(Map<String, dynamic> json) =>
      _$SalesSummaryFromJson(json);

  /// Profit margin percentage
  double get profitMargin => revenue > 0 ? (profit / revenue) * 100 : 0;

  /// Average order value
  double get averageOrderValue => ordersCount > 0 ? revenue / ordersCount : 0;
}

/// Product sales data
@freezed
class ProductSales with _$ProductSales {
  const ProductSales._();

  const factory ProductSales({
    required String productId,
    required String productName,
    String? categoryId,
    required int quantitySold,
    required double revenue,
    required double cost,
    required double profit,
  }) = _ProductSales;

  factory ProductSales.fromJson(Map<String, dynamic> json) =>
      _$ProductSalesFromJson(json);

  /// Profit margin percentage
  double get profitMargin => revenue > 0 ? (profit / revenue) * 100 : 0;
}

/// Category sales data
@freezed
class CategorySales with _$CategorySales {
  const factory CategorySales({
    required String categoryId,
    required String categoryName,
    required int productsSold,
    required double revenue,
    required double profit,
  }) = _CategorySales;

  factory CategorySales.fromJson(Map<String, dynamic> json) =>
      _$CategorySalesFromJson(json);
}

/// Inventory value summary
@freezed
class InventoryValue with _$InventoryValue {
  const factory InventoryValue({
    required int totalProducts,
    required int totalUnits,
    required double costValue,
    required double retailValue,
    required int lowStockCount,
    required int outOfStockCount,
  }) = _InventoryValue;

  factory InventoryValue.fromJson(Map<String, dynamic> json) =>
      _$InventoryValueFromJson(json);
}
