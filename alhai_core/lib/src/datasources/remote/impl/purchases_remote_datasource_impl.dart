import 'package:dio/dio.dart';

import '../../../dto/purchases/create_purchase_order_request.dart';
import '../../../dto/purchases/purchase_order_response.dart';
import '../../../dto/purchases/receive_items_request.dart';
import '../purchases_remote_datasource.dart';

/// Implementation of PurchasesRemoteDataSource
class PurchasesRemoteDataSourceImpl implements PurchasesRemoteDataSource {
  final Dio _dio;

  PurchasesRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<PurchaseOrderResponse>> getPurchaseOrders(
    String storeId, {
    String? status,
    String? supplierId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/purchase-orders',
      queryParameters: {
        'store_id': storeId,
        if (status != null) 'status': status,
        if (supplierId != null) 'supplier_id': supplierId,
        'page': page,
        'limit': limit,
      },
    );
    final list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => PurchaseOrderResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PurchaseOrderResponse> getPurchaseOrder(String id) async {
    final response = await _dio.get('/purchase-orders/$id');
    return PurchaseOrderResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PurchaseOrderResponse> createPurchaseOrder(
    CreatePurchaseOrderRequest request,
  ) async {
    final response = await _dio.post(
      '/purchase-orders',
      data: request.toJson(),
    );
    return PurchaseOrderResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PurchaseOrderResponse> updatePurchaseOrder(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch('/purchase-orders/$id', data: data);
    return PurchaseOrderResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cancelPurchaseOrder(String id, {String? reason}) async {
    await _dio.post(
      '/purchase-orders/$id/cancel',
      data: {if (reason != null) 'reason': reason},
    );
  }

  @override
  Future<PurchaseOrderResponse> receiveItems(
    String id,
    ReceiveItemsRequest request,
  ) async {
    final response = await _dio.post(
      '/purchase-orders/$id/receive',
      data: request.toJson(),
    );
    return PurchaseOrderResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PurchaseOrderResponse> recordPayment(String id, double amount) async {
    final response = await _dio.post(
      '/purchase-orders/$id/payment',
      data: {'amount': amount},
    );
    return PurchaseOrderResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
