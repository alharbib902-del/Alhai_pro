import 'package:json_annotation/json_annotation.dart';
import '../../models/purchase_order.dart';
import '../../repositories/purchases_repository.dart';

part 'create_purchase_order_request.g.dart';

/// Request DTO for creating a purchase order
@JsonSerializable()
class CreatePurchaseOrderRequest {
  final String storeId;
  final String supplierId;
  final List<PurchaseOrderItemRequest> items;
  final double? discount;
  final double? tax;
  final String? notes;
  final String? expectedDate;

  const CreatePurchaseOrderRequest({
    required this.storeId,
    required this.supplierId,
    required this.items,
    this.discount,
    this.tax,
    this.notes,
    this.expectedDate,
  });

  factory CreatePurchaseOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePurchaseOrderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePurchaseOrderRequestToJson(this);

  /// Creates from domain params
  factory CreatePurchaseOrderRequest.fromDomain(CreatePurchaseOrderParams params) {
    return CreatePurchaseOrderRequest(
      storeId: params.storeId,
      supplierId: params.supplierId,
      items: params.items.map((i) => PurchaseOrderItemRequest.fromDomain(i)).toList(),
      discount: params.discount,
      tax: params.tax,
      notes: params.notes,
      expectedDate: params.expectedDate?.toIso8601String(),
    );
  }
}

/// Request DTO for purchase order item
@JsonSerializable()
class PurchaseOrderItemRequest {
  final String productId;
  final String name;
  final int orderedQty;
  final double unitCost;

  const PurchaseOrderItemRequest({
    required this.productId,
    required this.name,
    required this.orderedQty,
    required this.unitCost,
  });

  factory PurchaseOrderItemRequest.fromJson(Map<String, dynamic> json) =>
      _$PurchaseOrderItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseOrderItemRequestToJson(this);

  /// Creates from domain model
  factory PurchaseOrderItemRequest.fromDomain(PurchaseOrderItem item) {
    return PurchaseOrderItemRequest(
      productId: item.productId,
      name: item.name,
      orderedQty: item.orderedQty,
      unitCost: item.unitCost,
    );
  }
}
