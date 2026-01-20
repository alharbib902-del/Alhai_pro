import '../../dto/reports/sales_summary_response.dart';
import '../../dto/reports/product_sales_response.dart';
import '../../dto/reports/category_sales_response.dart';
import '../../dto/reports/inventory_value_response.dart';
import '../../dto/reports/monthly_comparison_response.dart';

/// Remote data source contract for reports API calls
abstract class ReportsRemoteDataSource {
  /// Gets daily sales summary
  Future<SalesSummaryResponse> getDailySummary(String storeId, String date);

  /// Gets sales summaries for date range
  Future<List<SalesSummaryResponse>> getSalesSummaries(
    String storeId, {
    required String startDate,
    required String endDate,
  });

  /// Gets top selling products
  Future<List<ProductSalesResponse>> getTopProducts(
    String storeId, {
    required String startDate,
    required String endDate,
    int limit = 10,
  });

  /// Gets sales by category
  Future<List<CategorySalesResponse>> getCategorySales(
    String storeId, {
    required String startDate,
    required String endDate,
  });

  /// Gets current inventory value
  Future<InventoryValueResponse> getInventoryValue(String storeId);

  /// Gets hourly sales distribution
  Future<Map<String, double>> getHourlySales(String storeId, String date);

  /// Gets monthly comparison
  Future<MonthlyComparisonResponse> getMonthlyComparison(
    String storeId, {
    required int year,
    required int month,
  });
}
