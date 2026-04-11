import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_queue_service.freezed.dart';
part 'sync_queue_service.g.dart';

/// Sync operation type enum (v2.5.0)
enum SyncOperationType {
  @JsonValue('CREATE')
  create,
  @JsonValue('UPDATE')
  update,
  @JsonValue('DELETE')
  delete,
}

/// Sync status enum
enum SyncStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('SYNCING')
  syncing,
  @JsonValue('SYNCED')
  synced,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CONFLICT')
  conflict,
}

/// Extension for SyncStatus
extension SyncStatusExt on SyncStatus {
  String get displayNameAr {
    switch (this) {
      case SyncStatus.pending:
        return 'معلق';
      case SyncStatus.syncing:
        return 'جاري المزامنة';
      case SyncStatus.synced:
        return 'متزامن';
      case SyncStatus.failed:
        return 'فشل';
      case SyncStatus.conflict:
        return 'تعارض';
    }
  }

  bool get needsAttention =>
      this == SyncStatus.failed || this == SyncStatus.conflict;
}

/// Entity type for sync queue
enum SyncEntityType {
  @JsonValue('SALE')
  sale,
  @JsonValue('ORDER')
  order,
  @JsonValue('INVENTORY')
  inventory,
  @JsonValue('CUSTOMER')
  customer,
  @JsonValue('PRODUCT')
  product,
  @JsonValue('SHIFT')
  shift,
  @JsonValue('CASH_MOVEMENT')
  cashMovement,
  @JsonValue('REFUND')
  refund,
}

/// Sync queue item model (v2.5.0)
/// Referenced by: US-4.1, US-4.2
@freezed
class SyncQueueItem with _$SyncQueueItem {
  const SyncQueueItem._();

  const factory SyncQueueItem({
    required String id,
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operation,
    required SyncStatus status,
    required String payload,
    @Default(0) int attempts,
    @Default(3) int maxAttempts,
    String? lastError,
    required DateTime createdAt,
    DateTime? syncedAt,
    DateTime? nextRetryAt,
  }) = _SyncQueueItem;

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) =>
      _$SyncQueueItemFromJson(json);

  /// Check if can retry
  bool get canRetry => attempts < maxAttempts && status == SyncStatus.failed;

  /// Check if is pending or failed
  bool get needsSync =>
      status == SyncStatus.pending || status == SyncStatus.failed;

  /// Time since created
  Duration get age => DateTime.now().difference(createdAt);
}

/// Sync conflict model
@freezed
class SyncConflict with _$SyncConflict {
  const factory SyncConflict({
    required String id,
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> localValue,
    required Map<String, dynamic> serverValue,
    required DateTime detectedAt,
    @Default(false) bool isResolved,
    String? resolution,
    DateTime? resolvedAt,
  }) = _SyncConflict;

  factory SyncConflict.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictFromJson(json);
}

/// Conflict resolution type
enum ConflictResolution { acceptLocal, acceptServer, merge, createAdjustment }

/// Sync queue service interface (v2.5.0)
/// Referenced by: US-4.1, US-4.2, US-4.3, US-4.4, US-4.5
abstract class SyncQueueService {
  /// Adds an item to the sync queue
  Future<SyncQueueItem> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> payload,
  });

  /// Gets all pending items in the queue
  Future<List<SyncQueueItem>> getPendingItems();

  /// Gets queue summary (counts by status)
  Future<SyncQueueSummary> getSummary();

  /// Processes the sync queue
  /// Returns number of successfully synced items
  Future<int> processQueue();

  /// Retries a failed item
  Future<SyncQueueItem> retryItem(String itemId);

  /// Marks an item as synced
  Future<void> markSynced(String itemId);

  /// Marks an item as failed with error
  Future<void> markFailed(String itemId, String error);

  /// Gets all conflicts
  Future<List<SyncConflict>> getConflicts();

  /// Resolves a conflict
  Future<void> resolveConflict(
    String conflictId,
    ConflictResolution resolution, {
    String? notes,
  });

  /// Clears all synced items from queue
  Future<int> clearSyncedItems();

  /// Checks if there are pending items
  Future<bool> hasPendingItems();

  /// Gets connection status
  Future<bool> isOnline();

  /// Starts background sync
  Future<void> startBackgroundSync();

  /// Stops background sync
  Future<void> stopBackgroundSync();
}

/// Sync queue summary
class SyncQueueSummary {
  final int pendingCount;
  final int syncingCount;
  final int syncedCount;
  final int failedCount;
  final int conflictCount;
  final DateTime? lastSyncAt;

  const SyncQueueSummary({
    required this.pendingCount,
    required this.syncingCount,
    required this.syncedCount,
    required this.failedCount,
    required this.conflictCount,
    this.lastSyncAt,
  });

  int get totalPending => pendingCount + syncingCount;
  int get totalIssues => failedCount + conflictCount;
  bool get hasIssues => totalIssues > 0;
  bool get isAllSynced => pendingCount == 0 && failedCount == 0;
}
