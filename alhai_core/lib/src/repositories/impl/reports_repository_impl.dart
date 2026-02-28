import 'package:dio/dio.dart';

import '../../datasources/remote/reports_remote_datasource.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/sales_report.dart';
import '../reports_repository.dart';

/// Implementation of ReportsRepository
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource _remote;

  ReportsRepositoryImpl({
    required ReportsRemoteDataSource remote,
  }) : _remote = remote;

  @override
  Future<SalesSummary> getDailySummary(String storeId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final response = await _remote.getDailySummary(storeId, dateStr);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<SalesSummary>> getSalesSummaries(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;
      final responses = await _remote.getSalesSummaries(
        storeId,
        startDate: startStr,
        endDate: endStr,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<ProductSales>> getTopProducts(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
    int limit = 10,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;
      final responses = await _remote.getTopProducts(
        storeId,
        startDate: startStr,
        endDate: endStr,
        limit: limit,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<CategorySales>> getCategorySales(
    String storeId, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final startStr = startDate.toIso8601String().split('T').first;
      final endStr = endDate.toIso8601String().split('T').first;
      final responses = await _remote.getCategorySales(
        storeId,
        startDate: startStr,
        endDate: endStr,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<InventoryValue> getInventoryValue(String storeId) async {
    try {
      final response = await _remote.getInventoryValue(storeId);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Map<int, double>> getHourlySales(String storeId, DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;
      final response = await _remote.getHourlySales(storeId, dateStr);
      return response.map((k, v) => MapEntry(int.tryParse(k) ?? 0, v));
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<MonthlyComparison> getMonthlyComparison(
    String storeId, {
    required int year,
    required int month,
  }) async {
    try {
      final response = await _remote.getMonthlyComparison(
        storeId,
        year: year,
        month: month,
      );
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
