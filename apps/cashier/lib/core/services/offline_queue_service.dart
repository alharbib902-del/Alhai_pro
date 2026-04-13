// ---------------------------------------------------------------------------
// DUAL-QUEUE ARCHITECTURE -- APP-LEVEL QUEUE (Queue 1 of 2)
// ---------------------------------------------------------------------------
//
// The Alhai POS monorepo has TWO independent offline queuing systems.
// This file is Queue 1. Queue 2 lives in `packages/alhai_sync`.
//
// Queue 1 -- OfflineQueueService (THIS FILE)
//   Scope:      Cashier app only.
//   Storage:    FlutterSecureStorage (AES-encrypted on-device key-value store).
//   Operations: saleCreate, saleUpdate, refund, inventoryUpdate, customerSync.
//   Why it exists:
//     - Payloads contain sale amounts and customer PII that warrant encrypted
//       storage rather than plain SQLite.
//     - Provides cashier-specific retry semantics: 3 retries max, exponential
//       backoff (2s/4s/8s), batch size 5, 7-day stale cleanup.
//     - HTTP 409 (conflict) and validation errors (4xx) are not retried.
//   Entry point: OfflineQueueService.instance.enqueue(...)
//   Flush:       OfflineQueueService.instance.flush()
//
// Queue 2 -- sync_queue table + PushStrategy (packages/alhai_sync)
//   Scope:      ALL apps (cashier, admin, distributor) via the shared
//               alhai_database + alhai_sync packages.
//   Storage:    Drift/SQLite `sync_queue` table (unencrypted, indexed).
//   Operations: Standard CRUD sync for: sales, sale_items, orders,
//               order_items, cash_movements, audit_log, inventory_movements,
//               order_status_history, daily_summaries, whatsapp_messages.
//   Why it exists:
//     - General-purpose offline-first sync engine that handles all table-level
//       mutations, conflict resolution (version, duplicate key, delete-update,
//       schema mismatch), and priority ordering (sales = high priority).
//     - 5 retries max, exponential backoff with jitter, batch size 100.
//   Entry point: SyncQueueDao.enqueue(...)
//   Flush:       SyncEngine.syncNow() -> PushStrategy.pushPending()
//
// On reconnect, BOTH queues flush independently:
//   1. ConnectivityMonitor detects connectivity restored.
//   2. OfflineQueueService.flush()  -- drains the encrypted cashier queue.
//   3. SyncEngine.syncNow()         -- drains the sync_queue SQLite table.
//   Order does not matter; they do not depend on each other.
//
// Idempotency:
//   Both queues generate idempotency keys per operation. Even if the same
//   logical operation ends up in both queues (e.g. a sale), the server-side
//   idempotency check prevents duplicate processing.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Callback invoked on sync events. [message] is a human-readable description;
/// [isError] is true for failures, false for success.
typedef SyncCallback = void Function(String message, bool isError);

/// Error classification for queue items.
enum QueueErrorType {
  /// Transient -- no connectivity or socket timeout.
  network,

  /// Server rejected the payload (4xx except 409).
  validation,

  /// Server returned 409 -- conflicting state transition.
  conflict,
}

/// The type of POS operation queued for sync.
enum QueueOperationType {
  saleCreate,
  saleUpdate,
  refund,
  inventoryUpdate,
  customerSync,
}

/// A single item in the offline queue.
class QueueItem {
  final String id;
  final QueueOperationType type;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final DateTime queuedAt;

  /// 'pending' | 'syncing' | 'failed' | 'conflict'
  String itemStatus;

  int retryCount;
  DateTime? lastAttempt;
  String? lastError;

  QueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.idempotencyKey,
    required this.queuedAt,
    this.itemStatus = 'pending',
    this.retryCount = 0,
    this.lastAttempt,
    this.lastError,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'payload': payload,
    'idempotency_key': idempotencyKey,
    'queued_at': queuedAt.toIso8601String(),
    'item_status': itemStatus,
    'retry_count': retryCount,
    'last_attempt': lastAttempt?.toIso8601String(),
    'last_error': lastError,
  };

  factory QueueItem.fromJson(Map<String, dynamic> json) => QueueItem(
    id: json['id'] as String,
    type: QueueOperationType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => QueueOperationType.saleCreate,
    ),
    payload: Map<String, dynamic>.from(json['payload'] as Map),
    idempotencyKey: json['idempotency_key'] as String,
    queuedAt: DateTime.parse(json['queued_at'] as String),
    itemStatus: (json['item_status'] as String?) ?? 'pending',
    retryCount: (json['retry_count'] as int?) ?? 0,
    lastAttempt: json['last_attempt'] != null
        ? DateTime.tryParse(json['last_attempt'] as String)
        : null,
    lastError: json['last_error'] as String?,
  );
}

/// Callback that processes a single queue item against the server.
///
/// Returns `true` on success, throws on failure.
typedef QueueItemProcessor = Future<bool> Function(QueueItem item);

