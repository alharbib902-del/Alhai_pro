import 'package:json_annotation/json_annotation.dart';
import '../../models/sales_report.dart';

part 'sales_summary_response.g.dart';

/// Response DTO for sales summary
@JsonSerializable()
class SalesSummaryResponse {
  final String date;
  final int ordersCount;
  final int itemsSold;
  final double revenue;
  final double cost;
  final double profit;
  final double? discounts;
  final double? returns;

  const SalesSummaryResponse({
    required this.date,
    required this.ordersCount,
    required this.itemsSold,
    required this.revenue,
    required this.cost,
    required this.profit,
    this.discounts,
    this.returns,
  });

  factory SalesSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$SalesSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SalesSummaryResponseToJson(this);

  /// Converts to domain model
  SalesSummary toDomain() {
    return SalesSummary(
      date: DateTime.tryParse(date) ?? DateTime.now(),
      ordersCount: ordersCount,
      itemsSold: itemsSold,
      revenue: revenue,
      cost: cost,
      profit: profit,
      discounts: discounts ?? 0,
      returns: returns ?? 0,
    );
  }
}
