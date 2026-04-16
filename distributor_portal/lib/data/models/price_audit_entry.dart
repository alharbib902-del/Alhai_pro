/// Price change audit entry model.
///
/// Tracks individual price changes for audit trail compliance.
library;

class PriceAuditEntry {
  final String id;
  final String productId;
  final String productName;
  final double? oldPrice;
  final double newPrice;
  final String changedBy;
  final DateTime changedAt;
  final String? reason;

  const PriceAuditEntry({
    required this.id,
    required this.productId,
    required this.productName,
    this.oldPrice,
    required this.newPrice,
    required this.changedBy,
    required this.changedAt,
    this.reason,
  });

  factory PriceAuditEntry.fromJson(Map<String, dynamic> json) {
    return PriceAuditEntry(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      oldPrice: (json['old_price'] as num?)?.toDouble(),
      newPrice: (json['new_price'] as num?)?.toDouble() ?? 0,
      changedBy: json['changed_by'] as String? ?? '',
      changedAt: DateTime.tryParse(json['changed_at'] as String? ?? '') ??
          DateTime.now(),
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'product_name': productName,
        'old_price': oldPrice,
        'new_price': newPrice,
        'changed_by': changedBy,
        'changed_at': changedAt.toIso8601String(),
        'reason': reason,
      };

  /// Difference between old and new price, or null if no old price.
  double? get priceDifference =>
      oldPrice != null ? newPrice - oldPrice! : null;

  /// Percentage change, or null if no old price.
  double? get percentChange =>
      oldPrice != null && oldPrice! > 0
          ? ((newPrice - oldPrice!) / oldPrice!) * 100
          : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PriceAuditEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
