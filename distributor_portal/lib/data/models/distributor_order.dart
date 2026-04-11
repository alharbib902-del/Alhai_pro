/// Distributor order model.
///
/// Maps to the Supabase `orders` table with a join on `stores`.
library;

class DistributorOrder {
  final String id;
  final String purchaseNumber;
  final String storeName;
  final String storeId;
  final double total;
  final String status; // draft, sent, approved, received, rejected
  final DateTime createdAt;
  final String? notes;

  const DistributorOrder({
    required this.id,
    required this.purchaseNumber,
    required this.storeName,
    required this.storeId,
    required this.total,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory DistributorOrder.fromJson(Map<String, dynamic> json) {
    // The store name comes from a join: orders.store_id -> stores.name
    final storeName = json['stores'] is Map
        ? (json['stores']['name'] as String? ?? '')
        : (json['store_name'] as String? ?? '');

    return DistributorOrder(
      id: json['id'] as String,
      purchaseNumber:
          json['purchase_number'] as String? ??
          'PO-${(json['id'] as String).substring(0, 8)}',
      storeName: storeName,
      storeId: json['store_id'] as String? ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'draft',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistributorOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          purchaseNumber == other.purchaseNumber &&
          storeName == other.storeName &&
          storeId == other.storeId &&
          status == other.status &&
          total == other.total &&
          notes == other.notes;

  @override
  int get hashCode =>
      Object.hash(id, purchaseNumber, storeName, storeId, status, total, notes);
}
