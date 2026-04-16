import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/audit_log_service.dart';
import '../core/services/mfa_guard_service.dart';
import 'models/sa_store_model.dart';

/// Datasource for multi-tenant store management.
/// Queries: stores, store_members, organizations.
class SAStoresDatasource {
  /// Supabase client for all queries.
  ///
  /// Accepts [SupabaseClient] in production. Tests may pass a duck-typed
  /// fake via the [SAStoresDatasource.test] constructor.
  final dynamic _client;

  /// Optional audit logger for privileged mutations.
  final AuditLogService? _audit;

  /// Production constructor -- accepts a typed [SupabaseClient].
  SAStoresDatasource(SupabaseClient client, {AuditLogService? audit})
    : _client = client,
      _audit = audit;

  /// Test constructor -- accepts a fake client that implements the same
  /// postgrest query-chain surface as [SupabaseClient].
  SAStoresDatasource.test(this._client, {AuditLogService? audit})
    : _audit = audit;

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
    final data = await _client
        .from('stores')
        .select('''
          *,
          subscriptions(*)
        ''')
        .eq('id', storeId)
        .single();
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
              .count(CountOption.exact)
          as Future<dynamic>,
      _client
              .from('products')
              .select('id')
              .eq('store_id', storeId)
              .count(CountOption.exact)
          as Future<dynamic>,
      _client
              .from('users')
              .select('id')
              .eq('store_id', storeId)
              .count(CountOption.exact)
          as Future<dynamic>,
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
    MfaGuardService.requireAAL2(_client);
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

    await _audit?.log(
      action: 'store.create',
      targetType: 'store',
      targetId: storeId,
      after: {
        'name': name,
        'business_type': businessType,
        'owner_email': ownerEmail,
        'plan_slug': planSlug,
      },
    );

    return SAStore.fromJson(storeData);
  }

  /// Update store status (activate/suspend).
  Future<void> updateStoreStatus(String storeId, bool isActive) async {
    MfaGuardService.requireAAL2(_client);
    await _client
        .from('stores')
        .update({'is_active': isActive})
        .eq('id', storeId);
    await _audit?.log(
      action: 'store.status.update',
      targetType: 'store',
      targetId: storeId,
      after: {'is_active': isActive},
    );
  }

  /// Update store subscription plan.
  Future<void> updateStorePlan(String storeId, String planSlug) async {
    MfaGuardService.requireAAL2(_client);
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
    await _audit?.log(
      action: 'store.plan.update',
      targetType: 'store',
      targetId: storeId,
      after: {'plan': planSlug, 'org_id': orgId},
    );
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

  /// Soft delete a store (set is_active = false instead of deleting).
  Future<void> softDeleteStore(String storeId) async {
    MfaGuardService.requireAAL2(_client);
    await _client.from('stores').update({'is_active': false}).eq('id', storeId);
    await _audit?.log(
      action: 'store.soft_delete',
      targetType: 'store',
      targetId: storeId,
      after: {'is_active': false},
    );
  }

  /// Restore a soft-deleted store.
  Future<void> restoreStore(String storeId) async {
    MfaGuardService.requireAAL2(_client);
    await _client.from('stores').update({'is_active': true}).eq('id', storeId);
    await _audit?.log(
      action: 'store.restore',
      targetType: 'store',
      targetId: storeId,
      after: {'is_active': true},
    );
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
