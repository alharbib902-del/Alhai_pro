import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import '../json_converter.dart';
import '../sync_payload_utils.dart';
import '../sync_table_validator.dart';

/// L45: Whitelist of table names allowed in customStatement SQL calls.
/// This prevents SQL injection via server-provided table names.
const _allowedTables = {
  'products',
  'categories',
  'customers',
  'orders',
  'sales',
  'sale_items',
  'inventory_movements',
  'suppliers',
  'expenses',
  'stores',
  'users',
  'org_members',
  'organizations',
  'sync_queue',
  'sync_metadata',
  'stock_deltas',
  'returns',
  'purchases',
  'shifts',
  'accounts',
  'transactions',
  'notifications',
  'loyalty_points',
  'loyalty_tiers',
  'pos_terminals',
  'settings',
  'favorites',
  'held_invoices',
  'discounts',
  'promotions',
  'drivers',
  'audit_log',
  'whatsapp_messages',
  'whatsapp_templates',
  'daily_summaries',
  // Additional tables from sync_table_validator
  'order_items',
  'purchase_items',
  'return_items',
  'expense_categories',
  'coupons',
  'loyalty_transactions',
  'loyalty_rewards',
  'user_stores',
  'customer_addresses',
  'product_expiry',
  'roles',
  'org_products',
  'stock_transfers',
};

/// Validates that [tableName] is in the local [_allowedTables] whitelist.
/// Throws [Exception] if the table name is not allowed.
void _validatePullTable(String tableName) {
  if (!_allowedTables.contains(tableName)) {
    throw Exception('Invalid table: $tableName');
  }
}

/// استراتيجية السحب (Pull): السيرفر ← المحلي
/// تُستخدم للبيانات التي يديرها السيرفر: المنتجات، التصنيفات، المتاجر، الأدوار، الإعدادات
///
/// آلية العمل:
/// 1. جلب آخر وقت سحب من sync_metadata
/// 2. جلب السجلات المحدثة من السيرفر (updated_at > last_pull_at)
/// 3. إدراج أو تحديث محلياً (upsert)
/// 4. تحديث last_pull_at في sync_metadata
class PullStrategy {
  final SupabaseClient _client;
  final AppDatabase _db;
  final SyncMetadataDao _metadataDao;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// الجداول التي يتم سحبها من السيرفر
  /// هذه البيانات يديرها المشرف/السيرفر ونقطة البيع تستهلكها فقط
  static const List<String> pullTables = [
    'categories',
    'products',
    'stores',
    'roles',
    'settings',
    // جداول جديدة
    'users',
    'discounts',
    'coupons',
    'promotions',
    'loyalty_rewards',
    'drivers',
    'expense_categories',
    'org_products',
  ];

  /// حجم الصفحة لجلب البيانات
  static const int pageSize = 500;

