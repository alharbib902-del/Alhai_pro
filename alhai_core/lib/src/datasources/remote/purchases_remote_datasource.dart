import '../../config/app_limits.dart';
import '../../dto/purchases/purchase_order_response.dart';
import '../../dto/purchases/create_purchase_order_request.dart';
import '../../dto/purchases/receive_items_request.dart';

/// Remote data source contract for purchases API calls
abstract class PurchasesRemoteDataSource {
  /// Gets purchase orders for a store
  Future<List<PurchaseOrderResponse>> getPurchaseOrders(
    String storeId, {
    String? status,
    String? supplierId,
    int page = 1,
    int limit = AppLimits.defaultPageSize,
  });

  /// Gets a purchase order by ID
  Future<PurchaseOrderResponse> getPurchaseOrder(String id);

  /// Creates a new purchase order
  Future<PurchaseOrderResponse> createPurchaseOrder(CreatePurchaseOrderRequest request);

  /// Updates a purchase order
  Future<PurchaseOrderResponse> updatePurchaseOrder(
    String id,
    Map<String, dynamic> data,
  );

  /// Cancels a purchase order
  Future<void> cancelPurchaseOrder(String id, {String? reason});

  /// Receives items from a purchase order
  Future<PurchaseOrderResponse> receiveItems(String id, ReceiveItemsRequest request);

  /// Records payment for a purchase order
  Future<PurchaseOrderResponse> recordPayment(String id, double amount);
}
