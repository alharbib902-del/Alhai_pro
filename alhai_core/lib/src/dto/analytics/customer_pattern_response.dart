import 'package:json_annotation/json_annotation.dart';
import '../../models/analytics.dart';

part 'customer_pattern_response.g.dart';

/// Response DTO for customer pattern
@JsonSerializable()
class CustomerPatternResponse {
  final String customerId;
  final String customerName;
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final List<String> frequentProducts;
  final int daysSinceLastOrder;
  final String? lastOrderDate;

  const CustomerPatternResponse({
    required this.customerId,
    required this.customerName,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    required this.frequentProducts,
    required this.daysSinceLastOrder,
    this.lastOrderDate,
  });

  factory CustomerPatternResponse.fromJson(Map<String, dynamic> json) =>
      _$CustomerPatternResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerPatternResponseToJson(this);

  /// Converts to domain model
  CustomerPattern toDomain() {
    return CustomerPattern(
      customerId: customerId,
      customerName: customerName,
      totalOrders: totalOrders,
      totalSpent: totalSpent,
      averageOrderValue: averageOrderValue,
      frequentProducts: frequentProducts,
      daysSinceLastOrder: daysSinceLastOrder,
      lastOrderDate: lastOrderDate != null ? DateTime.tryParse(lastOrderDate!) : null,
    );
  }
}
