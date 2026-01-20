// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_purchase_order_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreatePurchaseOrderRequest _$CreatePurchaseOrderRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePurchaseOrderRequest(
      storeId: json['storeId'] as String,
      supplierId: json['supplierId'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              PurchaseOrderItemRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      discount: (json['discount'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      expectedDate: json['expectedDate'] as String?,
    );

Map<String, dynamic> _$CreatePurchaseOrderRequestToJson(
        CreatePurchaseOrderRequest instance) =>
    <String, dynamic>{
      'storeId': instance.storeId,
      'supplierId': instance.supplierId,
      'items': instance.items,
      'discount': instance.discount,
      'tax': instance.tax,
      'notes': instance.notes,
      'expectedDate': instance.expectedDate,
    };

PurchaseOrderItemRequest _$PurchaseOrderItemRequestFromJson(
        Map<String, dynamic> json) =>
    PurchaseOrderItemRequest(
      productId: json['productId'] as String,
      name: json['name'] as String,
      orderedQty: (json['orderedQty'] as num).toInt(),
      unitCost: (json['unitCost'] as num).toDouble(),
    );

Map<String, dynamic> _$PurchaseOrderItemRequestToJson(
        PurchaseOrderItemRequest instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'orderedQty': instance.orderedQty,
      'unitCost': instance.unitCost,
    };
