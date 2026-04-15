/// Pricing tier model for distributor per-store pricing.
///
/// Maps to the `pricing_tiers` Supabase table.
/// Each tier belongs to an org and defines a discount percentage.
library;

class PricingTier {
  final String id;
  final String orgId;
  final String name;
  final String? nameAr;
  final double discountPercent;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PricingTier({
    required this.id,
    required this.orgId,
    required this.name,
    this.nameAr,
    required this.discountPercent,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Display name: prefer Arabic name if available.
  String get displayName => nameAr ?? name;

  /// Discount display string, e.g. "15%" or "7.5%".
  String get discountDisplay {
    if (discountPercent == discountPercent.truncateToDouble()) {
      return '${discountPercent.toInt()}%';
    }
    // Remove trailing zeros: 7.50 → 7.5
    final s = discountPercent.toStringAsFixed(2);
    final trimmed = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    return '$trimmed%';
  }

  factory PricingTier.fromJson(Map<String, dynamic> json) {
    return PricingTier(
      id: json['id'] as String,
      orgId: json['org_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      discountPercent:
          (json['discount_percent'] as num?)?.toDouble() ?? 0,
      isDefault: json['is_default'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  Map<String, dynamic> toInsertJson(String orgId) => {
    'org_id': orgId,
    'name': name,
    'name_ar': nameAr,
    'discount_percent': discountPercent,
    'is_default': isDefault,
    'sort_order': sortOrder,
  };

  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    'name_ar': nameAr,
    'discount_percent': discountPercent,
    'is_default': isDefault,
    'sort_order': sortOrder,
    'updated_at': DateTime.now().toIso8601String(),
  };

  PricingTier copyWith({
    String? id,
    String? orgId,
    String? name,
    String? nameAr,
    double? discountPercent,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PricingTier(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      discountPercent: discountPercent ?? this.discountPercent,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PricingTier &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orgId == other.orgId &&
          name == other.name &&
          nameAr == other.nameAr &&
          discountPercent == other.discountPercent &&
          isDefault == other.isDefault &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => Object.hash(
    id, orgId, name, nameAr, discountPercent, isDefault, sortOrder,
  );
}
