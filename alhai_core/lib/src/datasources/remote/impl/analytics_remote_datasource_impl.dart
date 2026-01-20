import 'package:dio/dio.dart';

import '../../../dto/analytics/customer_pattern_response.dart';
import '../../../dto/analytics/dashboard_summary_response.dart';
import '../../../dto/analytics/peak_hours_analysis_response.dart';
import '../../../dto/analytics/reorder_suggestion_response.dart';
import '../../../dto/analytics/sales_forecast_response.dart';
import '../../../dto/analytics/slow_moving_product_response.dart';
import '../../../dto/analytics/smart_alert_response.dart';
import '../analytics_remote_datasource.dart';

/// Implementation of AnalyticsRemoteDataSource
class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final Dio _dio;

  AnalyticsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<DashboardSummaryResponse> getDashboardSummary(String storeId) async {
    final response = await _dio.get(
      '/analytics/dashboard',
      queryParameters: {'store_id': storeId},
    );
    return DashboardSummaryResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<SlowMovingProductResponse>> getSlowMovingProducts(
    String storeId, {
    int daysThreshold = 30,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/analytics/slow-moving',
      queryParameters: {
        'store_id': storeId,
        'days_threshold': daysThreshold,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SlowMovingProductResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SalesForecastResponse>> getSalesForecast(
    String storeId, {
    int days = 7,
  }) async {
    final response = await _dio.get(
      '/analytics/forecast',
      queryParameters: {
        'store_id': storeId,
        'days': days,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SalesForecastResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SmartAlertResponse>> getSmartAlerts(
    String storeId, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      '/analytics/alerts',
      queryParameters: {
        'store_id': storeId,
        'unread_only': unreadOnly,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SmartAlertResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    await _dio.patch('/analytics/alerts/$alertId/read');
  }

  @override
  Future<void> markAllAlertsRead(String storeId) async {
    await _dio.patch(
      '/analytics/alerts/read-all',
      queryParameters: {'store_id': storeId},
    );
  }

  @override
  Future<List<ReorderSuggestionResponse>> getReorderSuggestions(
    String storeId, {
    int daysAhead = 7,
  }) async {
    final response = await _dio.get(
      '/analytics/reorder-suggestions',
      queryParameters: {
        'store_id': storeId,
        'days_ahead': daysAhead,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => ReorderSuggestionResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PeakHoursAnalysisResponse> getPeakHoursAnalysis(
    String storeId, {
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.get(
      '/analytics/peak-hours',
      queryParameters: {
        'store_id': storeId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );
    return PeakHoursAnalysisResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<CustomerPatternResponse>> getCustomerPatterns(
    String storeId, {
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/analytics/customer-patterns',
      queryParameters: {
        'store_id': storeId,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => CustomerPatternResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
