import 'package:super_admin/data/models/sa_store_model.dart';
import 'package:super_admin/data/models/sa_user_model.dart';
import 'package:super_admin/data/models/sa_subscription_model.dart';

// ---------------------------------------------------------------------------
// Test factories for super_admin models.
//
// Each factory produces a fully-populated instance with sensible defaults.
// Pass named overrides to customise individual fields.
// ---------------------------------------------------------------------------

/// Counter used to generate unique IDs across factories.
int _idCounter = 0;
String _nextId() => 'test-${++_idCounter}';

/// Reset the shared ID counter (call in setUp if needed).
void resetFactoryIds() => _idCounter = 0;

// ---------- SAStore ----------

class SAStoreFactory {
  SAStoreFactory._();

  static SAStore create({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    bool isActive = true,
    String? ownerId,
    String? businessType,
    String? createdAt,
    String? logo,
    List<SAStoreSubscription>? subscriptions,
  }) {
    final storeId = id ?? _nextId();
    return SAStore(
      id: storeId,
      name: name ?? 'Test Store $storeId',
      address: address ?? '123 Main St',
      phone: phone ?? '+966500000000',
      email: email ?? 'store-$storeId@test.com',
      isActive: isActive,
      ownerId: ownerId ?? _nextId(),
      businessType: businessType ?? 'retail',
      createdAt: createdAt ?? '2025-01-15T10:00:00Z',
      logo: logo,
      subscriptions: subscriptions ?? [],
    );
  }

  /// Create a store with an active subscription attached.
  static SAStore withSubscription({
    String? id,
    String? name,
    String planSlug = 'basic',
    String status = 'active',
    double amount = 99.0,
  }) {
    final storeId = id ?? _nextId();
    return create(
      id: storeId,
      name: name,
      subscriptions: [
        SAStoreSubscription(
          id: _nextId(),
          planSlug: planSlug,
          status: status,
          startDate: '2025-01-01T00:00:00Z',
          endDate: '2025-02-01T00:00:00Z',
          orgId: storeId,
          amount: amount,
        ),
      ],
    );
  }

  /// Return the JSON map as Supabase would return it.
  static Map<String, dynamic> json({
    String? id,
    String? name,
    bool isActive = true,
    String? ownerId,
    String? businessType,
    List<Map<String, dynamic>>? subscriptions,
  }) {
    final storeId = id ?? _nextId();
    return {
      'id': storeId,
      'name': name ?? 'Test Store $storeId',
      'address': '123 Main St',
      'phone': '+966500000000',
      'email': 'store-$storeId@test.com',
      'is_active': isActive,
      'owner_id': ownerId ?? _nextId(),
      'business_type': businessType ?? 'retail',
      'created_at': '2025-01-15T10:00:00Z',
      'logo': null,
      'subscriptions': subscriptions ?? [],
    };
  }
}

// ---------- SAUser ----------

class SAUserFactory {
  SAUserFactory._();

  static SAUser create({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? role,
    String? createdAt,
    String? lastLoginAt,
    bool? isActive,
    String? storeId,
  }) {
    final userId = id ?? _nextId();
    return SAUser(
      id: userId,
      name: name ?? 'Test User $userId',
      phone: phone ?? '+966500000000',
      email: email ?? 'user-$userId@test.com',
      role: role ?? 'owner',
      createdAt: createdAt ?? '2025-01-15T10:00:00Z',
      lastLoginAt: lastLoginAt,
      isActive: isActive ?? true,
      storeId: storeId,
    );
  }

  /// Create a user who appears "online" (last login < 5 min ago).
  static SAUser online({String? id, String? name}) {
    return create(
      id: id,
      name: name,
      lastLoginAt: DateTime.now().toIso8601String(),
    );
  }

  /// Return the JSON map as Supabase would return it.
  static Map<String, dynamic> json({
    String? id,
    String? name,
    String? role,
    bool isActive = true,
    String? storeId,
  }) {
    final userId = id ?? _nextId();
    return {
      'id': userId,
      'name': name ?? 'Test User $userId',
      'phone': '+966500000000',
      'email': 'user-$userId@test.com',
      'role': role ?? 'owner',
      'created_at': '2025-01-15T10:00:00Z',
      'last_login_at': null,
      'is_active': isActive,
      'store_id': storeId,
    };
  }
}

// ---------- SASubscription ----------

class SASubscriptionFactory {
  SASubscriptionFactory._();

