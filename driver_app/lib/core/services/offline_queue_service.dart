import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/deliveries/data/delivery_datasource.dart';

/// Callback invoked on sync events. [message] is a human-readable description;
/// [isError] is true for failures, false for success.
typedef SyncCallback = void Function(String message, bool isError);

/// Error classification for queue items.
enum QueueErrorType {
  /// Transient – no connectivity or socket timeout.
  network,

  /// Server rejected the payload (4xx except 409).
  validation,

  /// Server returned 409 – conflicting state transition.
  conflict,
}

/// A single item in the offline queue.
class _QueueItem {
  final String deliveryId;
  final String status;
  final String? notes;
  final DateTime queuedAt;

  /// 'pending' | 'syncing' | 'failed' | 'conflict'
  String itemStatus;

  int retryCount;
  DateTime? lastAttempt;
  String? lastError;

  _QueueItem({
    required this.deliveryId,
    required this.status,
    required this.queuedAt,
    this.notes,
    this.itemStatus = 'pending',
    this.retryCount = 0,
    this.lastAttempt,
    this.lastError,
  });

  /// Idempotency key – same delivery + same target status = same operation.
  String get idempotencyKey => '${deliveryId}_$status';

  Map<String, dynamic> toJson() => {
        'delivery_id': deliveryId,
        'status': status,
        'notes': notes,
        'queued_at': queuedAt.toIso8601String(),
        'item_status': itemStatus,
        'retry_count': retryCount,
        'last_attempt': lastAttempt?.toIso8601String(),
        'last_error': lastError,
      };

  factory _QueueItem.fromJson(Map<String, dynamic> json) => _QueueItem(
        deliveryId: json['delivery_id'] as String,
        status: json['status'] as String,
        notes: json['notes'] as String?,
        queuedAt: DateTime.parse(json['queued_at'] as String),
        itemStatus: (json['item_status'] as String?) ?? 'pending',
        retryCount: (json['retry_count'] as int?) ?? 0,
        lastAttempt: json['last_attempt'] != null
            ? DateTime.tryParse(json['last_attempt'] as String)
            : null,
        lastError: json['last_error'] as String?,
      );
}

/// Queues delivery status updates when offline and replays them when
/// connectivity is restored.
///
/// Storage: FlutterSecureStorage (encrypted on-device key-value store).
/// Guarantees:
///   - Idempotency – duplicate (deliveryId + status) pairs are deduplicated.
///   - At-most-3-retries with exponential backoff per item.
///   - Automatic cleanup of items older than 7 days.
///   - HTTP 409 responses are classified as conflicts and not retried.
///   - In-memory cache so SharedPreferences is only hit once per session for
///     reads; writes are still persisted immediately for crash-safety.
class OfflineQueueService {
  OfflineQueueService._();

  static final OfflineQueueService instance = OfflineQueueService._();

  static const _queueKey = 'offline_delivery_queue';
  static const _maxRetries = 3;
  static const _staleThresholdDays = 7;

  // Secure storage instance – delivery IDs and statuses are sensitive
  // enough to warrant encrypted storage (no GPS, no PII).
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Optional callback notified on every sync event.
  SyncCallback? onSyncEvent;

  // ─── In-memory cache ─────────────────────────────────────────────────────

  /// Null until first load from FlutterSecureStorage.
  List<_QueueItem>? _cache;

  // ─── Internal helpers ────────────────────────────────────────────────────

  /// Returns the in-memory list, loading from encrypted storage the first time.
  Future<List<_QueueItem>> _load() async {
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
              return _QueueItem.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<_QueueItem>()
          .toList();
    } catch (_) {
      _cache = [];
    }

