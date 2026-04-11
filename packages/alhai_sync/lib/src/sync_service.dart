import 'dart:convert';
import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';

/// أنواع عمليات المزامنة
enum SyncOperation { create, update, delete }

/// أولوية المزامنة
enum SyncPriority { low, normal, high }

/// الجداول ذات الأولوية العالية (المبيعات والمخزون) - لا تخضع لحد الطابور
const _highPriorityTables = {
  'sales',
  'sale_items',
  'inventory_movements',
  'cash_movements',
};

/// خدمة طابور المزامنة
/// تضيف العمليات للطابور المحلي ليتم مزامنتها لاحقاً
class SyncService {
  final SyncQueueDao _syncQueueDao;
  final _uuid = const Uuid();

  /// آخر صحة طابور مؤقتة (لتجنب استعلام كل مرة)
  SyncQueueHealth? _cachedHealth;
  DateTime? _healthCacheTime;

  SyncService(this._syncQueueDao);

  /// إضافة عملية للطابور مع حماية من التكرار ودمج العمليات
  Future<String> enqueue({
    required String tableName,
    required String recordId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    SyncPriority priority = SyncPriority.normal,
  }) async {
    // === حماية حجم الطابور ===
    // تأجيل العناصر منخفضة الأولوية إذا الطابور ممتلئ
    if (!_highPriorityTables.contains(tableName) &&
        priority != SyncPriority.high) {
      final health = await _getCachedHealth();
      if (health.isOverloaded) {
        developer.log(
          'SyncService: queue overloaded (${health.activeCount} items), '
          'deferring low-priority item ($tableName/$recordId)',
          name: 'SyncService',
        );
        // لا نرفض، لكن نسجل تحذير - العناصر ذات الأولوية العالية تمر دائماً
        // نقبل العنصر لكن بأولوية منخفضة
        priority = SyncPriority.low;
      }
    }

    // === التحقق من صلاحية البيانات قبل الإضافة ===
    if (!_isValidPayload(tableName, payload)) {
      developer.log(
        'SyncService: invalid payload rejected for $tableName/$recordId',
        name: 'SyncService',
      );
      throw ArgumentError('Invalid sync payload for $tableName/$recordId');
    }

    // === دمج العمليات المتقاطعة (Cross-operation dedup) ===
    final crossDedup = await _handleCrossOperationDedup(
      tableName: tableName,
      recordId: recordId,
      operation: operation,
      payload: payload,
    );
    if (crossDedup != null) {
      return crossDedup; // تم دمج/إلغاء العملية
    }

    // === دمج العمليات المتشابهة (Same-operation dedup) ===
    final id = _uuid.v4();
    var idempotencyKey = '${tableName}_${recordId}_${operation.name}';

    final existing = await _syncQueueDao.findByIdempotencyKey(idempotencyKey);
    if (existing != null) {
      if (existing.status == 'pending') {
        // العنصر لم يُرسل بعد - تحديث البيانات فقط (coalesce rapid updates)
        developer.log(
          'SyncService: coalescing update - updating pending item payload '
          '(id=${existing.id}, key=$idempotencyKey)',
          name: 'SyncService',
        );
        await _syncQueueDao.updatePayload(existing.id, jsonEncode(payload));
        return existing.id;
      } else if (existing.status == 'syncing') {
        // العنصر قيد الإرسال حالياً - إنشاء عنصر جديد بمفتاح فريد
        idempotencyKey =
            '${idempotencyKey}_${DateTime.now().millisecondsSinceEpoch}';
        developer.log(
          'SyncService: existing item is syncing, creating new entry (key=$idempotencyKey)',
          name: 'SyncService',
        );
      } else {
        // العنصر تمت مزامنته أو فشل - حذف القديم وإنشاء جديد
        developer.log(
          'SyncService: removing old ${existing.status} item (id=${existing.id}), creating new entry',
          name: 'SyncService',
        );
        await _syncQueueDao.removeItem(existing.id);
      }
    }

    await _syncQueueDao.enqueue(
      id: id,
      tableName: tableName,
      recordId: recordId,
      operation: operation.name.toUpperCase(),
      payload: jsonEncode(payload),
      idempotencyKey: idempotencyKey,
      priority: _priorityToInt(priority),
    );

    // إبطال كاش الصحة عند إضافة عنصر جديد
    _healthCacheTime = null;

    return id;
  }

