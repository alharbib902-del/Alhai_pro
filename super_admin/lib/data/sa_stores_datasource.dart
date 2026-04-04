import 'package:supabase_flutter/supabase_flutter.dart';

/// Datasource for multi-tenant store management.
/// Queries: stores, store_members, organizations.
class SAStoresDatasource {
  final SupabaseClient _client;

  SAStoresDatasource(this._client);

  /// Fetch all stores with owner info.
  Future<List<Map<String, dynamic>>> getStores({
    String? statusFilter,
    String? planFilter,
    String? search,
  }) async {
    var query = _client.from('stores').select('''
      id, name, address, phone, email, is_active, owner_id,
      business_type, created_at, logo,
      subscriptions(plan_id, status, plans(name, slug))
    ''').order('created_at', ascending: false);

    if (statusFilter != null && statusFilter != 'all') {
      if (statusFilter == 'active') {
        query = query.eq('is_active', true);
      } else if (statusFilter == 'suspended') {
        query = query.eq('is_active', false);
      }
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,email.ilike.%$search%');
    }

    final data = await query;
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Fetch a single store by ID with full details.
  Future<Map<String, dynamic>> getStore(String storeId) async {
    final data = await _client
        .from('stores')
        .select('''
          *,
          subscriptions(*, plans(*))
        ''')
        .eq('id', storeId)
        .single();
    return data;
  }

  /// Get store usage stats (transactions, products, employees, branches).
  Future<Map<String, int>> getStoreUsageStats(String storeId) async {
    final results = await Future.wait([
      _client
          .from('sales')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact),
      _client
          .from('products')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact),
      _client
          .from('app_users')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact),
      _client
          .from('branches')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact),
    ]);

    return {
      'transactions': results[0].count,
      'products': results[1].count,
      'employees': results[2].count,
      'branches': results[3].count,
    };
  }

  /// Create a new store with owner and subscription.
  Future<Map<String, dynamic>> createStore({
    required String name,
    required String businessType,
    required String ownerName,
    required String ownerPhone,
    required String ownerEmail,
    required String planSlug,
    int branchCount = 1,
  }) async {
    // Insert store
    final storeData = await _client.from('stores').insert({
      'name': name,
      'business_type': businessType,
      'phone': ownerPhone,
      'email': ownerEmail,
      'is_active': true,
    }).select().single();

    final storeId = storeData['id'] as String;

    // Fetch plan ID by slug
    final planData = await _client
        .from('plans')
        .select('id')
        .eq('slug', planSlug)
        .maybeSingle();

    if (planData != null) {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));

      await _client.from('subscriptions').insert({
        'store_id': storeId,
        'plan_id': planData['id'],
        'status': planSlug == 'trial' ? 'trial' : 'active',
        'start_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });
    }

    return storeData;
  }

  /// Update store status (activate/suspend).
  Future<void> updateStoreStatus(String storeId, bool isActive) async {
    await _client
        .from('stores')
        .update({'is_active': isActive})
        .eq('id', storeId);
  }

  /// Update store subscription plan.
  Future<void> updateStorePlan(String storeId, String planSlug) async {
    final planData = await _client
        .from('plans')
        .select('id')
        .eq('slug', planSlug)
        .maybeSingle();

    if (planData != null) {
      await _client
          .from('subscriptions')
          .update({'plan_id': planData['id']})
          .eq('store_id', storeId)
          .eq('status', 'active');
    }
  }

  /// Get total store count.
  Future<int> getTotalStoreCount() async {
    final result = await _client
        .from('stores')
        .select('id')
        .count(CountOption.exact);
    return result.count;
  }

  /// Get active store count.
  Future<int> getActiveStoreCount() async {
    final result = await _client
        .from('stores')
        .select('id')
        .eq('is_active', true)
        .count(CountOption.exact);
    return result.count;
  }

  /// Get store owner info from app_users.
  Future<Map<String, dynamic>?> getStoreOwner(String storeId) async {
    final data = await _client
        .from('app_users')
        .select('id, name, phone, email, role')
        .eq('store_id', storeId)
        .eq('role', 'owner')
        .maybeSingle();
    return data;
  }
}
