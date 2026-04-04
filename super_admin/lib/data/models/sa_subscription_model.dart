import 'sa_store_model.dart';

/// Typed model for a subscription in the super admin context.
/// Matches Supabase schema: org_id, plan (TEXT slug),
/// current_period_start, current_period_end, amount, billing_cycle.
class SASubscription {
  final String id;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? orgId;
  final double? amount;
  final String? currency;
  final String? billingCycle;

  /// Resolved store name (from org_id lookup).
  final SASubscriptionStore? store;

  /// Plan slug from the TEXT field.
  final String? planSlug;

  const SASubscription({
    required this.id,
    this.status,
    this.startDate,
    this.endDate,
    this.orgId,
    this.amount,
    this.currency,
    this.billingCycle,
    this.store,
    this.planSlug,
  });

  /// Parse from the old nested-join format (backwards compat).
  factory SASubscription.fromJson(Map<String, dynamic> json) {
    final rawStore = json['stores'];
    final rawPlan = json['plans'];
    return SASubscription(
      id: json['id'] as String? ?? '',
      status: json['status'] as String?,
      startDate: json['start_date'] as String? ??
          json['current_period_start'] as String?,
      endDate: json['end_date'] as String? ??
          json['current_period_end'] as String?,
      orgId: json['org_id'] as String? ?? json['store_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      billingCycle: json['billing_cycle'] as String?,
      store: rawStore is Map<String, dynamic>
          ? SASubscriptionStore.fromJson(rawStore)
          : null,
      planSlug: json['plan'] as String? ??
          (rawPlan is Map<String, dynamic>
              ? rawPlan['slug'] as String?
              : null),
    );
  }

  /// Parse from the actual Supabase schema with optional resolved store name.
  factory SASubscription.fromSupabase(
    Map<String, dynamic> json, {
    String? storeName,
  }) {
    return SASubscription(
      id: json['id'] as String? ?? '',
      status: json['status'] as String?,
      startDate: json['current_period_start'] as String?,
      endDate: json['current_period_end'] as String?,
      orgId: json['org_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      billingCycle: json['billing_cycle'] as String?,
      planSlug: json['plan'] as String?,
      store: storeName != null
          ? SASubscriptionStore(id: json['org_id'] as String? ?? '', name: storeName)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'current_period_start': startDate,
        'current_period_end': endDate,
        'org_id': orgId,
        'plan': planSlug,
        'amount': amount,
        'currency': currency,
        'billing_cycle': billingCycle,
      };

  /// Convenience: store name.
  String get storeName => store?.name ?? 'Unknown';

  /// Convenience: plan name (derived from slug).
  String get planName => planSlug?.replaceAll('_', ' ') ?? 'Unknown';

  /// Convenience: monthly price.
  double get monthlyPrice {
    if (amount == null) return 0;
    if (billingCycle == 'yearly') return amount! / 12;
    return amount!;
  }
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
