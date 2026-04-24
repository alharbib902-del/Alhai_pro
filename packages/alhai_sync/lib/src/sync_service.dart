import 'dart:convert';
import 'dart:developer' as developer;

import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';

import 'validators/pre_sync_validator.dart';

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
  'invoices',       // ZATCA Phase-1 compliance — must always queue
  'return_items',   // audit trail — must always queue
  'returns',
  'stock_deltas',   // multi-device inventory — critical
  'transactions',   // account ledger — critical
};

/// Phase 2, task 2.8 — Hard queue limit.
///
/// The existing [SyncQueueHealth] demoted low-priority items at 10,000 active
/// items but never rejected them. After extended offline windows (30+ min on
/// a bad network) the queue was observed growing past 50k on dev devices, at
/// which point the sync cycle itself starts eating all SQLite time.
///
/// Now: when `activeCount` reaches this ceiling, **even demoted-to-low items
/// are rejected outright** (non-critical tables only — the high-priority set
/// above always passes so sales/invoices are never dropped). The rejection
/// returns synthetic id `queue_full_<ts>` so callers see a non-crash path.
///
/// Tuning: chose 50k as a soft failure line — enough headroom that a normal
/// day of offline work (≤10k operations) never trips it, but small enough
/// that we catch runaway pathological cases before SQLite degrades.
const int _hardQueueLimit = 50000;

/// خدمة طابور المزامنة
/// تضيف العمليات للطابور المحلي ليتم مزامنتها لاحقاً
class SyncService {
  final SyncQueueDao _syncQueueDao;
  final PreSyncValidator? _validator;
  final _uuid = const Uuid();

  /// آخر صحة طابور مؤقتة (لتجنب استعلام كل مرة)
  SyncQueueHealth? _cachedHealth;
  DateTime? _healthCacheTime;

  /// Constructs a SyncService.
  ///
  /// [validator] is optional — when provided, every [enqueue] call passes the
  /// payload through it before insertion. Payloads that fail validation are
  /// logged + dropped (not queued). When null, legacy behaviour (no validation)
  /// is preserved so existing callers continue to work.
  SyncService(
    this._syncQueueDao, {
    PreSyncValidator? validator,
  }) : _validator = validator;

  /// إضافة عملية للطابور مع حماية من التكرار ودمج العمليات
  Future<String> enqueue({
    required String tableName,
    required String recordId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    SyncPriority priority = SyncPriority.normal,
  }) async {
    // === حماية حجم الطابور (Phase 2, task 2.8) ===
    // ثلاث عتبات:
    //   1. isOverloaded (>10k): تأجيل العناصر منخفضة الأولوية
    //   2. _hardQueueLimit (>50k): رفض كامل للعناصر غير الحرجة
    //   3. جداول _highPriorityTables: تمر دائماً (sales/invoices/stock…)
    if (!_highPriorityTables.contains(tableName) &&
        priority != SyncPriority.high) {
      final health = await _getCachedHealth();

      // ── Hard reject at 50k: حتى مع demoted-to-low ──
      if (health.activeCount >= _hardQueueLimit) {
        developer.log(
          'SyncService: HARD LIMIT hit (${health.activeCount} active ≥ '
          '$_hardQueueLimit) — dropping non-critical item '
          '$tableName/$recordId. High-priority tables still accepted.',
          name: 'SyncService',
          level: 1000, // SEVERE
        );
        // Return synthetic id so callers that await the string don't crash.
        // The caller's normal flow completes locally (DB write succeeded),
        // only the sync fanout is skipped. When the queue drains below the
        // limit, future operations on this record will sync normally.
        return 'queue_full_${DateTime.now().millisecondsSinceEpoch}';
      }

      // ── Soft demote at 10k: keep queuing but at low priority ──
      if (health.isOverloaded) {
        developer.log(
          'SyncService: queue overloaded (${health.activeCount} items), '
          'deferring low-priority item ($tableName/$recordId)',
          name: 'SyncService',
        );
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

    // === Pre-sync business-rule validation (Phase 2) ===
    // Only runs when a validator was injected. Legacy callers without one
    // skip this step entirely. Failures are dropped (not queued) so corrupt
    // rows never reach Supabase; see dead-letter log below.
    if (_validator != null) {
      final result = await _validator.validate(SyncPayload(
        table: tableName,
        operation: operation.name,
        data: payload,
      ));
      if (result.hasErrors) {
        developer.log(
          'SyncService: pre-sync validation failed for '
          '$tableName/$recordId — ${result.errors.length} rule(s) violated. '
          'Payload dropped from queue.',
          name: 'SyncService',
          error: jsonEncode(
            result.errors.map((e) => e.toJson()).toList(),
          ),
        );
        // Return a synthetic id so callers aren't broken; payload is NOT queued.
        return 'validation_failed';
      }
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
