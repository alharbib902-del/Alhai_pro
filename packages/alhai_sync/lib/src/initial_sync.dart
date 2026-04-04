import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:alhai_database/alhai_database.dart';
import 'json_converter.dart';
import 'sync_table_validator.dart';

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

  /// الحد الأقصى لعدد الصفحات لكل جدول لمنع استهلاك الذاكرة الزائد
  /// 200 صفحة × 500 سجل = 100,000 سجل كحد أقصى لكل جدول
  static const int _maxPagesPerTable = 200;

  /// خريطة التبعيات: كل جدول يعتمد على الجداول المذكورة
  /// إذا فشل أحد الجداول الأساسية، يتم تخطي الجداول التابعة
  static const Map<String, List<String>> _tableDependencies = {
    'stores': ['organizations'],
    'users': ['organizations'],
    'roles': ['stores'],
    'categories': ['stores'],
    'products': ['stores', 'categories'],
    'customers': ['stores'],
    'customer_addresses': ['customers'],
    'shifts': ['stores', 'users'],
    'sales': ['stores', 'users'],
    'sale_items': ['sales', 'products'],
  };

  /// ترتيب الجداول للتحميل (حسب التبعيات)
  /// الترتيب مهم: الجداول المرجعية أولاً، ثم الجداول التي تعتمد عليها
  static const List<String> downloadOrder = [
    // المرحلة 1: البنية الأساسية
    'organizations',
    'stores',
    'users',
    'roles',
    // المرحلة 2: البيانات المرجعية
    'categories',
    'org_products',
    'products',
    'settings',
    'expense_categories',
    // المرحلة 3: البيانات التشغيلية (Pull)
    'discounts',
    'coupons',
    'promotions',
    'loyalty_rewards',
    'drivers',
    // المرحلة 4: البيانات ثنائية الاتجاه
    'customers',
    'customer_addresses',
    'suppliers',
    'accounts',
    'loyalty_points',
    'whatsapp_templates',
    // المرحلة 5: البيانات التفصيلية (تعتمد على جداول أعلاه)
    'shifts',
    'notifications',
    'product_expiry',
    // المرحلة 6: المبيعات (لاسترجاع البيانات بعد إعادة التشغيل)
    'sales',
    'sale_items',
  ];

  final _progressController = StreamController<InitialSyncProgress>.broadcast();

  InitialSync({
    required SupabaseClient client,
    required AppDatabase db,
    required SyncMetadataDao metadataDao,
  })  : _client = client,
        _db = db,
        _metadataDao = metadataDao;

  /// Stream لحالة التقدم
  Stream<InitialSyncProgress> get progressStream => _progressController.stream;

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
    final failedTables = <String>{};

    for (int i = 0; i < tablesToSync.length; i++) {
      final tableName = tablesToSync[i];

      // تخطي الجدول إذا فشل أحد الجداول التي يعتمد عليها
      final deps = _tableDependencies[tableName];
      if (deps != null && deps.any((dep) => failedTables.contains(dep))) {
        final failedDeps =
            deps.where((dep) => failedTables.contains(dep)).toList();
        final skipMsg =
            '$tableName: skipped (dependency failed: ${failedDeps.join(", ")})';
        errors.add(skipMsg);
        failedTables.add(tableName);

        if (kDebugMode) {
          debugPrint('InitialSync: $skipMsg');
        }
        continue;
      }

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
        failedTables.add(tableName);
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
    int pageCount = 0;

    while (hasMore && pageCount < _maxPagesPerTable) {
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
      pageCount++;

      if (records.length < pageSize) {
        hasMore = false;
      } else {
        offset += pageSize;
      }
    }

    if (pageCount >= _maxPagesPerTable) {
      debugPrint(
        '[InitialSync] Reached max pages ($pageCount) for table $tableName. '
        'Downloaded $totalRecords records. Remaining records skipped to prevent OOM.',
      );
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
        .order(_getOrderColumn(tableName), ascending: true)
        .range(offset, offset + pageSize - 1)
        .timeout(const Duration(seconds: 30));

    final records = List<Map<String, dynamic>>.from(response);
    return _jsonConverter.batchToLocal(tableName, records);
  }

  /// أعمدة التواريخ المعروفة التي يجب تحويلها من ISO 8601 إلى Unix seconds
  static const Set<String> _dateTimeColumns = {
    'created_at', 'updated_at', 'synced_at', 'deleted_at',
    'opened_at', 'closed_at', 'issued_at', 'due_at', 'paid_at',
    'expires_at', 'start_date', 'end_date', 'last_login',
    'completed_at', 'confirmed_at', 'cancelled_at', 'delivered_at',
    'shipped_at', 'refunded_at', 'voided_at', 'activated_at',
    'deactivated_at', 'last_sync_at', 'last_pull_at', 'last_push_at',
    // Additional datetime columns from database tables
    'order_date', 'preparing_at', 'ready_at', 'delivering_at',
    'received_at', 'approved_at', 'started_at', 'expiry_date',
    'expense_date', 'read_at', 'sent_at', 'last_attempt_at',
    'last_transaction_at', 'trial_ends_at', 'last_heartbeat_at',
    'current_period_start', 'current_period_end',
    'invited_at', 'joined_at', 'last_login_at',
  };

  /// تحويل ISO 8601 timestamps إلى Unix seconds (ما يتوقعه Drift)
  dynamic _convertValue(String column, dynamic value) {
    if (value == null) return null;
    if (!_dateTimeColumns.contains(column)) return value;
    if (value is int) return value; // بالفعل Unix seconds
    if (value is String) {
      try {
        return DateTime.parse(value).millisecondsSinceEpoch ~/ 1000;
      } catch (_) {
        return null;
      }
    }
    return value;
  }

  /// إدراج مجموعة سجلات محلياً
  /// يتم تعطيل Foreign Keys مؤقتاً أثناء المزامنة الأولية
  /// لأن البيانات قادمة من السيرفر وسلامتها مضمونة
  Future<void> _insertBatch(
      String tableName, List<Map<String, dynamic>> records) async {
    if (records.isEmpty) return;
    validateTableName(tableName);

    // تعطيل FK خارج الـ batch (PRAGMA لا يعمل داخل batch في WASM)
    await _db.customStatement('PRAGMA foreign_keys = OFF');

    try {
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
            columns.map((c) => _convertValue(c, record[c])).toList(),
          );
        }
      });
    } finally {
      // إعادة تفعيل FK دائماً
      await _db.customStatement('PRAGMA foreign_keys = ON');
    }
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
    // هذه الجداول لديها org_id فعلياً في Supabase
    // ملاحظة: drivers ليس لديها org_id (فقط store_id)
    const tablesWithOrgId = {
      'stores', 'users', 'categories', 'products',
      'customers', 'suppliers', 'expenses',
      // جداول جديدة
      'discounts', 'coupons', 'promotions', 'loyalty_rewards',
      'customer_addresses', 'accounts',
      'loyalty_points', 'shifts', 'notifications', 'product_expiry',
      'org_products',
    };
    return tablesWithOrgId.contains(tableName);
  }

  bool _hasStoreIdColumn(String tableName) {
    // customer_addresses: ليس لديها store_id (مرتبطة بالعميل مباشرة)
    // sale_items: ليس لديها store_id (مرتبطة بالبيع مباشرة)
    const tablesWithStoreId = {
      'products', 'categories', 'customers', 'settings',
      'suppliers', 'expense_categories', 'roles',
      // جداول جديدة
      'discounts', 'coupons', 'promotions', 'loyalty_rewards',
      'drivers', 'accounts',
      'loyalty_points', 'shifts', 'notifications',
      'product_expiry', 'whatsapp_templates',
      // المبيعات
      'sales',
    };
    return tablesWithStoreId.contains(tableName);
  }

  /// عمود الترتيب الزمني المتاح لكل جدول
  String _getOrderColumn(String tableName) {
    // جداول بدون created_at، فقط updated_at
    const updatedAtOnly = {'settings', 'whatsapp_templates'};
    if (updatedAtOnly.contains(tableName)) return 'updated_at';

    // جداول بدون created_at - ترتيب بعمود opened_at
    // shifts في Supabase لديها opened_at وليس created_at
    if (tableName == 'shifts') return 'opened_at';

    // sale_items ليس لديها created_at ولا updated_at، ترتيب بـ id
    if (tableName == 'sale_items') return 'id';

    return 'created_at';
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
