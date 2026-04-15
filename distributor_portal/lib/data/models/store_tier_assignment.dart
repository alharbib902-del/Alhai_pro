/// Store-to-tier assignment model.
///
/// Maps to the `distributor_store_tiers` Supabase table,
/// joined with store and tier info for display.
library;

class StoreTierAssignment {
  final String orgId;
  final String storeId;
  final String tierId;
  final DateTime assignedAt;

  /// Joined data (nullable — populated from query joins).
  final String? storeName;
  final String? tierName;
  final double? discountPercent;

  const StoreTierAssignment({
    required this.orgId,
    required this.storeId,
    required this.tierId,
    required this.assignedAt,
    this.storeName,
    this.tierName,
    this.discountPercent,
  });

  factory StoreTierAssignment.fromJson(Map<String, dynamic> json) {
    // Handle joined data from stores and pricing_tiers
    final storeData = json['stores'] as Map<String, dynamic>?;
    final tierData = json['pricing_tiers'] as Map<String, dynamic>?;

    return StoreTierAssignment(
      orgId: json['org_id'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      tierId: json['tier_id'] as String? ?? '',
      assignedAt:
          DateTime.tryParse(json['assigned_at'] as String? ?? '') ??
          DateTime.now(),
      storeName: storeData?['name'] as String?,
      tierName: tierData?['name'] as String?,
      discountPercent:
          (tierData?['discount_percent'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreTierAssignment &&
          runtimeType == other.runtimeType &&
          orgId == other.orgId &&
          storeId == other.storeId &&
          tierId == other.tierId;

  @override
  int get hashCode => Object.hash(orgId, storeId, tierId);
}