    return _cache!;
  }

  /// Persists the current in-memory list to encrypted storage.
  Future<void> _save(List<_QueueItem> items) async {
    _cache = items;
    final encoded = jsonEncode(items.map((i) => i.toJson()).toList());
    await _secureStorage.write(key: _queueKey, value: encoded);
  }

  /// Clears the in-memory cache (call when the queue is wiped).
  void _clearCache() => _cache = null;

  Duration _backoffFor(int retryCount) {
    // 2^retryCount seconds: 2s, 4s, 8s
    return Duration(seconds: 1 << (retryCount + 1));
  }

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

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Add a status update to the offline queue.
  ///
  /// Returns `true` if a new item was added, `false` if an existing pending/
  /// failed entry was updated in place (deduplication), or `null` if a
  /// currently-syncing entry was skipped.
  Future<bool?> enqueue({
    required String deliveryId,
    required String status,
    String? notes,
  }) async {
    final items = await _load();
    final key = '${deliveryId}_$status';

    final existing = items.cast<_QueueItem?>().firstWhere(
          (i) => i!.idempotencyKey == key,
          orElse: () => null,
        );

    if (existing != null) {
      if (existing.itemStatus == 'syncing') {
        _notify('Skipped duplicate (syncing): $key');
        return null; // already in flight
      }
      // Update existing pending/failed entry in place
      existing.itemStatus = 'pending';
      existing.retryCount = 0;
      existing.lastAttempt = null;
      existing.lastError = null;
      await _save(items);
      _notify('Updated existing queue entry: $key');
      return false;
    }

    items.add(_QueueItem(
      deliveryId: deliveryId,
      status: status,
      notes: notes,
      queuedAt: DateTime.now(),
    ));
    await _save(items);
    _notify('Queued $status for delivery $deliveryId');
    return true;
  }

  /// Replay all pending items. Call when connectivity is restored.
  ///
  /// Items are processed in FIFO order. Network failures increment the retry
  /// counter (up to [_maxRetries]). Validation/conflict errors stop retrying
  /// immediately.
  ///
  /// Returns the number of items successfully processed.
  Future<int> flush() async {
    final items = await _load();
    if (items.isEmpty) return 0;

    final ds = GetIt.instance<DeliveryDatasource>();
    return _processItems(items, ds);
  }

  /// Flush with an explicit datasource reference (used internally and in tests).
  Future<int> flushQueue(DeliveryDatasource datasource) async {
    final items = await _load();
    if (items.isEmpty) return 0;
    return _processItems(items, datasource);
  }

  Future<int> _processItems(
    List<_QueueItem> items,
    DeliveryDatasource ds,
  ) async {
    // Only process items that are eligible
    final eligible = items
        .where((i) =>
            (i.itemStatus == 'pending' || i.itemStatus == 'failed') &&
            i.retryCount < _maxRetries)
        .toList();

    if (eligible.isEmpty) {
      _notify('No eligible items to flush');
      return 0;
    }

    int processed = 0;

    // Process in batches of 5 to avoid overwhelming the server
    const batchSize = 5;
    for (int batchStart = 0;
        batchStart < eligible.length;
        batchStart += batchSize) {
      final batch = eligible.skip(batchStart).take(batchSize).toList();

      for (final item in batch) {
        // Enforce backoff: skip if last attempt was too recent
        if (item.lastAttempt != null) {
          final waitUntil = item.lastAttempt!.add(_backoffFor(item.retryCount));
          if (DateTime.now().isBefore(waitUntil)) {
            _notify(
                'Backoff active for ${item.deliveryId} (retry ${item.retryCount})');
            continue;
          }
        }

        item.itemStatus = 'syncing';
        item.lastAttempt = DateTime.now();
        await _save(items);

        try {
          final result = await ds.updateStatus(
            item.deliveryId,
            item.status,
            notes: item.notes,
          );

          if (result['success'] == true) {
            items.remove(item);
            processed++;
            _notify('Synced ${item.status} for delivery ${item.deliveryId}');
          } else {
            // Server rejected (validation / invalid transition)
            items.remove(item); // discard – retrying won't help
            processed++;
            _notify(
              'Server rejected ${item.deliveryId}: ${result['error']}',
              isError: true,
            );
          }
        } catch (e) {
          final errorType = _classifyError(e);
          item.lastError = e.toString();

          switch (errorType) {
            case QueueErrorType.conflict:
              item.itemStatus = 'conflict';
              _notify(
                'Conflict on ${item.deliveryId} (${item.status}): $e',
                isError: true,
              );
              break;
            case QueueErrorType.validation:
              items.remove(item); // discard unretriable validation errors
              _notify(
                'Validation error for ${item.deliveryId}: $e',
                isError: true,
              );
              break;
            case QueueErrorType.network:
              item.retryCount++;
              item.itemStatus =
                  item.retryCount >= _maxRetries ? 'failed' : 'pending';
              _notify(
                'Network error for ${item.deliveryId} '
                '(attempt ${item.retryCount}/$_maxRetries): $e',
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
    _notify('Flush complete: $processed synced, $remaining remaining');
    return processed;
  }

  /// Returns counts per status for monitoring.
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
    final cutoff =
        DateTime.now().subtract(const Duration(days: _staleThresholdDays));
    final before = items.length;
    items.removeWhere((i) => i.queuedAt.isBefore(cutoff));
    final removed = before - items.length;
    if (removed > 0) {
      await _save(items);
      _notify('Cleaned up $removed stale queue items');
    }
    return removed;
  }

  /// Get number of pending items (backward-compatible).
  Future<int> pendingCount() async {
    final items = await _load();
    return items.where((i) => i.itemStatus == 'pending').length;
  }

  /// Get total number of items in queue regardless of status.
  Future<int> totalCount() async {
    final items = await _load();
    return items.length;
  }

  /// Clear the entire queue.
  Future<void> clear() async {
    _clearCache();
    await _secureStorage.delete(key: _queueKey);
    _notify('Queue cleared');
  }
}
