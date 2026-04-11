import '../models/sales_report.dart';

/// Repository contract for reports and analytics
abstract class ReportsRepository {
  /// Gets daily sales summary
  Future<SalesSummary> getDailySummary(String storeId, DateTime date);

  /// Gets sales summary for date range
  Future<List<SalesSummary>> getSalesSummaries(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets top selling products
  Future<List<ProductSales>> getTopProducts(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  });

  /// Gets sales by category
  Future<List<CategorySales>> getCategorySales(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets current inventory value
  Future<InventoryValue> getInventoryValue(String storeId);

  /// Gets hourly sales distribution
  Future<Map<int, double>> getHourlySales(String storeId, DateTime date);

  /// Gets monthly comparison
  Future<MonthlyComparison> getMonthlyComparison(
    String storeId, {
    required int year,
    required int month,
  });
}

/// Monthly comparison data
class MonthlyComparison {
  final double currentMonthRevenue;
  final double previousMonthRevenue;
  final double currentMonthProfit;
  final double previousMonthProfit;
  final int currentMonthOrders;
  final int previousMonthOrders;

  const MonthlyComparison({
    required this.currentMonthRevenue,
    required this.previousMonthRevenue,
    required this.currentMonthProfit,
    required this.previousMonthProfit,
    required this.currentMonthOrders,
    required this.previousMonthOrders,
  });

  double get revenueChange => previousMonthRevenue > 0
      ? ((currentMonthRevenue - previousMonthRevenue) / previousMonthRevenue) *
            100
      : 0;

  double get profitChange => previousMonthProfit > 0
      ? ((currentMonthProfit - previousMonthProfit) / previousMonthProfit) * 100
      : 0;

  double get ordersChange => previousMonthOrders > 0
      ? ((currentMonthOrders - previousMonthOrders) / previousMonthOrders) * 100
      : 0;
}
