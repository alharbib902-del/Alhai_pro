// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RefundImpl _$$RefundImplFromJson(Map<String, dynamic> json) => _$RefundImpl(
  id: json['id'] as String,
  originalSaleId: json['originalSaleId'] as String,
  storeId: json['storeId'] as String,
  cashierId: json['cashierId'] as String,
  customerId: json['customerId'] as String?,
  status: $enumDecode(_$RefundStatusEnumMap, json['status']),
  reason: $enumDecode(_$RefundReasonEnumMap, json['reason']),
  method: $enumDecode(_$RefundMethodEnumMap, json['method']),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  items: (json['items'] as List<dynamic>)
      .map((e) => RefundItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  notes: json['notes'] as String?,
  supervisorId: json['supervisorId'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
);

Map<String, dynamic> _$$RefundImplToJson(_$RefundImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'originalSaleId': instance.originalSaleId,
      'storeId': instance.storeId,
      'cashierId': instance.cashierId,
      'customerId': instance.customerId,
      'status': _$RefundStatusEnumMap[instance.status]!,
      'reason': _$RefundReasonEnumMap[instance.reason]!,
      'method': _$RefundMethodEnumMap[instance.method]!,
      'totalAmount': instance.totalAmount,
      'items': instance.items,
      'notes': instance.notes,
      'supervisorId': instance.supervisorId,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

const _$RefundStatusEnumMap = {
  RefundStatus.pending: 'PENDING',
  RefundStatus.approved: 'APPROVED',
  RefundStatus.completed: 'COMPLETED',
  RefundStatus.rejected: 'REJECTED',
};

const _$RefundReasonEnumMap = {
  RefundReason.customerRequest: 'CUSTOMER_REQUEST',
  RefundReason.defectiveProduct: 'DEFECTIVE_PRODUCT',
  RefundReason.wrongItem: 'WRONG_ITEM',
  RefundReason.expiredProduct: 'EXPIRED_PRODUCT',
  RefundReason.priceError: 'PRICE_ERROR',
  RefundReason.other: 'OTHER',
};

const _$RefundMethodEnumMap = {
  RefundMethod.cash: 'CASH',
  RefundMethod.card: 'CARD',
  RefundMethod.credit: 'CREDIT',
};

_$RefundItemImpl _$$RefundItemImplFromJson(Map<String, dynamic> json) =>
    _$RefundItemImpl(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      reason: json['reason'] as String?,
    );

Map<String, dynamic> _$$RefundItemImplToJson(_$RefundItemImpl instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalAmount': instance.totalAmount,
      'reason': instance.reason,
    };
