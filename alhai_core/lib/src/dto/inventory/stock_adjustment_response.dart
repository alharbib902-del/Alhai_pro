import 'package:json_annotation/json_annotation.dart';
import '../../models/stock_adjustment.dart';

part 'stock_adjustment_response.g.dart';

/// Response DTO for stock adjustment from API
@JsonSerializable()
class StockAdjustmentResponse {
  final String id;
  final String productId;
  final String storeId;
  final String type;
  final int quantity;
  final int previousQty;
  final int newQty;
  final String? reason;
  final String? referenceId;
  final String? createdBy;
  final String createdAt;

  const StockAdjustmentResponse({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.type,
    required this.quantity,
    required this.previousQty,
    required this.newQty,
    this.reason,
    this.referenceId,
    this.createdBy,
    required this.createdAt,
  });

  factory StockAdjustmentResponse.fromJson(Map<String, dynamic> json) =>
      _$StockAdjustmentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StockAdjustmentResponseToJson(this);

  /// Converts to domain model
  StockAdjustment toDomain() {
    return StockAdjustment(
      id: id,
      productId: productId,
      storeId: storeId,
      type: AdjustmentType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => AdjustmentType.correction,
      ),
      quantity: quantity,
      previousQty: previousQty,
      newQty: newQty,
      reason: reason,
      referenceId: referenceId,
      createdBy: createdBy,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }
}
