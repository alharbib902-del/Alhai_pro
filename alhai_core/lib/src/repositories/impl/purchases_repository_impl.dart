import 'package:dio/dio.dart';

import '../../datasources/remote/purchases_remote_datasource.dart';
import '../../dto/purchases/create_purchase_order_request.dart';
import '../../dto/purchases/receive_items_request.dart';
import '../../exceptions/error_mapper.dart';
import '../../models/paginated.dart';
import '../../models/purchase_order.dart';
import '../purchases_repository.dart';

/// Implementation of PurchasesRepository
class PurchasesRepositoryImpl implements PurchasesRepository {
  final PurchasesRemoteDataSource _remote;

  PurchasesRepositoryImpl({required PurchasesRemoteDataSource remote})
    : _remote = remote;

  @override
  Future<Paginated<PurchaseOrder>> getPurchaseOrders(
    String storeId, {
    PurchaseOrderStatus? status,
    String? supplierId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final responses = await _remote.getPurchaseOrders(
        storeId,
        status: status?.name,
        supplierId: supplierId,
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
  Future<PurchaseOrder> getPurchaseOrder(String id) async {
    try {
      final response = await _remote.getPurchaseOrder(id);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<PurchaseOrder> createPurchaseOrder(
    CreatePurchaseOrderParams params,
  ) async {
    try {
      final request = CreatePurchaseOrderRequest.fromDomain(params);
      final response = await _remote.createPurchaseOrder(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<PurchaseOrder> updatePurchaseOrder(
    String id,
    UpdatePurchaseOrderParams params,
  ) async {
    try {
      final data = <String, dynamic>{};
      if (params.items != null) {
        data['items'] = params.items!
            .map((i) => PurchaseOrderItemRequest.fromDomain(i).toJson())
            .toList();
      }
      if (params.discount != null) data['discount'] = params.discount;
      if (params.tax != null) data['tax'] = params.tax;
      if (params.notes != null) data['notes'] = params.notes;
      if (params.expectedDate != null) {
        data['expectedDate'] = params.expectedDate!.toIso8601String();
      }

      final response = await _remote.updatePurchaseOrder(id, data);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<void> cancelPurchaseOrder(String id, {String? reason}) async {
    try {
      await _remote.cancelPurchaseOrder(id, reason: reason);
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<PurchaseOrder> receiveItems(
    String id,
    List<ReceivedItem> items,
  ) async {
    try {
      final request = ReceiveItemsRequest.fromDomain(items);
      final response = await _remote.receiveItems(id, request);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }

  @override
  Future<PurchaseOrder> recordPayment(String id, double amount) async {
    try {
      final response = await _remote.recordPayment(id, amount);
      return response.toDomain();
    } on DioException catch (e) {
      throw ErrorMapper.fromDioError(e);
    }
  }
}
