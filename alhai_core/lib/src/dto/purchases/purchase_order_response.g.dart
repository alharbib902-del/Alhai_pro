// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseOrderResponse _$PurchaseOrderResponseFromJson(
        Map<String, dynamic> json) =>
    PurchaseOrderResponse(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String?,
      storeId: json['storeId'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) =>
              PurchaseOrderItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num).toDouble(),
      notes: json['notes'] as String?,
      expectedDate: json['expectedDate'] as String?,
      receivedDate: json['receivedDate'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$PurchaseOrderResponseToJson(
        PurchaseOrderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'storeId': instance.storeId,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'status': instance.status,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'total': instance.total,
      'paidAmount': instance.paidAmount,
      'notes': instance.notes,
      'expectedDate': instance.expectedDate,
      'receivedDate': instance.receivedDate,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

PurchaseOrderItemResponse _$PurchaseOrderItemResponseFromJson(
        Map<String, dynamic> json) =>
    PurchaseOrderItemResponse(
      productId: json['productId'] as String,
      name: json['name'] as String,
      orderedQty: (json['orderedQty'] as num).toInt(),
      receivedQty: (json['receivedQty'] as num).toInt(),
      unitCost: (json['unitCost'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );

Map<String, dynamic> _$PurchaseOrderItemResponseToJson(
        PurchaseOrderItemResponse instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'orderedQty': instance.orderedQty,
      'receivedQty': instance.receivedQty,
      'unitCost': instance.unitCost,
      'lineTotal': instance.lineTotal,
    };