  /// دمج العمليات المتقاطعة:
  /// - DELETE بعد CREATE (كلاهما معلق) → إلغاء كليهما
  /// - UPDATE بعد CREATE (كلاهما معلق) → دمج UPDATE في CREATE
  Future<String?> _handleCrossOperationDedup({
    required String tableName,
    required String recordId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final pendingItems = await _syncQueueDao.findPendingByTableRecord(
      tableName,
      recordId,
    );
    if (pendingItems.isEmpty) return null;

    // حالة 1: DELETE بعد CREATE → إلغاء كليهما
    if (operation == SyncOperation.delete) {
      final pendingCreate = pendingItems
          .where((item) => item.operation == 'CREATE')
          .toList();
      if (pendingCreate.isNotEmpty) {
        developer.log(
          'SyncService: DELETE cancels pending CREATE for $tableName/$recordId - removing both',
          name: 'SyncService',
        );
        // حذف جميع العناصر المعلقة لهذا السجل (CREATE + أي UPDATE)
        for (final item in pendingItems) {
          await _syncQueueDao.removeItem(item.id);
        }
        _healthCacheTime = null;
        return 'cancelled'; // لا حاجة لإرسال أي شيء
      }
    }

    // حالة 2: UPDATE بعد CREATE → دمج بيانات التحديث في الإنشاء
    if (operation == SyncOperation.update) {
      final pendingCreate = pendingItems
          .where((item) => item.operation == 'CREATE')
          .toList();
      if (pendingCreate.isNotEmpty) {
        final createItem = pendingCreate.first;
        try {
          final createPayload =
              jsonDecode(createItem.payload) as Map<String, dynamic>;
          // دمج بيانات التحديث فوق بيانات الإنشاء
          createPayload.addAll(payload);
          await _syncQueueDao.updatePayload(
            createItem.id,
            jsonEncode(createPayload),
          );
          developer.log(
            'SyncService: merged UPDATE into pending CREATE for $tableName/$recordId',
            name: 'SyncService',
          );
          return createItem.id;
        } catch (e) {
          developer.log(
            'SyncService: failed to merge UPDATE into CREATE, will create separate entry: $e',
            name: 'SyncService',
          );
        }
      }
    }

    return null; // لم يتم الدمج
  }

  /// فحص صلاحية البيانات قبل إضافتها للطابور
  bool _isValidPayload(String tableName, Map<String, dynamic> payload) {
    // لا نقبل بيانات فارغة
    if (payload.isEmpty) return false;

    // التحقق من وجود حقل id (مطلوب لجميع العمليات)
    // باستثناء عمليات الحذف التي قد تحتوي فقط على {deleted: true}
    final hasId = payload.containsKey('id');
    final isDeletePayload = payload.length == 1 && payload['deleted'] == true;
    if (!hasId && !isDeletePayload) return false;

    // التحقق من عدم وجود NaN أو Infinity في الأرقام
    for (final value in payload.values) {
      if (value is double && (value.isNaN || value.isInfinite)) {
        developer.log(
          'SyncService: payload contains NaN/Infinity for $tableName',
          name: 'SyncService',
        );
        return false;
      }
    }

    // التحقق من أن التواريخ معقولة (ليست قبل 2020 أو بعد 2100)
    for (final entry in payload.entries) {
      if (entry.value is String && _looksLikeDate(entry.key)) {
        try {
          final date = DateTime.parse(entry.value as String);
          if (date.year < 2020 || date.year > 2100) {
            developer.log(
              'SyncService: unreasonable date ${entry.key}=${entry.value} for $tableName',
              name: 'SyncService',
            );
            return false;
          }
        } catch (_) {
          // ليس تاريخ - تجاهل
        }
      }
    }

    // التحقق من أن النصوص ليست كبيرة جداً (< 1MB)
    final payloadJson = jsonEncode(payload);
    if (payloadJson.length > 1024 * 1024) {
      developer.log(
        'SyncService: payload too large (${payloadJson.length} bytes) for $tableName',
        name: 'SyncService',
      );
      return false;
    }

    return true;
  }

  /// هل اسم الحقل يشبه تاريخ؟
  bool _looksLikeDate(String fieldName) {
    final lower = fieldName.toLowerCase();
    return lower.endsWith('_at') ||
        lower.endsWith('_date') ||
        lower == 'date' ||
        lower == 'created' ||
        lower == 'updated';
  }

  /// الحصول على صحة الطابور مع كاش لمدة 30 ثانية
  Future<SyncQueueHealth> _getCachedHealth() async {
    final now = DateTime.now();
    if (_cachedHealth != null &&
        _healthCacheTime != null &&
        now.difference(_healthCacheTime!).inSeconds < 30) {
      return _cachedHealth!;
    }
    _cachedHealth = await _syncQueueDao.getQueueHealth();
    _healthCacheTime = now;
    return _cachedHealth!;
  }

  /// إضافة عملية إنشاء
  Future<String> enqueueCreate({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> data,
    SyncPriority priority = SyncPriority.normal,
  }) {
    return enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: SyncOperation.create,
      payload: data,
      priority: priority,
    );
  }

