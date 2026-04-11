import 'package:dio/dio.dart';

import '../../datasources/remote/analytics_remote_datasource.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/analytics.dart';
import '../analytics_repository.dart';

/// Implementation of AnalyticsRepository
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource _remote;

  AnalyticsRepositoryImpl({required AnalyticsRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<List<SlowMovingProduct>> getSlowMovingProducts(
    String storeId, {
    int daysThreshold = 30,
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getSlowMovingProducts(
        storeId,
        daysThreshold: daysThreshold,
        limit: limit,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<SalesForecast>> getSalesForecast(
    String storeId, {
    int days = 7,
  }) async {
    try {
      final responses = await _remote.getSalesForecast(storeId, days: days);
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<SmartAlert>> getSmartAlerts(
    String storeId, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final responses = await _remote.getSmartAlerts(
        storeId,
        unreadOnly: unreadOnly,
        limit: limit,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> markAlertRead(String alertId) async {
    try {
      await _remote.markAlertRead(alertId);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> markAllAlertsRead(String storeId) async {
    try {
      await _remote.markAllAlertsRead(storeId);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<ReorderSuggestion>> getReorderSuggestions(
    String storeId, {
    int daysAhead = 7,
  }) async {
    try {
      final responses = await _remote.getReorderSuggestions(
        storeId,
        daysAhead: daysAhead,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<PeakHoursAnalysis> getPeakHoursAnalysis(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _remote.getPeakHoursAnalysis(
        storeId,
        startDate: startDate?.toIso8601String().split('T').first,
        endDate: endDate?.toIso8601String().split('T').first,
      );
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<CustomerPattern>> getCustomerPatterns(
    String storeId, {
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getCustomerPatterns(
        storeId,
        limit: limit,
      );
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<DashboardSummary> getDashboardSummary(String storeId) async {
    try {
      final response = await _remote.getDashboardSummary(storeId);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
