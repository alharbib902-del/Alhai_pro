import 'dart:convert';
import 'package:alhai_core/alhai_core.dart';
import 'package:uuid/uuid.dart';

/// Implementation of SyncQueueService for offline data synchronization
/// Manages a queue of pending operations to sync when online
/// Referenced by: US-4.1, US-4.2, US-4.3, US-4.4, US-4.5
class SyncQueueServiceImpl implements SyncQueueService {
  // In-memory queue (in production, use local database like SQLite/Hive)
  final List<SyncQueueItem> _queue = [];
  final List<SyncConflict> _conflicts = [];

  // Sync state
  bool _isProcessing = false;
  DateTime? _lastSyncAt;
  bool _backgroundSyncEnabled = false;

  // UUID generator
  final _uuid = const Uuid();

  // Connectivity callback (set by app)
  Future<bool> Function()? _connectivityCheck;

  // Sync handler callback (set by app for actual API calls)
  Future<bool> Function(SyncQueueItem item)? _syncHandler;

  /// Set connectivity check function
  void setConnectivityCheck(Future<bool> Function() check) {
    _connectivityCheck = check;
  }

  /// Set sync handler for processing items
  void setSyncHandler(Future<bool> Function(SyncQueueItem) handler) {
    _syncHandler = handler;
  }

  @override
  Future<SyncQueueItem> enqueue({
    required SyncEntityType entityType,
    required String entityId,
    required SyncOperationType operation,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItem(
      id: _uuid.v4(),
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      status: SyncStatus.pending,
      payload: jsonEncode(payload),
      createdAt: DateTime.now(),
    );

    _queue.add(item);

    // Try to sync immediately if online and background sync is enabled
    if (_backgroundSyncEnabled && await isOnline()) {
      processQueue();
    }

    return item;
  }

  @override
  Future<List<SyncQueueItem>> getPendingItems() async {
    return _queue.where((item) => item.needsSync).toList();
  }

  @override
  Future<SyncQueueSummary> getSummary() async {
    return SyncQueueSummary(
      pendingCount: _queue.where((i) => i.status == SyncStatus.pending).length,
      syncingCount: _queue.where((i) => i.status == SyncStatus.syncing).length,
      syncedCount: _queue.where((i) => i.status == SyncStatus.synced).length,
      failedCount: _queue.where((i) => i.status == SyncStatus.failed).length,
      conflictCount: _conflicts.where((c) => !c.isResolved).length,
      lastSyncAt: _lastSyncAt,
    );
  }

  @override
  Future<int> processQueue() async {
    if (_isProcessing) return 0;
    if (!await isOnline()) return 0;

    _isProcessing = true;
    int syncedCount = 0;

    try {
      final pendingItems = await getPendingItems();

      // Sort by creation time (oldest first)
      pendingItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final item in pendingItems) {
        try {
          // Mark as syncing
          _updateItemStatus(item.id, SyncStatus.syncing);

          // Process the item
          final success = await _processItem(item);

          if (success) {
            await markSynced(item.id);
            syncedCount++;
          } else {
            await markFailed(item.id, 'Sync failed');
          }
        } catch (e) {
          await markFailed(item.id, e.toString());
        }
      }

      _lastSyncAt = DateTime.now();
    } finally {
      _isProcessing = false;
    }

    return syncedCount;
  }

  @override
  Future<SyncQueueItem> retryItem(String itemId) async {
    final index = _queue.indexWhere((i) => i.id == itemId);
    if (index == -1) {
      throw Exception('Item not found in queue');
    }

    final item = _queue[index];
    if (!item.canRetry) {
      throw Exception('Item cannot be retried');
    }

    // Reset status to pending
    final updatedItem = SyncQueueItem(
      id: item.id,
      entityType: item.entityType,
      entityId: item.entityId,
      operation: item.operation,
      status: SyncStatus.pending,
      payload: item.payload,
      attempts: item.attempts,
      maxAttempts: item.maxAttempts,
      createdAt: item.createdAt,
      nextRetryAt: DateTime.now(),
    );

    _queue[index] = updatedItem;
    return updatedItem;
  }

  @override
  Future<void> markSynced(String itemId) async {
    _updateItemStatus(itemId, SyncStatus.synced, syncedAt: DateTime.now());
  }

