/// Distributor order item model.
///
/// Maps to the Supabase `order_items` table with a join on `products`.
library;

class DistributorOrderItem {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double suggestedPrice;
  final double? distributorPrice;
  final String? barcode;

  const DistributorOrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.suggestedPrice,
    this.distributorPrice,
    this.barcode,
  });

  double get suggestedTotal => quantity * suggestedPrice;
  double get distributorTotal =>
      distributorPrice != null ? quantity * distributorPrice! : 0;

  factory DistributorOrderItem.fromJson(Map<String, dynamic> json) {
    final productName = json['products'] is Map
        ? (json['products']['name'] as String? ?? '')
        : (json['product_name'] as String? ?? '');
    final barcode = json['products'] is Map
        ? (json['products']['barcode'] as String?)
        : (json['barcode'] as String?);

    return DistributorOrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: productName,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      suggestedPrice: (json['unit_price'] as num?)?.toDouble() ?? 0,
      distributorPrice: (json['distributor_price'] as num?)?.toDouble(),
      barcode: barcode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistributorOrderItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orderId == other.orderId &&
          productId == other.productId &&
          productName == other.productName &&
          quantity == other.quantity &&
          suggestedPrice == other.suggestedPrice &&
          distributorPrice == other.distributorPrice;

  @override
  int get hashCode => Object.hash(
      id, orderId, productId, productName, quantity, suggestedPrice,
      distributorPrice);
}
