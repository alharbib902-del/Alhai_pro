import 'package:json_annotation/json_annotation.dart';
import '../../repositories/analytics_repository.dart';
import '../reports/sales_summary_response.dart';

part 'dashboard_summary_response.g.dart';

/// Response DTO for dashboard summary
@JsonSerializable()
class DashboardSummaryResponse {
  final SalesSummaryResponse todaySales;
  final int alertsCount;
  final int lowStockCount;
  final int slowMovingCount;
  final double revenueChange;
  final int pendingOrdersCount;
  final double totalDebtsAmount;

  const DashboardSummaryResponse({
    required this.todaySales,
    required this.alertsCount,
    required this.lowStockCount,
    required this.slowMovingCount,
    required this.revenueChange,
    required this.pendingOrdersCount,
    required this.totalDebtsAmount,
  });

  factory DashboardSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$DashboardSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardSummaryResponseToJson(this);

  /// Converts to domain model
  DashboardSummary toDomain() {
    return DashboardSummary(
      todaySales: todaySales.toDomain(),
      alertsCount: alertsCount,
      lowStockCount: lowStockCount,
      slowMovingCount: slowMovingCount,
      revenueChange: revenueChange,
      pendingOrdersCount: pendingOrdersCount,
      totalDebtsAmount: totalDebtsAmount,
    );
  }
}
