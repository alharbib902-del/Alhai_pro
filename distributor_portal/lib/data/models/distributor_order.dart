/// Distributor order model.
///
/// Maps to the Supabase `orders` table with a join on `stores`.
library;

/// All known order statuses including post-approval workflow stages.
/// Legacy statuses (draft, sent, approved, received, rejected) are preserved.
/// New post-approval stages: preparing, packed, shipped, delivered.
const List<String> orderWorkflowStages = [
  'draft',
  'sent',
  'approved',
  'preparing',
  'packed',
  'shipped',
  'delivered',
];

/// Whether a status is a post-approval workflow stage.
bool isPostApprovalStatus(String status) {
  return const {'preparing', 'packed', 'shipped', 'delivered'}.contains(status);
}

/// Get the next workflow status after the given one, or null if terminal.
String? nextWorkflowStatus(String current) {
  const transitions = {
    'approved': 'preparing',
    'preparing': 'packed',
    'packed': 'shipped',
    'shipped': 'delivered',
  };
  return transitions[current];
}

/// Arabic label for a workflow status.
String workflowStatusLabel(String status) {
  const labels = {
    'draft': 'مسودة',
    'sent': 'مُرسل',
    'approved': 'مقبول',
    'preparing': 'قيد التحضير',
    'packed': 'تم التغليف',
    'shipped': 'تم الشحن',
    'delivered': 'تم التسليم',
    'received': 'مستلم',
    'rejected': 'مرفوض',
  };
  return labels[status] ?? status;
}

class DistributorOrder {
  final String id;
  final String purchaseNumber;
  final String storeName;
  final String storeId;
  final double total;
  final String
  status; // draft, sent, approved, preparing, packed, shipped, delivered, received, rejected
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
