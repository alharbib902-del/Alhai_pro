import 'package:json_annotation/json_annotation.dart';
import '../../repositories/reports_repository.dart';

part 'monthly_comparison_response.g.dart';

/// Response DTO for monthly comparison
@JsonSerializable()
class MonthlyComparisonResponse {
  final double currentMonthRevenue;
  final double previousMonthRevenue;
  final double currentMonthProfit;
  final double previousMonthProfit;
  final int currentMonthOrders;
  final int previousMonthOrders;

  const MonthlyComparisonResponse({
    required this.currentMonthRevenue,
    required this.previousMonthRevenue,
    required this.currentMonthProfit,
    required this.previousMonthProfit,
    required this.currentMonthOrders,
    required this.previousMonthOrders,
  });

  factory MonthlyComparisonResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlyComparisonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyComparisonResponseToJson(this);

  /// Converts to domain model
  MonthlyComparison toDomain() {
    return MonthlyComparison(
      currentMonthRevenue: currentMonthRevenue,
      previousMonthRevenue: previousMonthRevenue,
      currentMonthProfit: currentMonthProfit,
      previousMonthProfit: previousMonthProfit,
      currentMonthOrders: currentMonthOrders,
      previousMonthOrders: previousMonthOrders,
    );
  }
}
