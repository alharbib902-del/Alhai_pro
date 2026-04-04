import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/sa_store_model.dart';

/// Datasource for multi-tenant store management.
/// Queries: stores, store_members, organizations.
class SAStoresDatasource {
  // ignore: strict_raw_type
  final dynamic _client;

  /// Accepts [SupabaseClient] in production or a fake in tests.
  SAStoresDatasource(this._client);

  /// Fetch all stores with owner info.
  Future<List<SAStore>> getStores({
    String? statusFilter,
    String? planFilter,
    String? search,
  }) async {
    var query = _client.from('stores').select('''
      id, name, address, phone, email, is_active, owner_id,
      business_type, created_at, logo, org_id,
      subscriptions(id, plan, status, amount, current_period_start, current_period_end, org_id)
    ''');

    if (statusFilter != null && statusFilter != 'all') {
      if (statusFilter == 'active') {
        query = query.eq('is_active', true);
      } else if (statusFilter == 'suspended') {
        query = query.eq('is_active', false);
      }
    }

    if (search != null && search.isNotEmpty) {
      final sanitized = search.replaceAll('%', r'\%').replaceAll('_', r'\_');
      query = query.or('name.ilike.%$sanitized%,email.ilike.%$sanitized%');
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List)
        .map((e) => SAStore.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single store by ID with full details.
  Future<SAStore> getStore(String storeId) async {
    final data = await _client.from('stores').select('''
          *,
          subscriptions(*)
        ''').eq('id', storeId).single();
    return SAStore.fromJson(data);
  }

  /// Get store usage stats (transactions, products, employees, branches).
  ///
  /// Uses Future.wait to run all 4 count queries in parallel (not sequential
  /// N+1). This is intentional for better performance.
  Future<SAStoreUsageStats> getStoreUsageStats(String storeId) async {
    final results = await Future.wait<dynamic>([
      _client
          .from('sales')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact) as Future<dynamic>,
      _client
          .from('products')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact) as Future<dynamic>,
      _client
          .from('users')
          .select('id')
          .eq('store_id', storeId)
          .count(CountOption.exact) as Future<dynamic>,
    ]);

    // branches table does not exist; default to 1 (main store)
    return SAStoreUsageStats(
      transactions: results[0].count,
      products: results[1].count,
      employees: results[2].count,
      branches: 1,
    );
  }

  /// Create a new store with owner and subscription.
  ///
  /// Uses manual rollback to ensure atomicity: if subscription creation
  /// fails, the store record is deleted to avoid orphaned rows.
  Future<SAStore> createStore({
    required String name,
    required String businessType,
    required String ownerName,
    required String ownerPhone,
    required String ownerEmail,
    required String planSlug,
    int branchCount = 1,
  }) async {
    // Step 1: Insert store
    final storeData = await _client
        .from('stores')
        .insert({
          'name': name,
          'business_type': businessType,
          'phone': ownerPhone,
          'email': ownerEmail,
          'is_active': true,
        })
        .select()
        .single();

    final storeId = storeData['id'] as String;

    try {
      // Step 2: Create subscription with plan slug
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));
      final orgId = storeData['org_id'] as String? ?? storeId;

      await _client.from('subscriptions').insert({
        'id': '${storeId}_sub_${now.millisecondsSinceEpoch}',
        'org_id': orgId,
        'plan': planSlug,
        'status': planSlug == 'trial' ? 'trial' : 'active',
        'current_period_start': now.toIso8601String(),
        'current_period_end': endDate.toIso8601String(),
        'amount': 0,
        'currency': 'SAR',
        'billing_cycle': 'monthly',
      });
    } catch (e) {
      // Rollback: delete the store if subscription creation fails
      await _client.from('stores').delete().eq('id', storeId);
      rethrow;
    }

    return SAStore.fromJson(storeData);
  }

  /// Update store status (activate/suspend).
  Future<void> updateStoreStatus(String storeId, bool isActive) async {
    await _client
        .from('stores')
        .update({'is_active': isActive}).eq('id', storeId);
  }

  /// Update store subscription plan.
  Future<void> updateStorePlan(String storeId, String planSlug) async {
    // Get org_id for this store
    final store = await _client
        .from('stores')
        .select('org_id')
        .eq('id', storeId)
        .maybeSingle();

    final orgId = store?['org_id'] as String? ?? storeId;
    await _client
        .from('subscriptions')
        .update({'plan': planSlug})
        .eq('org_id', orgId)
        .eq('status', 'active');
  }

  /// Get total store count.
  Future<int> getTotalStoreCount() async {
    final result =
        await _client.from('stores').select('id').count(CountOption.exact);
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

  /// Soft delete a store (set is_active = false instead of deleting).
  Future<void> softDeleteStore(String storeId) async {
    await _client.from('stores').update({'is_active': false}).eq('id', storeId);
  }

  /// Restore a soft-deleted store.
  Future<void> restoreStore(String storeId) async {
    await _client.from('stores').update({'is_active': true}).eq('id', storeId);
  }

  /// Get store owner info from users.
  Future<SAStoreOwner?> getStoreOwner(String storeId) async {
    final data = await _client
        .from('users')
        .select('id, name, phone, email, role')
        .eq('store_id', storeId)
        .eq('role', 'owner')
        .maybeSingle();
    return data != null ? SAStoreOwner.fromJson(data) : null;
  }
}
