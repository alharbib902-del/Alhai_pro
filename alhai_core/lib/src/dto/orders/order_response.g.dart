// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OrderResponseImpl _$$OrderResponseImplFromJson(Map<String, dynamic> json) =>
    _$OrderResponseImpl(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String?,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String?,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      isPaid: json['is_paid'] as bool? ?? false,
      addressId: json['address_id'] as String?,
      notes: json['notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      confirmedAt: json['confirmed_at'] as String?,
      preparingAt: json['preparing_at'] as String?,
      readyAt: json['ready_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$OrderResponseImplToJson(_$OrderResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'store_id': instance.storeId,
      'store_name': instance.storeName,
      'status': instance.status,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'discount': instance.discount,
      'delivery_fee': instance.deliveryFee,
      'tax': instance.tax,
      'total': instance.total,
      'payment_method': instance.paymentMethod,
      'is_paid': instance.isPaid,
      'address_id': instance.addressId,
      'notes': instance.notes,
      'cancellation_reason': instance.cancellationReason,
      'confirmed_at': instance.confirmedAt,
      'preparing_at': instance.preparingAt,
      'ready_at': instance.readyAt,
      'delivered_at': instance.deliveredAt,
      'cancelled_at': instance.cancelledAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
