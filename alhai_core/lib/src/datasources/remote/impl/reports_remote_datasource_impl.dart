import 'package:dio/dio.dart';

import '../../../dto/reports/category_sales_response.dart';
import '../../../dto/reports/inventory_value_response.dart';
import '../../../dto/reports/monthly_comparison_response.dart';
import '../../../dto/reports/product_sales_response.dart';
import '../../../dto/reports/sales_summary_response.dart';
import '../reports_remote_datasource.dart';

/// Implementation of ReportsRemoteDataSource
class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Dio _dio;

  ReportsRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<SalesSummaryResponse> getDailySummary(
      String storeId, String date) async {
    final response = await _dio.get(
      '/reports/daily-summary',
      queryParameters: {
        'store_id': storeId,
        'date': date,
      },
    );
    return SalesSummaryResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<SalesSummaryResponse>> getSalesSummaries(
    String storeId, {
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get(
      '/reports/sales-summaries',
      queryParameters: {
        'store_id': storeId,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => SalesSummaryResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductSalesResponse>> getTopProducts(
    String storeId, {
    required String startDate,
    required String endDate,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/reports/top-products',
      queryParameters: {
        'store_id': storeId,
        'start_date': startDate,
        'end_date': endDate,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => ProductSalesResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CategorySalesResponse>> getCategorySales(
    String storeId, {
    required String startDate,
    required String endDate,
  }) async {
    final response = await _dio.get(
      '/reports/category-sales',
      queryParameters: {
        'store_id': storeId,
        'start_date': startDate,
        'end_date': endDate,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => CategorySalesResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<InventoryValueResponse> getInventoryValue(String storeId) async {
    final response = await _dio.get(
      '/reports/inventory-value',
      queryParameters: {'store_id': storeId},
    );
    return InventoryValueResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, double>> getHourlySales(
      String storeId, String date) async {
    final response = await _dio.get(
      '/reports/hourly-sales',
      queryParameters: {
        'store_id': storeId,
        'date': date,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, (value as num).toDouble()));
  }

  @override
  Future<MonthlyComparisonResponse> getMonthlyComparison(
    String storeId, {
    required int year,
    required int month,
  }) async {
    final response = await _dio.get(
      '/reports/monthly-comparison',
      queryParameters: {
        'store_id': storeId,
        'year': year,
        'month': month,
      },
    );
    return MonthlyComparisonResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
