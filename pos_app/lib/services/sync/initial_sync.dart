import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local/app_database.dart';
import '../../data/local/daos/sync_metadata_dao.dart';
import 'json_converter.dart';

/// حالة تقدم المزامنة الأولية
class InitialSyncProgress {
  final String currentTable;
  final int currentTableIndex;
  final int totalTables;
  final int recordsDownloaded;
  final bool isComplete;
  final String? error;

  const InitialSyncProgress({
    this.currentTable = '',
    this.currentTableIndex = 0,
    this.totalTables = 0,
    this.recordsDownloaded = 0,
    this.isComplete = false,
    this.error,
  });

  double get progress =>
      totalTables > 0 ? currentTableIndex / totalTables : 0.0;
}

/// المزامنة الأولية: تحميل البيانات الكاملة عند إعداد الجهاز لأول مرة
///
/// ترتيب التحميل (حسب التبعيات):
/// 1. organizations → المؤسسة
/// 2. stores → المتاجر
/// 3. users → المستخدمين
/// 4. roles → الأدوار
/// 5. categories → التصنيفات
/// 6. products → المنتجات
/// 7. customers → العملاء
/// 8. settings → الإعدادات
/// 9. suppliers → الموردين
/// 10. expense_categories → فئات المصروفات
///
/// ميزات:
/// - استئناف التحميل إذا انقطع
/// - تقدم مفصل عبر Stream
/// - التحقق من سلامة البيانات بعد التحميل
class InitialSync {
  final SupabaseClient _client;
  final AppDatabase _db;
  final SyncMetadataDao _metadataDao;
  final JsonColumnConverter _jsonConverter = JsonColumnConverter.instance;

  /// حجم الصفحة
  static const int pageSize = 500;

  /// ترتيب الجداول للتحميل (حسب التبعيات)
  static const List<String> downloadOrder = [
    'organizations',
    'stores',
    'users',
    'roles',
    'categories',
    'products',
    'customers',
    'settings',
    'suppliers',
    'expense_categories',
  ];

  final _progressController =
      StreamController<InitialSyncProgress>.broadcast();