  PullStrategy({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _db = db,
        _metadataDao = metadataDao;

  /// تنفيذ السحب لجدول معين
  Future<PullResult> pullTable({
    required String tableName,
    required String orgId,
    required String storeId,
  }) async {
    int totalPulled = 0;
    final errors = <String>[];

    try {
      // جلب آخر وقت سحب
      final lastPullAt = await _metadataDao.getLastPullAt(tableName);

      // جلب البيانات من السيرفر بالصفحات
      int page = 0;
      bool hasMore = true;

      while (hasMore) {
        final records = await _fetchPage(
          tableName: tableName,
          orgId: orgId,
          storeId: storeId,
          since: lastPullAt,
          offset: page * pageSize,
        );

        if (records.isEmpty) {
          hasMore = false;
          break;
        }

        // إدراج/تحديث محلياً
        await _upsertLocally(tableName, records);
        totalPulled += records.length;

        if (records.length < pageSize) {
          hasMore = false;
        } else {
          page++;
        }
      }

      // إعادة بناء فهرس FTS بعد سحب المنتجات
      if (tableName == 'products' && totalPulled > 0) {
        try {
          await _db.customStatement(
              "INSERT INTO products_fts(products_fts) VALUES('rebuild')");
          if (kDebugMode) {
            debugPrint('[Pull] FTS index rebuilt after pulling $totalPulled products');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[Pull] FTS rebuild failed (non-fatal): $e');
          }
        }
      }

      // تحديث آخر وقت سحب
      await _metadataDao.updateLastPullAt(
        tableName,
        DateTime.now().toUtc(),
        syncCount: totalPulled,
      );
      await _metadataDao.clearError(tableName);
    } catch (e) {
      errors.add('Pull $tableName: $e');
      await _metadataDao.setError(tableName, e.toString());
      if (kDebugMode) {
        debugPrint('PullStrategy error for $tableName: $e');
      }
    }

    return PullResult(
      tableName: tableName,
      recordsPulled: totalPulled,
      errors: errors,
    );
  }

  /// تنفيذ السحب لجميع الجداول
  Future<List<PullResult>> pullAll({
    required String orgId,
    required String storeId,
  }) async {
    final results = <PullResult>[];
    for (final tableName in pullTables) {
      final result = await pullTable(
        tableName: tableName,
        orgId: orgId,
        storeId: storeId,
      );
      results.add(result);
    }
    return results;
  }

  /// جلب صفحة من البيانات من السيرفر
  Future<List<Map<String, dynamic>>> _fetchPage({
    required String tableName,
    required String orgId,
    required String storeId,
    DateTime? since,
    int offset = 0,
  }) async {
    var query = _client.from(tableName).select();

    // فلترة حسب الأعمدة المتاحة لكل جدول
    if (_hasOrgId(tableName)) {
      query = query.eq('org_id', orgId);
    }
    if (_hasStoreId(tableName)) {
      query = query.eq('store_id', storeId);
    }
    // stores: filter by org_id only (the store IS the row, no store_id column)
    // roles, settings: filter by store_id only (no org_id column)

    if (since != null) {
      query = query.gte('updated_at', since.toUtc().toIso8601String());
    }

    final response = await query
        .order('updated_at', ascending: true)
        .range(offset, offset + pageSize - 1)
        .timeout(const Duration(seconds: 30));

    final records = List<Map<String, dynamic>>.from(response);
    final jsonConverted = _jsonConverter.batchToLocal(tableName, records);
    // M36: إعادة تسمية أعمدة Supabase لتتوافق مع مخطط Drift المحلي
    return batchMapColumnsToLocal(tableName, jsonConverted);
  }

  /// هل يحتوي الجدول على عمود org_id في Supabase؟
  bool _hasOrgId(String tableName) {
    const tablesWithOrgId = {
      'categories', 'products', 'stores',
      // جداول جديدة
      'users', 'discounts', 'coupons', 'promotions',
      'loyalty_rewards', 'drivers', 'org_products',
    };
    return tablesWithOrgId.contains(tableName);
  }

  /// هل يحتوي الجدول على عمود store_id في Supabase؟
  bool _hasStoreId(String tableName) {
    const tablesWithStoreId = {
      'categories', 'products', 'roles', 'settings',
      // جداول جديدة
      'discounts', 'coupons', 'promotions',
      'loyalty_rewards', 'drivers', 'expense_categories',
    };
    return tablesWithStoreId.contains(tableName);
  }

  /// إدراج/تحديث السجلات محلياً باستخدام SQL مباشر
  Future<void> _upsertLocally(
      String tableName, List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    validateTableName(tableName);
    // L45: Additional whitelist validation before customStatement calls
    _validatePullTable(tableName);

    await _db.batch((batch) {
      for (final record in records) {
        // التعامل مع الحذف الناعم
        final deletedAt = record['deleted_at'];
        if (deletedAt != null) {
          // حذف ناعم: حذف السجل محلياً
          batch.customStatement(
            'DELETE FROM $tableName WHERE id = ?',
            [record['id']],
          );
        } else {
          // إدراج أو تحديث
          final columns = record.keys.toList();
          final placeholders = columns.map((_) => '?').join(', ');
          final updates = columns
              .where((c) => c != 'id')
              .map((c) => '$c = excluded.$c')
              .join(', ');

          batch.customStatement(
            'INSERT INTO $tableName (${columns.join(', ')}) '
            'VALUES ($placeholders) '
            'ON CONFLICT(id) DO UPDATE SET $updates',
            columns.map((c) => record[c]).toList(),
          );
        }
      }
    });
  }
}

/// نتيجة عملية السحب
class PullResult {
  final String tableName;
  final int recordsPulled;
  final List<String> errors;

  PullResult({
    required this.tableName,
    required this.recordsPulled,
    required this.errors,
  });

  bool get hasErrors => errors.isNotEmpty;
}
