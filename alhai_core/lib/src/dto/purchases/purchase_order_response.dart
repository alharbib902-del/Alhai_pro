import 'package:json_annotation/json_annotation.dart';
import '../../models/purchase_order.dart';

part 'purchase_order_response.g.dart';

/// Response DTO for purchase order from API
@JsonSerializable()
class PurchaseOrderResponse {
  final String id;
  final String? orderNumber;
  final String storeId;
  final String supplierId;
  final String? supplierName;
  final String status;
  final List<PurchaseOrderItemResponse> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double paidAmount;
  final String? notes;
  final String? expectedDate;
  final String? receivedDate;
  final String createdAt;
  final String? updatedAt;

  const PurchaseOrderResponse({
    required this.id,
    this.orderNumber,
    required this.storeId,
    required this.supplierId,
    this.supplierName,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.paidAmount,
    this.notes,
    this.expectedDate,
    this.receivedDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory PurchaseOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderResponseToJson(this);

  /// Converts to domain model
  PurchaseOrder toDomain() {
    return PurchaseOrder(
      id: id,
      orderNumber: orderNumber,
      storeId: storeId,
      supplierId: supplierId,
      supplierName: supplierName,
      status: PurchaseOrderStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => PurchaseOrderStatus.draft,
      ),
      items: items.map((i) => i.toDomain()).toList(),
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      paidAmount: paidAmount,
      notes: notes,
      expectedDate: expectedDate != null ? DateTime.parse(expectedDate!) : null,
      receivedDate: receivedDate != null ? DateTime.parse(receivedDate!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}

/// Response DTO for purchase order item
@JsonSerializable()
class PurchaseOrderItemResponse {
  final String productId;
  final String name;
  final int orderedQty;
  final int receivedQty;
  final double unitCost;
  final double lineTotal;

  const PurchaseOrderItemResponse({
    required this.productId,
    required this.name,
    required this.orderedQty,
    required this.receivedQty,
    required this.unitCost,
    required this.lineTotal,
  });

  factory PurchaseOrderItemResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderItemResponseToJson(this);

  /// Converts to domain model
  PurchaseOrderItem toDomain() {
    return PurchaseOrderItem(
      productId: productId,
      name: name,
      orderedQty: orderedQty,
      receivedQty: receivedQty,
      unitCost: unitCost,
      lineTotal: lineTotal,
    );
  }
}
