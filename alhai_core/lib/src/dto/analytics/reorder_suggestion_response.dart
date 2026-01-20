import 'package:json_annotation/json_annotation.dart';
import '../../models/analytics.dart';

part 'reorder_suggestion_response.g.dart';

/// Response DTO for reorder suggestion
@JsonSerializable()
class ReorderSuggestionResponse {
  final String productId;
  final String productName;
  final int currentStock;
  final int suggestedQuantity;
  final double averageDailySales;
  final int daysUntilStockout;
  final String? preferredSupplierId;
  final String? preferredSupplierName;

  const ReorderSuggestionResponse({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.suggestedQuantity,
    required this.averageDailySales,
    required this.daysUntilStockout,
    this.preferredSupplierId,
    this.preferredSupplierName,
  });

  factory ReorderSuggestionResponse.fromJson(Map<String, dynamic> json) =>
      _$ReorderSuggestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ReorderSuggestionResponseToJson(this);

  /// Converts to domain model
  ReorderSuggestion toDomain() {
    return ReorderSuggestion(
      productId: productId,
      productName: productName,
      currentStock: currentStock,
      suggestedQuantity: suggestedQuantity,
      averageDailySales: averageDailySales,
      daysUntilStockout: daysUntilStockout,
      preferredSupplierId: preferredSupplierId,
      preferredSupplierName: preferredSupplierName,
    );
  }
}