/// Queues POS operations when offline and replays them when connectivity
/// is restored.
///
/// Storage: FlutterSecureStorage (encrypted on-device key-value store).
/// Guarantees:
///   - Idempotency -- duplicate operations with the same key are deduplicated.
///   - At-most-3-retries with exponential backoff per item.
///   - Batch processing (5 items at a time) to avoid overwhelming the server.
///   - Automatic cleanup of items older than 7 days.
///   - HTTP 409 responses are classified as conflicts and not retried.
///   - In-memory cache so secure storage is only hit once per session for
///     reads; writes are persisted immediately for crash-safety.
class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  static const _queueKey = 'offline_pos_queue';
  static const _maxRetries = 3;
  static const _batchSize = 5;
  static const _staleThresholdDays = 7;

  static const _uuid = Uuid();

  // Secure storage instance -- sale amounts and customer data warrant
  // encrypted storage.
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Optional callback notified on every sync event.
  SyncCallback? onSyncEvent;

  /// Optional processor that handles syncing a single item to the server.
  /// Must be set before calling [flush].
  QueueItemProcessor? itemProcessor;

  // -- In-memory cache -------------------------------------------------------

  /// Null until first load from FlutterSecureStorage.
  List<QueueItem>? _cache;

  /// Whether a flush is currently in progress. Prevents concurrent flushes.
  bool _flushing = false;

  // -- Internal helpers ------------------------------------------------------

  /// Returns the in-memory list, loading from encrypted storage the first time.
  Future<List<QueueItem>> _load() async {
    if (_cache != null) return _cache!;

    final raw = await _secureStorage.read(key: _queueKey);
    if (raw == null || raw.isEmpty) {
      _cache = [];
      return _cache!;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _cache = decoded
          .map((e) {
            try {
              return QueueItem.fromJson(e as Map<String, dynamic>);
            } catch (e) {
              if (kDebugMode) {
                debugPrint(
                  '[OfflineQueueService] item deserialization failed: $e',
                );
              }
              return null;
            }
          })
          .whereType<QueueItem>()
          .toList();
    } catch (e) {
      if (kDebugMode) debugPrint('[OfflineQueueService] queue load failed: $e');
      _cache = [];
    }

    return _cache!;
  }

  /// Persists the current in-memory list to encrypted storage.
  Future<void> _save(List<QueueItem> items) async {
    _cache = items;
    final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
    await _secureStorage.write(key: _queueKey, value: encoded);
  }

  /// Clears the in-memory cache.
  void _clearCache() => _cache = null;

  /// Exponential backoff: 2^(retryCount+1) seconds -> 2s, 4s, 8s.
  Duration _backoffFor(int retryCount) {
    return Duration(seconds: 1 << (retryCount + 1));
  }

  /// Classify an error to determine retry strategy.
  QueueErrorType _classifyError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('409') || msg.contains('conflict')) {
      return QueueErrorType.conflict;
    }
    if (msg.contains('400') ||
        msg.contains('422') ||
        msg.contains('validation') ||
        msg.contains('invalid')) {
      return QueueErrorType.validation;
    }
    return QueueErrorType.network;
  }

  void _notify(String message, {bool isError = false}) {
    onSyncEvent?.call(message, isError);
    if (kDebugMode) debugPrint('OfflineQueue: $message');
  }

  /// Generate an idempotency key for a POS operation.
  ///
  /// For sales: uses the local sale ID to prevent duplicate submissions.
  /// For other operations: combines the type and a unique identifier from
  /// the payload.
  String _generateIdempotencyKey(
    QueueOperationType type,
    Map<String, dynamic> payload,
  ) {
    switch (type) {
      case QueueOperationType.saleCreate:
        // Use local sale ID to prevent duplicate sale submissions
        final saleId = payload['local_sale_id'] ?? payload['id'] ?? _uuid.v4();
        return 'sale_create_$saleId';
      case QueueOperationType.saleUpdate:
        final saleId = payload['sale_id'] ?? payload['id'] ?? '';
        final field = payload['field'] ?? 'update';
        return 'sale_update_${saleId}_$field';
      case QueueOperationType.refund:
        final saleId = payload['original_sale_id'] ?? '';
        return 'refund_$saleId';
      case QueueOperationType.inventoryUpdate:
        final productId = payload['product_id'] ?? '';
        final ts = payload['timestamp'] ?? DateTime.now().toIso8601String();
        return 'inv_${productId}_$ts';
      case QueueOperationType.customerSync:
        final customerId = payload['customer_id'] ?? '';
        return 'cust_sync_$customerId';
    }
  }

  // -- Public API ------------------------------------------------------------

  /// Add a POS operation to the offline queue.
  ///
  /// Returns `true` if a new item was added, `false` if an existing pending/
  /// failed entry was updated in place (deduplication), or `null` if a
  /// currently-syncing entry was skipped.
  Future<bool?> enqueue({
    required QueueOperationType type,
    required Map<String, dynamic> payload,
    String? customIdempotencyKey,
  }) async {
    final items = await _load();
    final key = customIdempotencyKey ?? _generateIdempotencyKey(type, payload);

    // Deduplication check
    final existing = items.cast<QueueItem?>().firstWhere(
      (i) => i!.idempotencyKey == key,
      orElse: () => null,
    );

    if (existing != null) {
      if (existing.itemStatus == 'syncing') {
        _notify('تم تخطي عنصر مكرر (قيد المزامنة): $key');
        return null; // already in flight
      }
      // Update existing pending/failed entry in place
      existing.itemStatus = 'pending';
      existing.retryCount = 0;
      existing.lastAttempt = null;
      existing.lastError = null;
      await _save(items);
      _notify('تم تحديث عنصر موجود: $key');
      return false;
    }

    items.add(
      QueueItem(
        id: _uuid.v4(),
        type: type,
        payload: payload,
        idempotencyKey: key,
        queuedAt: DateTime.now(),
      ),
    );
    await _save(items);
    _notify('تمت إضافة ${type.name} إلى قائمة الانتظار');
    return true;
  }

  /// Replay all pending items. Call when connectivity is restored.
  ///
  /// Items are processed in FIFO order in batches of [_batchSize].
  /// Network failures increment the retry counter (up to [_maxRetries]).
  /// Validation/conflict errors stop retrying immediately.
  ///
  /// Returns the number of items successfully processed.
  Future<int> flush() async {
    if (_flushing) {
      _notify('المزامنة قيد التنفيذ بالفعل');
      return 0;
    }

    if (itemProcessor == null) {
      _notify('لم يتم تعيين معالج العناصر', isError: true);
      return 0;
    }

    _flushing = true;
    try {
      final items = await _load();
      if (items.isEmpty) return 0;
      return await _processItems(items);
    } finally {
      _flushing = false;
    }
  }

  Future<int> _processItems(List<QueueItem> items) async {
    // Only process items that are eligible
    final eligible = items
        .where(
          (i) =>
              (i.itemStatus == 'pending' || i.itemStatus == 'failed') &&
              i.retryCount < _maxRetries,
        )
        .toList();

    if (eligible.isEmpty) {
      _notify('لا توجد عناصر مؤهلة للمزامنة');
      return 0;
    }

    int processed = 0;

    // Process in batches to avoid overwhelming the server
    for (
      int batchStart = 0;
      batchStart < eligible.length;
      batchStart += _batchSize
    ) {
      final batch = eligible.skip(batchStart).take(_batchSize).toList();

      for (final item in batch) {
        // Enforce backoff: skip if last attempt was too recent
        if (item.lastAttempt != null) {
          final waitUntil = item.lastAttempt!.add(_backoffFor(item.retryCount));
          if (DateTime.now().isBefore(waitUntil)) {
            if (kDebugMode) {
              debugPrint(
                'OfflineQueue: Backoff active for ${item.id} '
                '(retry ${item.retryCount})',
              );
            }
            continue;
          }
        }

        item.itemStatus = 'syncing';
        item.lastAttempt = DateTime.now();
        await _save(items);

        try {
          final success = await itemProcessor!(item);

          if (success) {
            items.remove(item);
            processed++;
            _notify('تمت مزامنة ${item.type.name} بنجاح (${item.id})');
          } else {
            // Server rejected -- discard, retrying won't help
            items.remove(item);
            processed++;
            _notify('رفض الخادم العملية ${item.id}', isError: true);
          }
        } catch (e) {
          final errorType = _classifyError(e);
          item.lastError = e.toString();

          switch (errorType) {
            case QueueErrorType.conflict:
              item.itemStatus = 'conflict';
              _notify('تعارض في العملية ${item.id}: $e', isError: true);
              break;
            case QueueErrorType.validation:
              items.remove(item); // discard unretriable validation errors
              _notify('خطأ في التحقق للعملية ${item.id}: $e', isError: true);
              break;
            case QueueErrorType.network:
              item.retryCount++;
              item.itemStatus = item.retryCount >= _maxRetries
                  ? 'failed'
                  : 'pending';
              _notify(
                'خطأ في الشبكة للعملية ${item.id} '
                '(محاولة ${item.retryCount}/$_maxRetries): $e',
                isError: true,
              );
              break;
          }
          await _save(items);
        }
      }
    }

    await _save(items);

    final remaining = items.length;
    _notify('اكتملت المزامنة: $processed تمت مزامنتها، $remaining متبقية');
    return processed;
  }

  /// Returns counts per status for health monitoring.
  ///
  /// Keys: 'pending', 'syncing', 'failed', 'conflict', 'total'
  Future<Map<String, int>> getQueueHealth() async {
    final items = await _load();
    final counts = <String, int>{
      'pending': 0,
      'syncing': 0,
      'failed': 0,
      'conflict': 0,
      'total': items.length,
    };
    for (final item in items) {
      counts.update(item.itemStatus, (v) => v + 1, ifAbsent: () => 1);
    }
    return counts;
  }

  /// Remove items older than [_staleThresholdDays] days.
  /// Returns the number of items removed.
  Future<int> cleanupStale() async {
    final items = await _load();
    final cutoff = DateTime.now().subtract(
      const Duration(days: _staleThresholdDays),
    );
    final before = items.length;
    items.removeWhere((i) => i.queuedAt.isBefore(cutoff));
    final removed = before - items.length;
    if (removed > 0) {
      await _save(items);
      _notify('تم حذف $removed عنصر قديم من قائمة الانتظار');
    }
    return removed;
  }

  /// Get number of pending items.
  Future<int> pendingCount() async {
    final items = await _load();
    return items
        .where((i) => i.itemStatus == 'pending' || i.itemStatus == 'failed')
        .length;
  }

  /// Get total number of items in queue regardless of status.
  Future<int> totalCount() async {
    final items = await _load();
    return items.length;
  }

  /// Get all items in the queue (read-only snapshot).
  Future<List<QueueItem>> getItems() async {
    final items = await _load();
    return List.unmodifiable(items);
  }

  /// Clear the entire queue.
  Future<void> clear() async {
    _clearCache();
    await _secureStorage.delete(key: _queueKey);
    _notify('تم مسح قائمة الانتظار');
  }
}