  InitialSync({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _db = db,
        _metadataDao = metadataDao;

  /// Stream لحالة التقدم
  Stream<InitialSyncProgress> get progressStream =>
      _progressController.stream;

  /// هل تمت المزامنة الأولية لجميع الجداول؟
  Future<bool> isComplete() async {
    for (final tableName in downloadOrder) {
      final synced = await _metadataDao.isInitialSynced(tableName);
      if (!synced) return false;
    }
    return true;
  }

  /// الجداول التي لم تتم مزامنتها بعد (لميزة الاستئناف)
  Future<List<String>> getRemainingTables() async {
    final remaining = <String>[];
    for (final tableName in downloadOrder) {
      final synced = await _metadataDao.isInitialSynced(tableName);
      if (!synced) remaining.add(tableName);
    }
    return remaining;
  }

  /// تنفيذ المزامنة الأولية
  Future<InitialSyncResult> execute({
    required String orgId,
    required String storeId,
  }) async {
    final errors = <String>[];
    int totalRecords = 0;

    // الحصول على الجداول المتبقية (للاستئناف)
    final tablesToSync = await getRemainingTables();

    if (tablesToSync.isEmpty) {
      _emitProgress(const InitialSyncProgress(isComplete: true));
      return InitialSyncResult(
        success: true,
        totalRecords: 0,
        errors: [],
      );
    }

    final totalTables = tablesToSync.length;

    for (int i = 0; i < tablesToSync.length; i++) {
      final tableName = tablesToSync[i];

      _emitProgress(InitialSyncProgress(
        currentTable: tableName,
        currentTableIndex: i,
        totalTables: totalTables,
        recordsDownloaded: totalRecords,
      ));

      try {
        final count = await _downloadTable(
          tableName: tableName,
          orgId: orgId,
          storeId: storeId,
        );
        totalRecords += count;

        // تعيين كـ "تمت المزامنة الأولية"
        await _metadataDao.markInitialSynced(tableName);
        await _metadataDao.updateLastPullAt(
          tableName,
          DateTime.now().toUtc(),
          syncCount: count,
        );
      } catch (e) {
        errors.add('$tableName: $e');
        await _metadataDao.setError(tableName, e.toString());

        if (kDebugMode) {
          debugPrint('InitialSync error for $tableName: $e');
        }

        // نستمر في بقية الجداول حتى لو فشل أحدها
      }
    }

    final isComplete = errors.isEmpty;

    _emitProgress(InitialSyncProgress(
      currentTable: '',
      currentTableIndex: totalTables,
      totalTables: totalTables,
      recordsDownloaded: totalRecords,
      isComplete: isComplete,
      error: errors.isNotEmpty ? errors.join('; ') : null,
    ));

    // التحقق من سلامة البيانات
    if (isComplete) {
      await _validateDataIntegrity();
    }

    return InitialSyncResult(
      success: isComplete,
      totalRecords: totalRecords,
      errors: errors,
    );
  }

  /// تحميل جدول كامل من السيرفر
  Future<int> _downloadTable({
    required String tableName,
    required String orgId,
    required String storeId,
  }) async {
    int totalRecords = 0;
    int offset = 0;
    bool hasMore = true;

    while (hasMore) {
      final records = await _fetchPage(
        tableName: tableName,
        orgId: orgId,
        storeId: storeId,
        offset: offset,
      );

      if (records.isEmpty) {
        hasMore = false;
        break;
      }

      // إدراج محلياً
      await _insertBatch(tableName, records);
      totalRecords += records.length;

      if (records.length < pageSize) {
        hasMore = false;
      } else {
        offset += pageSize;
      }
    }

    return totalRecords;
  }

  /// جلب صفحة من البيانات
  Future<List<Map<String, dynamic>>> _fetchPage({
    required String tableName,
    required String orgId,
    required String storeId,
    int offset = 0,
  }) async {
    var query = _client.from(tableName).select();

    // فلترة حسب المؤسسة/المتجر
    if (tableName == 'organizations') {
      query = query.eq('id', orgId);
    } else if (_hasOrgIdColumn(tableName)) {
      query = query.eq('org_id', orgId);
    }

    if (_hasStoreIdColumn(tableName)) {
      query = query.eq('store_id', storeId);
    }

    final response = await query
        .order('created_at', ascending: true)
        .range(offset, offset + pageSize - 1);

    final records = List<Map<String, dynamic>>.from(response);
    return _jsonConverter.batchToLocal(tableName, records);
  }

  /// إدراج مجموعة سجلات محلياً
  Future<void> _insertBatch(
      String tableName, List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;

    await _db.batch((batch) {
      for (final record in records) {
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
    });
  }

  /// التحقق من سلامة البيانات بعد التحميل
  Future<void> _validateDataIntegrity() async {
    try {
      // التحقق أن المنتجات لها تصنيفات موجودة
      final orphanProducts = await _db.customSelect(
        '''SELECT COUNT(*) as count FROM products p
           WHERE p.category_id IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM categories c WHERE c.id = p.category_id)''',
      ).getSingle();

      final orphanCount = orphanProducts.data['count'] as int? ?? 0;
      if (orphanCount > 0 && kDebugMode) {
        debugPrint(
            'Warning: $orphanCount products have orphaned category references');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Data integrity validation error: $e');
      }
    }
  }

  bool _hasOrgIdColumn(String tableName) {
    return tableName != 'organizations' && tableName != 'settings';
  }

  bool _hasStoreIdColumn(String tableName) {
    const tablesWithStoreId = {
      'products', 'categories', 'customers', 'settings',
      'suppliers', 'expense_categories',
    };
    return tablesWithStoreId.contains(tableName);
  }

  void _emitProgress(InitialSyncProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void dispose() {
    _progressController.close();
  }
}

/// نتيجة المزامنة الأولية
class InitialSyncResult {
  final bool success;
  final int totalRecords;
  final List<String> errors;

  InitialSyncResult({
    required this.success,
    required this.totalRecords,
    required this.errors,
  });
}
