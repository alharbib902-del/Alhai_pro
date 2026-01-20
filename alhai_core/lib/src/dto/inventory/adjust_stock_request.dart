import 'package:json_annotation/json_annotation.dart';

part 'adjust_stock_request.g.dart';

/// Request DTO for adjusting stock
@JsonSerializable()
class AdjustStockRequest {
  final String productId;
  final String storeId;
  final String type;
  final int quantity;
  final String? reason;
  final String? referenceId;

  const AdjustStockRequest({
    required this.productId,
    required this.storeId,
    required this.type,
    required this.quantity,
    this.reason,
    this.referenceId,
  });

  factory AdjustStockRequest.fromJson(Map<String, dynamic> json) =>
      _$AdjustStockRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdjustStockRequestToJson(this);
}