  /// إضافة عملية تحديث
  Future<String> enqueueUpdate({
    required String tableName,
    required String recordId,
    required Map<String, dynamic> changes,
    SyncPriority priority = SyncPriority.normal,
  }) {
    return enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: SyncOperation.update,
      payload: changes,
      priority: priority,
    );
  }

  /// إضافة عملية حذف
  Future<String> enqueueDelete({
    required String tableName,
    required String recordId,
    SyncPriority priority = SyncPriority.normal,
  }) {
    return enqueue(
      tableName: tableName,
      recordId: recordId,
      operation: SyncOperation.delete,
      payload: {'deleted': true},
      priority: priority,
    );
  }

  /// الحصول على العناصر المعلقة
  Future<List<SyncQueueTableData>> getPendingItems() {
    return _syncQueueDao.getPendingItems();
  }

  /// عدد العناصر المعلقة
  Future<int> getPendingCount() {
    return _syncQueueDao.getPendingCount();
  }

  /// مراقبة العناصر المعلقة
  Stream<int> watchPendingCount() {
    return _syncQueueDao.watchPendingCount();
  }

  /// مراقبة العناصر المعلقة مع وقت أقدم عنصر
  Stream<({int count, DateTime? oldestAt})> watchPendingCountWithOldest() {
    return _syncQueueDao.watchPendingCountWithOldest();
  }

  /// تعيين كـ "جاري المزامنة"
  Future<void> markAsSyncing(String id) {
    return _syncQueueDao.markAsSyncing(id);
  }

  /// تعيين كـ "تمت المزامنة"
  Future<void> markAsSynced(String id) {
    return _syncQueueDao.markAsSynced(id);
  }

  /// تعيين كـ "فشل"
  Future<void> markAsFailed(String id, String error) {
    return _syncQueueDao.markAsFailed(id, error);
  }

  /// حذف عنصر
  Future<void> removeItem(String id) {
    return _syncQueueDao.removeItem(id);
  }

  /// الحصول على العناصر العالقة في حالة 'syncing'
  Future<List<SyncQueueTableData>> getStuckSyncingItems() {
    return _syncQueueDao.getStuckSyncingItems();
  }

  /// الحصول على العناصر المتعارضة
  Future<List<SyncQueueTableData>> getConflictItems() {
    return _syncQueueDao.getConflictItems();
  }

  /// مراقبة العناصر المعلقة
  Stream<List<SyncQueueTableData>> watchPendingItems() {
    return _syncQueueDao.watchPendingItems();
  }

  /// مراقبة العناصر المتعارضة
  Stream<List<SyncQueueTableData>> watchConflictItems() {
    return _syncQueueDao.watchConflictItems();
  }

  /// مراقبة عدد العناصر المتعارضة
  Stream<int> watchConflictCount() {
    return _syncQueueDao.watchConflictCount();
  }

  /// تعيين كـ "تم الحل"
  Future<void> markResolved(String id) {
    return _syncQueueDao.markResolved(id);
  }

  /// إعادة المحاولة لعنصر
  Future<void> retryItem(String id) {
    return _syncQueueDao.retryItem(id);
  }

  /// تعيين كـ "تعارض"
  Future<void> markAsConflict(String id, String error) {
    return _syncQueueDao.markAsConflict(id, error);
  }

  /// تنظيف العناصر القديمة
  Future<int> cleanup({Duration olderThan = const Duration(days: 7)}) {
    return _syncQueueDao.cleanupSyncedItems(olderThan: olderThan);
  }

  /// الحصول على صحة الطابور
  Future<SyncQueueHealth> getQueueHealth() {
    return _syncQueueDao.getQueueHealth();
  }

  /// مراقبة صحة الطابور (تحديث كل 30 ثانية عبر الكاش)
  Future<bool> isQueueOverloaded() async {
    final health = await _getCachedHealth();
    return health.isOverloaded;
  }

  /// Reset all items stuck in 'syncing' status back to 'pending' (crash recovery)
  Future<int> resetStuckItems() {
    return _syncQueueDao.resetStuckItems();
  }

  /// استعادة العناصر العالقة في حالة 'syncing' لأكثر من 5 دقائق
  Future<int> recoverStuckSyncingItems({
    Duration stuckThreshold = const Duration(minutes: 5),
  }) {
    return _syncQueueDao.recoverStuckSyncingItems(
      stuckThreshold: stuckThreshold,
    );
  }

  /// تسجيل نتيجة عملية مزامنة
  Future<void> logSyncOperation({
    required String tableName,
    required String operation,
    required String recordId,
    required String result,
    int? durationMs,
    String? error,
  }) {
    return _syncQueueDao.logSyncOperation(
      tableName: tableName,
      operation: operation,
      recordId: recordId,
      result: result,
      durationMs: durationMs,
      error: error,
    );
  }

  /// تنظيف سجلات المزامنة القديمة (أقدم من 7 أيام)
  Future<int> cleanupSyncAuditLogs({
    Duration olderThan = const Duration(days: 7),
  }) {
    return _syncQueueDao.cleanupSyncAuditLogs(olderThan: olderThan);
  }

  /// الحصول على العناصر المتعارضة لجدول معين
  Future<List<SyncQueueTableData>> getConflictItemsForTable(String tableName) {
    return _syncQueueDao.getConflictItemsForTable(tableName);
  }

  /// الحصول على عدد التعارضات لكل جدول
  Future<Map<String, int>> getConflictCountsByTable() {
    return _syncQueueDao.getConflictCountsByTable();
  }

  /// حل تعارض مع تحديث البيانات المحلولة
  Future<void> resolveConflictWithData(String id, String resolvedPayload) {
    return _syncQueueDao.resolveConflictWithData(id, resolvedPayload);
  }

  /// تنظيف جميع التعارضات المحلولة
  Future<int> cleanupResolvedConflicts({
    Duration olderThan = const Duration(days: 3),
  }) {
    return _syncQueueDao.cleanupResolvedConflicts(olderThan: olderThan);
  }

  // ==================== Dead Letter Queue ====================

  /// الحصول على العناصر الميتة (فشلت نهائياً)
  Future<List<SyncQueueTableData>> getDeadLetterItems() {
    return _syncQueueDao.getDeadLetterItems();
  }

  /// عدد العناصر الميتة
  Future<int> getDeadLetterCount() {
    return _syncQueueDao.getDeadLetterCount();
  }

  /// مراقبة عدد العناصر الميتة
  Stream<int> watchDeadLetterCount() {
    return _syncQueueDao.watchDeadLetterCount();
  }

  /// إعادة محاولة جميع العناصر الميتة
  Future<int> retryDeadLetterItems() {
    return _syncQueueDao.retryDeadLetterItems();
  }

  int _priorityToInt(SyncPriority priority) {
    switch (priority) {
      case SyncPriority.low:
        return 1;
      case SyncPriority.normal:
        return 2;
      case SyncPriority.high:
        return 3;
    }
  }
}
