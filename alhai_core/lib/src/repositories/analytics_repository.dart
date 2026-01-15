import '../models/analytics.dart';
import '../models/sales_report.dart';

/// Repository contract for AI analytics operations
abstract class AnalyticsRepository {
  /// Gets slow moving products
  Future<List<SlowMovingProduct>> getSlowMovingProducts(
    String storeId, {
    int daysThreshold = 30,
    int limit = 20,
  });

  /// Gets sales forecast for upcoming days
  Future<List<SalesForecast>> getSalesForecast(
    String storeId, {
    int days = 7,
  });

  /// Gets smart alerts for store
  Future<List<SmartAlert>> getSmartAlerts(
    String storeId, {
    bool unreadOnly = false,
    int limit = 50,
  });

  /// Marks alert as read
  Future<void> markAlertRead(String alertId);

  /// Marks all alerts as read
  Future<void> markAllAlertsRead(String storeId);

  /// Gets reorder suggestions
  Future<List<ReorderSuggestion>> getReorderSuggestions(
    String storeId, {
    int daysAhead = 7,
  });

  /// Gets peak hours analysis
  Future<PeakHoursAnalysis> getPeakHoursAnalysis(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Gets customer buying patterns
  Future<List<CustomerPattern>> getCustomerPatterns(
    String storeId, {
    int limit = 20,
  });

  /// Gets dashboard summary with all key metrics
  Future<DashboardSummary> getDashboardSummary(String storeId);
}

/// Dashboard summary with all key metrics
class DashboardSummary {
  final SalesSummary todaySales;
  final int alertsCount;
  final int lowStockCount;
  final int slowMovingCount;
  final double revenueChange;
  final int pendingOrdersCount;
  final double totalDebtsAmount;

  const DashboardSummary({
    required this.todaySales,
    required this.alertsCount,
    required this.lowStockCount,
    required this.slowMovingCount,
    required this.revenueChange,
    required this.pendingOrdersCount,
    required this.totalDebtsAmount,
  });
}
