import 'sa_store_model.dart';

/// Typed model for a subscription in the super admin context.
class SASubscription {
  final String id;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? storeId;

  /// Nested store info from the join.
  final SASubscriptionStore? store;

  /// Nested plan info from the join.
  final SAStorePlan? plan;

  const SASubscription({
    required this.id,
    this.status,
    this.startDate,
    this.endDate,
    this.storeId,
    this.store,
    this.plan,
  });

  factory SASubscription.fromJson(Map<String, dynamic> json) {
    final rawStore = json['stores'];
    final rawPlan = json['plans'];
    return SASubscription(
      id: json['id'] as String? ?? '',
      status: json['status'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      storeId: json['store_id'] as String?,
      store: rawStore is Map<String, dynamic>
          ? SASubscriptionStore.fromJson(rawStore)
          : null,
      plan: rawPlan is Map<String, dynamic>
          ? SAStorePlan.fromJson(rawPlan)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'store_id': storeId,
        'stores': store?.toJson(),
        'plans': plan?.toJson(),
      };

  /// Convenience: store name.
  String get storeName => store?.name ?? 'Unknown';

  /// Convenience: plan name.
  String get planName => plan?.name ?? 'Unknown';

  /// Convenience: plan slug.
  String get planSlug => plan?.slug ?? 'unknown';

  /// Convenience: monthly price.
  double get monthlyPrice => plan?.monthlyPrice ?? 0;
}

/// Nested store info within a subscription.
class SASubscriptionStore {
  final String id;
  final String? name;

  const SASubscriptionStore({
    required this.id,
    this.name,
  });

  factory SASubscriptionStore.fromJson(Map<String, dynamic> json) {
    return SASubscriptionStore(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

/// Typed model for a plan.
class SAPlan {
  final String id;
  final String? name;
  final String? slug;
  final double? monthlyPrice;
  final double? yearlyPrice;
  final int? maxBranches;
  final int? maxProducts;
  final int? maxUsers;
  final List<String>? features;
  final String? createdAt;

  const SAPlan({
    required this.id,
    this.name,
    this.slug,
    this.monthlyPrice,
    this.yearlyPrice,
    this.maxBranches,
    this.maxProducts,
    this.maxUsers,
    this.features,
    this.createdAt,
  });

  factory SAPlan.fromJson(Map<String, dynamic> json) {
    return SAPlan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      monthlyPrice: (json['monthly_price'] as num?)?.toDouble(),
      yearlyPrice: (json['yearly_price'] as num?)?.toDouble(),
      maxBranches: json['max_branches'] as int?,
      maxProducts: json['max_products'] as int?,
      maxUsers: json['max_users'] as int?,
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'monthly_price': monthlyPrice,
        'yearly_price': yearlyPrice,
        'max_branches': maxBranches,
        'max_products': maxProducts,
        'max_users': maxUsers,
        'features': features,
        'created_at': createdAt,
      };
}

/// Typed model for a billing invoice.
class SABillingInvoice {
  final String id;
  final String? invoiceNumber;
  final double? amount;
  final String? status;
  final String? issuedAt;
  final String? dueAt;

  /// Nested store info.
  final SASubscriptionStore? store;

  /// Nested plan info.
  final SAStorePlan? plan;

  const SABillingInvoice({
    required this.id,
    this.invoiceNumber,
    this.amount,
    this.status,
    this.issuedAt,
    this.dueAt,
    this.store,
    this.plan,
  });

  factory SABillingInvoice.fromJson(Map<String, dynamic> json) {
    final rawStore = json['stores'];
    final rawPlan = json['plans'];
    return SABillingInvoice(
      id: json['id'] as String? ?? '',
      invoiceNumber: json['invoice_number'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String?,
      issuedAt: json['issued_at'] as String?,
      dueAt: json['due_at'] as String?,
      store: rawStore is Map<String, dynamic>
          ? SASubscriptionStore.fromJson(rawStore)
          : null,
      plan: rawPlan is Map<String, dynamic>
          ? SAStorePlan.fromJson(rawPlan)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_number': invoiceNumber,
        'amount': amount,
        'status': status,
        'issued_at': issuedAt,
        'due_at': dueAt,
        'stores': store?.toJson(),
        'plans': plan?.toJson(),
      };

  /// Convenience: store name.
  String get storeName => store?.name ?? 'Unknown';

  /// Convenience: plan name.
  String get planName => plan?.name ?? 'Unknown';
}
