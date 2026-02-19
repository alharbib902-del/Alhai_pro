# Report 3: Generated Sync Logic + JSON Converter

## File 1: `lib/services/sync/json_converter.dart`

```dart
import 'dart:convert';

/// JSONB-to-Text conversion utility for sync operations.
///
/// Supabase stores certain fields as JSONB in PostgreSQL,
/// while Drift uses TextColumn in local SQLite.
class JsonColumnConverter {
  static final JsonColumnConverter instance = JsonColumnConverter._();
  JsonColumnConverter._();

  static const Map<String, Set<String>> _jsonbFields = {
    'roles': {'permissions'},
    'sync_queue': {'payload'},
    'audit_log': {'old_value', 'new_value'},
    'discounts': {'product_ids', 'category_ids'},
    'notifications': {'data'},
    'held_invoices': {'items'},
    'stock_takes': {'items'},
    'stock_transfers': {'items'},
    'promotions': {'rules'},
    'organizations': {'settings'},
    'subscriptions': {'features'},
    'pos_terminals': {'settings'},
  };

  bool isJsonbField(String tableName, String fieldName) =>
      _jsonbFields[tableName]?.contains(fieldName) ?? false;

  Set<String> getJsonbFields(String tableName) =>
      _jsonbFields[tableName] ?? {};

  /// Local (Text) -> Remote (JSONB): parse JSON strings into objects
  Map<String, dynamic> toRemote(
    String tableName,
    Map<String, dynamic> payload,
  ) {
    final result = Map<String, dynamic>.from(payload);
    for (final field in getJsonbFields(tableName)) {
      if (result.containsKey(field) && result[field] is String) {
        result[field] = _parseJsonString(result[field] as String);
      }
    }
    return result;
  }

  /// Remote (JSONB) -> Local (Text): serialize objects to JSON strings
  Map<String, dynamic> toLocal(
    String tableName,
    Map<String, dynamic> payload,
  ) {
    final result = Map<String, dynamic>.from(payload);
    for (final field in getJsonbFields(tableName)) {
      if (result.containsKey(field) && result[field] != null) {
        result[field] = _toJsonString(result[field]);
      }
    }
    return result;
  }

  List<Map<String, dynamic>> batchToLocal(
    String tableName,
    List<Map<String, dynamic>> records,
  ) => records.map((r) => toLocal(tableName, r)).toList();

  List<Map<String, dynamic>> batchToRemote(
    String tableName,
    List<Map<String, dynamic>> records,
  ) => records.map((r) => toRemote(tableName, r)).toList();

  dynamic _parseJsonString(String value) {
    if (value.isEmpty) return value;
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map || decoded is List) return decoded;
      return value;
    } catch (_) {
      return value;
    }
  }

  String _toJsonString(dynamic value) {
    if (value is String) return value;
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
  }

  static bool isValidJson(String value) {
    try { jsonDecode(value); return true; } catch (_) { return false; }
  }

  static String mergeJsonStrings(String base, String override) {
    try {
      final baseObj = jsonDecode(base);
      final overrideObj = jsonDecode(override);
      if (baseObj is Map<String, dynamic> && overrideObj is Map<String, dynamic>) {
        return jsonEncode(_deepMerge(baseObj, overrideObj));
      }
      return override;
    } catch (_) { return override; }
  }

  static Map<String, dynamic> _deepMerge(
    Map<String, dynamic> base, Map<String, dynamic> override,
  ) {
    final result = Map<String, dynamic>.from(base);
    for (final entry in override.entries) {
      if (result[entry.key] is Map<String, dynamic> && entry.value is Map<String, dynamic>) {
        result[entry.key] = _deepMerge(
          result[entry.key] as Map<String, dynamic>,
          entry.value as Map<String, dynamic>,
        );
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  static String normalizeJson(String value) {
    try {
      return jsonEncode(_sortKeys(jsonDecode(value)));
    } catch (_) { return value; }
  }

  static dynamic _sortKeys(dynamic value) {
    if (value is Map<String, dynamic>) {
      final sorted = <String, dynamic>{};
      for (final key in (value.keys.toList()..sort())) {
        sorted[key] = _sortKeys(value[key]);
      }
      return sorted;
    }
    if (value is List) return value.map(_sortKeys).toList();
    return value;
  }
}
```

## File 2: `lib/services/sync/org_sync_service.dart`