  static SASubscription create({
    String? id,
    String? status,
    String? startDate,
    String? endDate,
    String? orgId,
    double? amount,
    String? currency,
    String? billingCycle,
    SASubscriptionStore? store,
    String? planSlug,
  }) {
    final subId = id ?? _nextId();
    return SASubscription(
      id: subId,
      status: status ?? 'active',
      startDate: startDate ?? '2025-01-01T00:00:00Z',
      endDate: endDate ?? '2025-02-01T00:00:00Z',
      orgId: orgId ?? _nextId(),
      amount: amount ?? 99.0,
      currency: currency ?? 'SAR',
      billingCycle: billingCycle ?? 'monthly',
      store: store,
      planSlug: planSlug ?? 'basic',
    );
  }

  /// Create a subscription with a resolved store name.
  static SASubscription withStore({
    String? id,
    String storeName = 'Test Store',
    String? storeId,
    String status = 'active',
    String planSlug = 'basic',
    double amount = 99.0,
  }) {
    final sid = storeId ?? _nextId();
    return create(
      id: id,
      status: status,
      orgId: sid,
      planSlug: planSlug,
      amount: amount,
      store: SASubscriptionStore(id: sid, name: storeName),
    );
  }

  /// Return the JSON map as Supabase would return it.
  static Map<String, dynamic> json({
    String? id,
    String? status,
    String? planSlug,
    double? amount,
    String? orgId,
    String? billingCycle,
    Map<String, dynamic>? stores,
  }) {
    final subId = id ?? _nextId();
    return {
      'id': subId,
      'status': status ?? 'active',
      'current_period_start': '2025-01-01T00:00:00Z',
      'current_period_end': '2025-02-01T00:00:00Z',
      'org_id': orgId ?? _nextId(),
      'plan': planSlug ?? 'basic',
      'amount': amount ?? 99.0,
      'currency': 'SAR',
      'billing_cycle': billingCycle ?? 'monthly',
      if (stores != null) 'stores': stores,
    };
  }
}

// ---------- SAPlan ----------

class SAPlanFactory {
  SAPlanFactory._();

  static SAPlan create({
    String? id,
    String? name,
    String? slug,
    double? monthlyPrice,
    double? yearlyPrice,
    int? maxBranches,
    int? maxProducts,
    int? maxUsers,
    List<String>? features,
    String? createdAt,
  }) {
    final planId = id ?? _nextId();
    return SAPlan(
      id: planId,
      name: name ?? 'Basic Plan',
      slug: slug ?? 'basic',
      monthlyPrice: monthlyPrice ?? 99.0,
      yearlyPrice: yearlyPrice ?? 999.0,
      maxBranches: maxBranches ?? 3,
      maxProducts: maxProducts ?? 500,
      maxUsers: maxUsers ?? 10,
      features: features ?? const ['pos', 'inventory', 'reports'],
      createdAt: createdAt ?? '2025-01-01T00:00:00Z',
    );
  }

  /// Convenience: create the standard set of plans (free, basic, pro, enterprise).
  static List<SAPlan> allTiers() {
    return [
      create(
        id: 'plan-free',
        name: 'Free',
        slug: 'free',
        monthlyPrice: 0,
        yearlyPrice: 0,
        maxBranches: 1,
        maxProducts: 50,
        maxUsers: 2,
        features: const ['pos'],
      ),
      create(
        id: 'plan-basic',
        name: 'Basic',
        slug: 'basic',
        monthlyPrice: 99,
        yearlyPrice: 999,
        maxBranches: 3,
        maxProducts: 500,
        maxUsers: 10,
        features: const ['pos', 'inventory', 'reports'],
      ),
      create(
        id: 'plan-pro',
        name: 'Pro',
        slug: 'pro',
        monthlyPrice: 249,
        yearlyPrice: 2499,
        maxBranches: 10,
        maxProducts: 5000,
        maxUsers: 50,
        features: const ['pos', 'inventory', 'reports', 'analytics', 'api'],
      ),
      create(
        id: 'plan-enterprise',
        name: 'Enterprise',
        slug: 'enterprise',
        monthlyPrice: 499,
        yearlyPrice: 4999,
        maxBranches: 100,
        maxProducts: 100000,
        maxUsers: 500,
        features: const [
          'pos',
          'inventory',
          'reports',
          'analytics',
          'api',
          'white_label',
        ],
      ),
    ];
  }

  /// Return the JSON map as Supabase would return it.
  static Map<String, dynamic> json({
    String? id,
    String? name,
    String? slug,
    double? monthlyPrice,
    double? yearlyPrice,
  }) {
    final planId = id ?? _nextId();
    return {
      'id': planId,
      'name': name ?? 'Basic Plan',
      'slug': slug ?? 'basic',
      'monthly_price': monthlyPrice ?? 99.0,
      'yearly_price': yearlyPrice ?? 999.0,
      'max_branches': 3,
      'max_products': 500,
      'max_users': 10,
      'features': ['pos', 'inventory', 'reports'],
      'created_at': '2025-01-01T00:00:00Z',
    };
  }
}
