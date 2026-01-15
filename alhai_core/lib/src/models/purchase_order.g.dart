// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseOrderImpl _$$PurchaseOrderImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseOrderImpl(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String?,
      storeId: json['storeId'] as String,
      supplierId: json['supplierId'] as String,
      supplierName: json['supplierName'] as String?,
      status: $enumDecode(_$PurchaseOrderStatusEnumMap, json['status']),
      items: (json['items'] as List<dynamic>)
          .map((e) => PurchaseOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      expectedDate: json['expectedDate'] == null
          ? null
          : DateTime.parse(json['expectedDate'] as String),
      receivedDate: json['receivedDate'] == null
          ? null
          : DateTime.parse(json['receivedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PurchaseOrderImplToJson(_$PurchaseOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'storeId': instance.storeId,
      'supplierId': instance.supplierId,
      'supplierName': instance.supplierName,
      'status': _$PurchaseOrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'total': instance.total,
      'paidAmount': instance.paidAmount,
      'notes': instance.notes,
      'expectedDate': instance.expectedDate?.toIso8601String(),
      'receivedDate': instance.receivedDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PurchaseOrderStatusEnumMap = {
  PurchaseOrderStatus.draft: 'draft',
  PurchaseOrderStatus.ordered: 'ordered',
  PurchaseOrderStatus.partiallyReceived: 'partiallyReceived',
  PurchaseOrderStatus.received: 'received',
  PurchaseOrderStatus.cancelled: 'cancelled',
};

_$PurchaseOrderItemImpl _$$PurchaseOrderItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseOrderItemImpl(
      productId: json['productId'] as String,
      name: json['name'] as String,
      orderedQty: (json['orderedQty'] as num).toInt(),
      receivedQty: (json['receivedQty'] as num?)?.toInt() ?? 0,
      unitCost: (json['unitCost'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );

Map<String, dynamic> _$$PurchaseOrderItemImplToJson(
        _$PurchaseOrderItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'name': instance.name,
      'orderedQty': instance.orderedQty,
      'receivedQty': instance.receivedQty,
      'unitCost': instance.unitCost,
      'lineTotal': instance.lineTotal,
    };
