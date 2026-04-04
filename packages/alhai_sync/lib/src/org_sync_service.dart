import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'json_converter.dart';
import 'sync_payload_utils.dart';

/// Organization-level table names for multi-tenant sync
class OrgTables {
  static const String organizations = 'organizations';
  static const String subscriptions = 'subscriptions';
  static const String orgMembers = 'org_members';
  static const String userStores = 'user_stores';
  static const String posTerminals = 'pos_terminals';
  static const String orgProducts = 'org_products';

  /// All org-level tables in sync priority order
  static const List<String> all = [
    organizations,
    subscriptions,
    orgMembers,
    userStores,
    posTerminals,
    orgProducts,
  ];

  OrgTables._();
}

/// خدمة مزامنة بيانات المؤسسة
class OrgSyncService {
  final SupabaseClient _client;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  OrgSyncService({required SupabaseClient client}) : _client = client;

  /// تنفيذ المزامنة لعملية واحدة على جدول مؤسسة
  Future<void> syncOperation({
    required String tableName,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final remotePayload = _jsonConverter.toRemote(tableName, payload);

    switch (operation.toUpperCase()) {
      case 'CREATE':
      case 'UPDATE':
        await _upsert(tableName, remotePayload);
        break;
      case 'DELETE':
        await _delete(tableName, remotePayload);
        break;
      default:
        throw UnsupportedError('Unsupported operation: $operation');
    }
  }

  Future<void> _upsert(
    String tableName,
    Map<String, dynamic> payload,
  ) async {
    final cleanPayload = _cleanPayload(payload, tableName: tableName);
    try {
      await _client
          .from(tableName)
          .upsert(cleanPayload, onConflict: 'id')
          .timeout(const Duration(seconds: 30));
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OrgSync upsert DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('OrgSync upsert timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrgSync upsert error for $tableName: $e');
      }
      rethrow;
    }
  }

  Future<void> _delete(
    String tableName,
    Map<String, dynamic> payload,
  ) async {
    final id = payload['id'] as String?;
    if (id == null) {
      throw ArgumentError('Delete operation requires an "id" field');
    }
    try {
      await _client
          .from(tableName)
          .delete()
          .eq('id', id)
          .timeout(const Duration(seconds: 30));
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OrgSync delete DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('OrgSync delete timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrgSync delete error for $tableName: $e');
      }
      rethrow;
    }
  }

  /// جلب التحديثات من السيرفر لمؤسسة معينة
  Future<List<Map<String, dynamic>>> fetchOrgUpdates({
    required String tableName,
    required String orgId,
    DateTime? since,
  }) async {
    try {
      var query = _client.from(tableName).select();

      if (tableName == OrgTables.organizations) {
        query = query.eq('id', orgId);
      } else {
        query = query.eq('org_id', orgId);
      }

      if (since != null) {
        query = query.gte('updated_at', since.toIso8601String());
      }

      final response = await query.timeout(const Duration(seconds: 30));
      final records = List<Map<String, dynamic>>.from(response);
      return _jsonConverter.batchToLocal(tableName, records);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OrgSync fetch DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('OrgSync fetch timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrgSync fetch error for $tableName: $e');
      }
      rethrow;
    }
  }

  /// جلب التحديثات من السيرفر لمتجر معين
  Future<List<Map<String, dynamic>>> fetchStoreUpdates({
    required String tableName,
    required String storeId,
    DateTime? since,
  }) async {
    try {
      var query = _client.from(tableName).select().eq('store_id', storeId);

      if (since != null) {
        query = query.gte('updated_at', since.toIso8601String());
      }

      final response = await query.timeout(const Duration(seconds: 30));
      final records = List<Map<String, dynamic>>.from(response);
      return _jsonConverter.batchToLocal(tableName, records);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint(
            'OrgSync fetch DB error for $tableName: ${e.code} ${e.message}');
      }
      rethrow;
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('OrgSync fetch timeout for $tableName');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OrgSync fetch error for $tableName: $e');
      }
      rethrow;
    }
  }

  Map<String, dynamic> _cleanPayload(
    Map<String, dynamic> payload, {
    String? tableName,
  }) {
    return cleanSyncPayload(payload, removeItems: false, tableName: tableName);
  }
}
