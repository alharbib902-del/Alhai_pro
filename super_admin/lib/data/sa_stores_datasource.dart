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

  /// When true, mutation methods bypass the AAL2 MFA check. ONLY set by the
  /// `.test` constructor.
  final bool _skipMfaCheck;

  /// Production constructor -- accepts a typed [SupabaseClient].
  SAStoresDatasource(SupabaseClient client, {AuditLogService? audit})
    : _client = client,
      _audit = audit,
      _skipMfaCheck = false;

  /// Test constructor -- accepts a fake client that implements the same
  /// postgrest query-chain surface as [SupabaseClient].
  SAStoresDatasource.test(this._client, {AuditLogService? audit})
    : _audit = audit,
      _skipMfaCheck = true;

  void _requireMfa() {
    if (!_skipMfaCheck) MfaGuardService.requireAAL2(_client as SupabaseClient);
  }

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

  /// Create a new store with its initial subscription and audit row in a
  /// single atomic server-side transaction.
  ///
  /// Wraps the v49 `create_store` RPC. The RPC performs stores INSERT +
  /// subscriptions INSERT + sa_audit_log INSERT in one plpgsql transaction;
  /// any failure (CHECK violation, guard rejection, constraint) rolls back
  /// all three. The client therefore does NOT emit its own audit row --
  /// that would be a duplicate, and it would not be part of the
  /// transaction.
  ///
  /// Validation authoritative on the server:
  ///   - `p_name` / `p_plan` non-empty -> 22023
  ///   - `plan` whitelist (free/starter/professional/enterprise)
  ///     enforced by `subscriptions_plan_check` -> 23514
  ///   - `status='trialing'`, 30-day trial window, other defaults set
  ///     inside the RPC; the client does not pass these.
  ///
  /// `businessType` is persisted into `subscriptions.features` JSONB
  /// by the RPC when provided -- no schema column needed client-side.
  Future<SAStore> createStore({
    required String name,
    String? phone,
    String? email,
    String? taxNumber,
    required String plan,
    String? businessType,
  }) async {
    _requireMfa();
    final data = await _client.rpc(
      'create_store',
      params: {
        'p_name':          name,
        'p_phone':         _nullIfEmpty(phone),
        'p_email':         _nullIfEmpty(email),
        'p_tax_number':    _nullIfEmpty(taxNumber),
        'p_plan':          plan,
        'p_business_type': _nullIfEmpty(businessType),
      },
    );
    return SAStore.fromJson(data as Map<String, dynamic>);
  }

  String? _nullIfEmpty(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  /// Update store status (activate/suspend).
  Future<void> updateStoreStatus(String storeId, bool isActive) async {
    _requireMfa();
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
    _requireMfa();
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
    _requireMfa();
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
    _requireMfa();
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
