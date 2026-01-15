import '../models/paginated.dart';
import '../models/purchase_order.dart';

/// Repository contract for purchase order operations
abstract class PurchasesRepository {
  /// Gets purchase orders for a store
  Future<Paginated<PurchaseOrder>> getPurchaseOrders(
    String storeId, {
    PurchaseOrderStatus? status,
    String? supplierId,
    int page = 1,
    int limit = 20,
  });

  /// Gets a purchase order by ID
  Future<PurchaseOrder> getPurchaseOrder(String id);

  /// Creates a new purchase order
  Future<PurchaseOrder> createPurchaseOrder(CreatePurchaseOrderParams params);

  /// Updates a purchase order
  Future<PurchaseOrder> updatePurchaseOrder(
      String id, UpdatePurchaseOrderParams params);

  /// Cancels a purchase order
  Future<void> cancelPurchaseOrder(String id, {String? reason});

  /// Receives items from a purchase order
  Future<PurchaseOrder> receiveItems(
    String id,
    List<ReceivedItem> items,
  );

  /// Records payment for a purchase order
  Future<PurchaseOrder> recordPayment(String id, double amount);
}

/// Parameters for creating a purchase order
class CreatePurchaseOrderParams {
  final String storeId;
  final String supplierId;
  final List<PurchaseOrderItem> items;
  final double? discount;
  final double? tax;
  final String? notes;
  final DateTime? expectedDate;

  const CreatePurchaseOrderParams({
    required this.storeId,
    required this.supplierId,
    required this.items,
    this.discount,
    this.tax,
    this.notes,
    this.expectedDate,
  });
}

/// Parameters for updating a purchase order
class UpdatePurchaseOrderParams {
  final List<PurchaseOrderItem>? items;
  final double? discount;
  final double? tax;
  final String? notes;
  final DateTime? expectedDate;

  const UpdatePurchaseOrderParams({
    this.items,
    this.discount,
    this.tax,
    this.notes,
    this.expectedDate,
  });
}

/// Received item data
class ReceivedItem {
  final String productId;
  final int quantity;

  const ReceivedItem({
    required this.productId,
    required this.quantity,
  });
}