```dart
import 'dart:async';
import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import 'json_converter.dart';
import 'sync_service.dart';

/// Sync service for organization-level data
class OrgSyncService {
  final AppDatabase _db;
  final SupabaseClient _supabase;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  OrgSyncService(this._db, this._supabase);

  /// Sync all org-level tables
  Future<void> syncAll(String orgId) async {
    await syncOrganization(orgId);
    await syncSubscription(orgId);
    await syncOrgMembers(orgId);
    await syncUserStores(orgId);
    await syncPosTerminals(orgId);
  }

  /// Sync single organization
  Future<void> syncOrganization(String orgId) async {
    final remote = await _supabase
        .from('organizations')
        .select()
        .eq('id', orgId)
        .maybeSingle();

    if (remote != null) {
      final local = _jsonConverter.toLocal('organizations', remote);
      await _db.organizationsDao.upsertOrganization(
        _mapToOrganizationCompanion(local),
      );
    }
  }

  /// Sync subscription for org
  Future<void> syncSubscription(String orgId) async {
    final remote = await _supabase
        .from('subscriptions')
        .select()
        .eq('org_id', orgId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (remote != null) {
      final local = _jsonConverter.toLocal('subscriptions', remote);
      await _db.organizationsDao.upsertSubscription(
        _mapToSubscriptionCompanion(local),
      );
    }
  }

  /// Sync org members
  Future<void> syncOrgMembers(String orgId) async {
    final remoteList = await _supabase
        .from('org_members')
        .select()
        .eq('org_id', orgId);

    for (final remote in remoteList) {
      await _db.orgMembersDao.upsertOrgMember(
        _mapToOrgMemberCompanion(remote),
      );
    }
  }

  /// Sync user-store assignments
  Future<void> syncUserStores(String orgId) async {
    final storeIds = await _supabase
        .from('stores')
        .select('id')
        .eq('org_id', orgId);

    for (final store in storeIds) {
      final remoteList = await _supabase
          .from('user_stores')
          .select()
          .eq('store_id', store['id']);

      for (final remote in remoteList) {
        await _db.orgMembersDao.upsertUserStore(
          _mapToUserStoreCompanion(remote),
        );
      }
    }
  }

  /// Sync POS terminals
  Future<void> syncPosTerminals(String orgId) async {
    final remoteList = await _supabase
        .from('pos_terminals')
        .select()
        .eq('org_id', orgId);

    for (final remote in remoteList) {
      final local = _jsonConverter.toLocal('pos_terminals', remote);
      await _db.posTerminalsDao.upsertTerminal(
        _mapToTerminalCompanion(local),
      );
    }
  }

  /// Upload local changes to remote
  Future<void> pushOrganization(String orgId) async {
    final local = await _db.organizationsDao.getOrganizationById(orgId);
    if (local == null) return;

    final payload = _organizationToMap(local);
    final remote = _jsonConverter.toRemote('organizations', payload);

    await _supabase.from('organizations').upsert(remote);
    await _db.organizationsDao.markOrgAsSynced(orgId);
  }

  // === Helper conversion methods ===

  static String convertJsonbToText(dynamic value) {
    if (value == null) return '{}';
    if (value is String) return value;
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
  }

  static Map<String, dynamic> convertTextToJsonb(String value) {
    if (value.isEmpty) return {};
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  // Private mapping methods would be implemented based on
  // the exact Companion class signatures from code generation.
  // These are stubs:

  OrganizationsTableCompanion _mapToOrganizationCompanion(
      Map<String, dynamic> data) {
    // Map JSON data to OrganizationsTableCompanion
    throw UnimplementedError('Implement after code generation');
  }

  SubscriptionsTableCompanion _mapToSubscriptionCompanion(
      Map<String, dynamic> data) {
    throw UnimplementedError('Implement after code generation');
  }

  OrgMembersTableCompanion _mapToOrgMemberCompanion(
      Map<String, dynamic> data) {
    throw UnimplementedError('Implement after code generation');
  }

  UserStoresTableCompanion _mapToUserStoreCompanion(
      Map<String, dynamic> data) {
    throw UnimplementedError('Implement after code generation');
  }

  PosTerminalsTableCompanion _mapToTerminalCompanion(
      Map<String, dynamic> data) {
    throw UnimplementedError('Implement after code generation');
  }

  Map<String, dynamic> _organizationToMap(OrganizationsTableData org) {
    throw UnimplementedError('Implement after code generation');
  }
}
```

## Modifications to `sync_manager.dart`

Add org sync to the sync flow:

```dart
// In SyncManager class, add:
final OrgSyncService _orgSyncService;

// In syncAll() method, add at the beginning:
await _orgSyncService.syncAll(currentOrgId);
```

## Modifications to `sync_api_service.dart`

Add API endpoints for new tables:

```dart
// Add these table names to the sync table list:
'organizations',
'subscriptions',
'org_members',
'user_stores',
'pos_terminals',
```
