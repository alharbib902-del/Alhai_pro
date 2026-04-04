/// Typed model for a store in the super admin context.
class SAStore {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;
  final String? ownerId;
  final String? businessType;
  final String? createdAt;
  final String? logo;

  /// Nested subscription info from the join query.
  final List<SAStoreSubscription> subscriptions;

  const SAStore({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.email,
    this.isActive = true,
    this.ownerId,
    this.businessType,
    this.createdAt,
    this.logo,
    this.subscriptions = const [],
  });

  factory SAStore.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subscriptions'];
    final subs = <SAStoreSubscription>[];
    if (rawSubs is List) {
      for (final s in rawSubs) {
        if (s is Map<String, dynamic>) {
          subs.add(SAStoreSubscription.fromJson(s));
        }
      }
    }

    return SAStore(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      ownerId: json['owner_id'] as String?,
      businessType: json['business_type'] as String?,
      createdAt: json['created_at'] as String?,
      logo: json['logo'] as String?,
      subscriptions: subs,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'phone': phone,
        'email': email,
        'is_active': isActive,
        'owner_id': ownerId,
        'business_type': businessType,
        'created_at': createdAt,
        'logo': logo,
        'subscriptions': subscriptions.map((s) => s.toJson()).toList(),
      };

  /// Convenience: get the current plan name from the first subscription.
  String get planName {
    if (subscriptions.isEmpty) return 'No plan';
    return subscriptions.first.planName ?? 'Unknown';
  }

  /// Convenience: get the current subscription status.
  String get subscriptionStatus {
    if (subscriptions.isEmpty) return 'none';
    return subscriptions.first.status ?? 'unknown';
  }
}

/// Nested subscription info as returned by the stores query join.
class SAStoreSubscription {
  final String? id;
  final String? planId;
  final String? status;
  final String? startDate;
  final String? endDate;
  final String? storeId;

  /// Nested plan info from the join.
  final SAStorePlan? plan;

  const SAStoreSubscription({
    this.id,
    this.planId,
    this.status,
    this.startDate,
    this.endDate,
    this.storeId,
    this.plan,
  });

  factory SAStoreSubscription.fromJson(Map<String, dynamic> json) {
    final rawPlan = json['plans'] ?? json['plan'];
    return SAStoreSubscription(
      id: json['id'] as String?,
      planId: json['plan_id'] as String?,
      status: json['status'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      storeId: json['store_id'] as String?,
      plan: rawPlan is Map<String, dynamic>
          ? SAStorePlan.fromJson(rawPlan)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'status': status,
        'start_date': startDate,
        'end_date': endDate,
        'store_id': storeId,
        'plans': plan?.toJson(),
      };

  String? get planName => plan?.name;
  String? get planSlug => plan?.slug;
}

/// Nested plan info within a subscription.
class SAStorePlan {
  final String? id;
  final String? name;
  final String? slug;
  final double? monthlyPrice;
  final double? yearlyPrice;
  final int? maxBranches;
  final int? maxProducts;
  final int? maxUsers;
  final List<String>? features;

  const SAStorePlan({
    this.id,
    this.name,
    this.slug,
    this.monthlyPrice,
    this.yearlyPrice,
    this.maxBranches,
    this.maxProducts,
    this.maxUsers,
    this.features,
  });

  factory SAStorePlan.fromJson(Map<String, dynamic> json) {
    return SAStorePlan(
      id: json['id'] as String?,
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
      };
}

/// Store usage stats (transactions, products, employees, branches).
class SAStoreUsageStats {
  final int transactions;
  final int products;
  final int employees;
  final int branches;

  const SAStoreUsageStats({
    this.transactions = 0,
    this.products = 0,
    this.employees = 0,
    this.branches = 0,
  });

  factory SAStoreUsageStats.fromJson(Map<String, int> json) {
    return SAStoreUsageStats(
      transactions: json['transactions'] ?? 0,
      products: json['products'] ?? 0,
      employees: json['employees'] ?? 0,
      branches: json['branches'] ?? 0,
    );
  }

  Map<String, int> toJson() => {
        'transactions': transactions,
        'products': products,
        'employees': employees,
        'branches': branches,
      };
}

/// Store owner info.
class SAStoreOwner {
  final String id;
  final String? name;
  final String? phone;
  final String? email;
  final String? role;

  const SAStoreOwner({
    required this.id,
    this.name,
    this.phone,
    this.email,
    this.role,
  });

  factory SAStoreOwner.fromJson(Map<String, dynamic> json) {
    return SAStoreOwner(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role,
      };
}