  @override
  Future<void> markFailed(String itemId, String error) async {
    final index = _queue.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final item = _queue[index];
    final newAttempts = item.attempts + 1;

    // Calculate next retry time with exponential backoff
    final backoffMinutes = (1 << (newAttempts - 1)).clamp(1, 60);
    final nextRetry = DateTime.now().add(Duration(minutes: backoffMinutes));

    _queue[index] = SyncQueueItem(
      id: item.id,
      entityType: item.entityType,
      entityId: item.entityId,
      operation: item.operation,
      status: SyncStatus.failed,
      payload: item.payload,
      attempts: newAttempts,
      maxAttempts: item.maxAttempts,
      lastError: error,
      createdAt: item.createdAt,
      nextRetryAt: nextRetry,
    );
  }

  @override
  Future<List<SyncConflict>> getConflicts() async {
    return _conflicts.where((c) => !c.isResolved).toList();
  }

  @override
  Future<void> resolveConflict(
    String conflictId,
    ConflictResolution resolution, {
    String? notes,
  }) async {
    final index = _conflicts.indexWhere((c) => c.id == conflictId);
    if (index == -1) {
      throw Exception('Conflict not found');
    }

    final conflict = _conflicts[index];

    // Apply resolution
    switch (resolution) {
      case ConflictResolution.acceptLocal:
        // Re-queue the local value
        await enqueue(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          operation: SyncOperationType.update,
          payload: conflict.localValue,
        );
        break;

      case ConflictResolution.acceptServer:
        // Server value is already applied, nothing to do
        break;

      case ConflictResolution.merge:
        // Merge both values (app-specific logic)
        final merged = {...conflict.serverValue, ...conflict.localValue};
        await enqueue(
          entityType: conflict.entityType,
          entityId: conflict.entityId,
          operation: SyncOperationType.update,
          payload: merged,
        );
        break;

      case ConflictResolution.createAdjustment:
        // Create an adjustment record (for inventory conflicts)
        // This is app-specific
        break;
    }

    // Mark as resolved
    _conflicts[index] = SyncConflict(
      id: conflict.id,
      entityType: conflict.entityType,
      entityId: conflict.entityId,
      localValue: conflict.localValue,
      serverValue: conflict.serverValue,
      detectedAt: conflict.detectedAt,
      isResolved: true,
      resolution: resolution.name,
      resolvedAt: DateTime.now(),
    );
  }

  @override
  Future<int> clearSyncedItems() async {
    final syncedItems = _queue
        .where((i) => i.status == SyncStatus.synced)
        .toList();
    final count = syncedItems.length;

    _queue.removeWhere((i) => i.status == SyncStatus.synced);

    return count;
  }

  @override
  Future<bool> hasPendingItems() async {
    return _queue.any((i) => i.needsSync);
  }

  @override
  Future<bool> isOnline() async {
    if (_connectivityCheck != null) {
      return await _connectivityCheck!();
    }
    // Default: assume online
    return true;
  }

  @override
  Future<void> startBackgroundSync() async {
    _backgroundSyncEnabled = true;

    // Process any pending items immediately
    if (await isOnline()) {
      await processQueue();
    }
  }

  @override
  Future<void> stopBackgroundSync() async {
    _backgroundSyncEnabled = false;
  }

  // Helper methods

  void _updateItemStatus(
    String itemId,
    SyncStatus status, {
    DateTime? syncedAt,
  }) {
    final index = _queue.indexWhere((i) => i.id == itemId);
    if (index == -1) return;

    final item = _queue[index];
    _queue[index] = SyncQueueItem(
      id: item.id,
      entityType: item.entityType,
      entityId: item.entityId,
      operation: item.operation,
      status: status,
      payload: item.payload,
      attempts: item.attempts,
      maxAttempts: item.maxAttempts,
      lastError: item.lastError,
      createdAt: item.createdAt,
      syncedAt: syncedAt ?? item.syncedAt,
      nextRetryAt: item.nextRetryAt,
    );
  }

  Future<bool> _processItem(SyncQueueItem item) async {
    if (_syncHandler != null) {
      return await _syncHandler!(item);
    }

    // Default implementation: simulate successful sync
    // In production, this would make actual API calls based on entity type
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  /// Add a conflict to the queue
  void addConflict({
    required SyncEntityType entityType,
    required String entityId,
    required Map<String, dynamic> localValue,
    required Map<String, dynamic> serverValue,
  }) {
    _conflicts.add(
      SyncConflict(
        id: _uuid.v4(),
        entityType: entityType,
        entityId: entityId,
        localValue: localValue,
        serverValue: serverValue,
        detectedAt: DateTime.now(),
      ),
    );
  }

  /// Get all items in queue (for debugging)
  List<SyncQueueItem> getAllItems() => List.unmodifiable(_queue);

  /// Clear entire queue (for testing)
  void clearQueue() {
    _queue.clear();
    _conflicts.clear();
  }
}
