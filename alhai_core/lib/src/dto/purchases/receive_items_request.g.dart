// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receive_items_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiveItemsRequest _$ReceiveItemsRequestFromJson(Map<String, dynamic> json) =>
    ReceiveItemsRequest(
      items: (json['items'] as List<dynamic>)
          .map((e) => ReceivedItemRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReceiveItemsRequestToJson(
  ReceiveItemsRequest instance,
) => <String, dynamic>{'items': instance.items};

ReceivedItemRequest _$ReceivedItemRequestFromJson(Map<String, dynamic> json) =>
    ReceivedItemRequest(
      productId: json['productId'] as String,
      quantity: (json['quantity'] as num).toInt(),
    );

Map<String, dynamic> _$ReceivedItemRequestToJson(
  ReceivedItemRequest instance,
) => <String, dynamic>{
  'productId': instance.productId,
  'quantity': instance.quantity,
};
