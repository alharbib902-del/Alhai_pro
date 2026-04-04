import 'package:json_annotation/json_annotation.dart';
import '../../repositories/purchases_repository.dart';

part 'receive_items_request.g.dart';

/// Request DTO for receiving items from a purchase order
@JsonSerializable()
class ReceiveItemsRequest {
  final List<ReceivedItemRequest> items;

  const ReceiveItemsRequest({
    required this.items,
  });

  factory ReceiveItemsRequest.fromJson(Map<String, dynamic> json) =>
      _$ReceiveItemsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReceiveItemsRequestToJson(this);

  /// Creates from domain list
  factory ReceiveItemsRequest.fromDomain(List<ReceivedItem> items) {
    return ReceiveItemsRequest(
      items: items
          .map((i) => ReceivedItemRequest(
                productId: i.productId,
                quantity: i.quantity,
              ))
          .toList(),
    );
  }
}

/// Request DTO for a received item
@JsonSerializable()
class ReceivedItemRequest {
  final String productId;
  final int quantity;

  const ReceivedItemRequest({
    required this.productId,
    required this.quantity,
  });

  factory ReceivedItemRequest.fromJson(Map<String, dynamic> json) =>
      _$ReceivedItemRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReceivedItemRequestToJson(this);
}
