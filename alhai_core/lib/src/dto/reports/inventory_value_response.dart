import 'package:json_annotation/json_annotation.dart';
import '../../models/sales_report.dart';

part 'inventory_value_response.g.dart';

/// Response DTO for inventory value
@JsonSerializable()
class InventoryValueResponse {
  final int totalProducts;
  final int totalUnits;
  final double costValue;
  final double retailValue;
  final int lowStockCount;
  final int outOfStockCount;

  const InventoryValueResponse({
    required this.totalProducts,
    required this.totalUnits,
    required this.costValue,
    required this.retailValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  factory InventoryValueResponse.fromJson(Map<String, dynamic> json) =>
      _$InventoryValueResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryValueResponseToJson(this);

  /// Converts to domain model
  InventoryValue toDomain() {
    return InventoryValue(
      totalProducts: totalProducts,
      totalUnits: totalUnits,
      costValue: costValue,
      retailValue: retailValue,
      lowStockCount: lowStockCount,
      outOfStockCount: outOfStockCount,
    );
  }
}
