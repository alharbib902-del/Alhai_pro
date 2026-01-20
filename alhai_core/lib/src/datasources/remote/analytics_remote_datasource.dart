import '../../dto/analytics/slow_moving_product_response.dart';
import '../../dto/analytics/sales_forecast_response.dart';
import '../../dto/analytics/smart_alert_response.dart';
import '../../dto/analytics/reorder_suggestion_response.dart';
import '../../dto/analytics/peak_hours_analysis_response.dart';
import '../../dto/analytics/customer_pattern_response.dart';
import '../../dto/analytics/dashboard_summary_response.dart';

/// Remote data source contract for analytics API calls
abstract class AnalyticsRemoteDataSource {
  /// Gets slow moving products
  Future<List<SlowMovingProductResponse>> getSlowMovingProducts(
    String storeId, {
    int daysThreshold = 30,
    int limit = 20,
  });

  /// Gets sales forecast
  Future<List<SalesForecastResponse>> getSalesForecast(
    String storeId, {
    int days = 7,
  });

  /// Gets smart alerts
  Future<List<SmartAlertResponse>> getSmartAlerts(
    String storeId, {
    bool unreadOnly = false,
    int limit = 50,
  });

  /// Marks an alert as read
  Future<void> markAlertRead(String alertId);

  /// Marks all alerts as read
  Future<void> markAllAlertsRead(String storeId);

  /// Gets reorder suggestions
  Future<List<ReorderSuggestionResponse>> getReorderSuggestions(
    String storeId, {
    int daysAhead = 7,
  });

  /// Gets peak hours analysis
  Future<PeakHoursAnalysisResponse> getPeakHoursAnalysis(
    String storeId, {
    String? startDate,
    String? endDate,
  });

  /// Gets customer patterns
  Future<List<CustomerPatternResponse>> getCustomerPatterns(
    String storeId, {
    int limit = 20,
  });

  /// Gets dashboard summary
  Future<DashboardSummaryResponse> getDashboardSummary(String storeId);
}
