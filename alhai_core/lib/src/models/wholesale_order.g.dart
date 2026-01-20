// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wholesale_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WholesaleOrderImpl _$$WholesaleOrderImplFromJson(Map<String, dynamic> json) =>
    _$WholesaleOrderImpl(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      distributorId: json['distributorId'] as String,
      storeId: json['storeId'] as String,
      storeName: json['storeName'] as String,
      status: $enumDecode(_$WholesaleOrderStatusEnumMap, json['status']),
      paymentMethod:
          $enumDecode(_$WholesalePaymentMethodEnumMap, json['paymentMethod']),
      items: (json['items'] as List<dynamic>)
          .map((e) => WholesaleOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      expectedDeliveryDate: json['expectedDeliveryDate'] == null
          ? null
          : DateTime.parse(json['expectedDeliveryDate'] as String),
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      shippedAt: json['shippedAt'] == null
          ? null
          : DateTime.parse(json['shippedAt'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancellationReason: json['cancellationReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$WholesaleOrderImplToJson(
        _$WholesaleOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderNumber': instance.orderNumber,
      'distributorId': instance.distributorId,
      'storeId': instance.storeId,
      'storeName': instance.storeName,
      'status': _$WholesaleOrderStatusEnumMap[instance.status]!,
      'paymentMethod': _$WholesalePaymentMethodEnumMap[instance.paymentMethod]!,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'tax': instance.tax,
      'total': instance.total,
      'notes': instance.notes,
      'deliveryAddress': instance.deliveryAddress,
      'expectedDeliveryDate': instance.expectedDeliveryDate?.toIso8601String(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'shippedAt': instance.shippedAt?.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancellationReason': instance.cancellationReason,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$WholesaleOrderStatusEnumMap = {
  WholesaleOrderStatus.pending: 'PENDING',
  WholesaleOrderStatus.confirmed: 'CONFIRMED',
  WholesaleOrderStatus.processing: 'PROCESSING',
  WholesaleOrderStatus.shipped: 'SHIPPED',
  WholesaleOrderStatus.delivered: 'DELIVERED',
  WholesaleOrderStatus.cancelled: 'CANCELLED',
};

const _$WholesalePaymentMethodEnumMap = {
  WholesalePaymentMethod.cash: 'CASH',
  WholesalePaymentMethod.bankTransfer: 'BANK_TRANSFER',
  WholesalePaymentMethod.credit: 'CREDIT',
  WholesalePaymentMethod.check: 'CHECK',
  WholesalePaymentMethod.app: 'APP',
};

_$WholesaleOrderItemImpl _$$WholesaleOrderItemImplFromJson(
        Map<String, dynamic> json) =>
    _$WholesaleOrderItemImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$WholesaleOrderItemImplToJson(
        _$WholesaleOrderItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'productSku': instance.productSku,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
      'discount': instance.discount,
      'unit': instance.unit,
    };
