import 'package:dio/dio.dart';

import '../../datasources/remote/inventory_remote_datasource.dart';
import '../../dto/inventory/adjust_stock_request.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/paginated.dart';
import '../../models/stock_adjustment.dart';
import '../inventory_repository.dart';

/// Implementation of InventoryRepository
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource _remote;

  InventoryRepositoryImpl({required InventoryRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Paginated<StockAdjustment>> getAdjustments(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getAdjustments(
        productId,
        page: page,
        limit: limit,
      );

      final items = responses.map((r) => r.toDomain()).toList();
      final hasMore = items.length >= limit;

      return Paginated(
        items: items,
        page: page,
        limit: limit,
        hasMore: hasMore,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<Paginated<StockAdjustment>> getStoreAdjustments(
    String storeId, {
    AdjustmentType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getStoreAdjustments(
        storeId,
        type: type?.name,
        page: page,
        limit: limit,
      );

      final items = responses.map((r) => r.toDomain()).toList();
      final hasMore = items.length >= limit;

      return Paginated(
        items: items,
        page: page,
        limit: limit,
        hasMore: hasMore,
      );
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<StockAdjustment> adjustStock({
    required String productId,
    required String storeId,
    required AdjustmentType type,
    required double quantity,
    String? reason,
    String? referenceId,
  }) async {
    try {
      final request = AdjustStockRequest(
        productId: productId,
        storeId: storeId,
        type: type.name,
        quantity: quantity,
        reason: reason,
        referenceId: referenceId,
      );
      final response = await _remote.adjustStock(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<LowStockProduct>> getLowStockProducts(String storeId) async {
    try {
      final responses = await _remote.getLowStockProducts(storeId);
      return responses.map((r) => r.toDomain()).toList();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<List<String>> getOutOfStockProductIds(String storeId) async {
    try {
      return await _remote.getOutOfStockProductIds(storeId);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
