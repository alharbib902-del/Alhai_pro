import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/services/sync_queue_service.dart';

void main() {
  // ── SyncOperationType ────────────────────────────────────

  group('SyncOperationType', () {
    test('has all expected values', () {
      expect(SyncOperationType.values.length, 3);
      expect(SyncOperationType.values, contains(SyncOperationType.create));
      expect(SyncOperationType.values, contains(SyncOperationType.update));
      expect(SyncOperationType.values, contains(SyncOperationType.delete));
    });
  });

  // ── SyncStatus ───────────────────────────────────────────

  group('SyncStatus', () {
    test('has all expected values', () {
      expect(SyncStatus.values.length, 5);
    });

    test('has correct Arabic display names', () {
      expect(SyncStatus.pending.displayNameAr, 'معلق');
      expect(SyncStatus.syncing.displayNameAr, 'جاري المزامنة');
      expect(SyncStatus.synced.displayNameAr, 'متزامن');
      expect(SyncStatus.failed.displayNameAr, 'فشل');
      expect(SyncStatus.conflict.displayNameAr, 'تعارض');
    });

    group('needsAttention', () {
      test('returns true for failed status', () {
        expect(SyncStatus.failed.needsAttention, isTrue);
      });

      test('returns true for conflict status', () {
        expect(SyncStatus.conflict.needsAttention, isTrue);
      });

      test('returns false for pending status', () {
        expect(SyncStatus.pending.needsAttention, isFalse);
      });

      test('returns false for syncing status', () {
        expect(SyncStatus.syncing.needsAttention, isFalse);
      });

      test('returns false for synced status', () {
        expect(SyncStatus.synced.needsAttention, isFalse);
      });
    });
  });

  // ── SyncEntityType ───────────────────────────────────────

  group('SyncEntityType', () {
    test('has all expected values', () {
      expect(SyncEntityType.values.length, 8);
      expect(SyncEntityType.values, contains(SyncEntityType.sale));
      expect(SyncEntityType.values, contains(SyncEntityType.order));
      expect(SyncEntityType.values, contains(SyncEntityType.inventory));
      expect(SyncEntityType.values, contains(SyncEntityType.customer));
      expect(SyncEntityType.values, contains(SyncEntityType.product));
      expect(SyncEntityType.values, contains(SyncEntityType.shift));
      expect(SyncEntityType.values, contains(SyncEntityType.cashMovement));
      expect(SyncEntityType.values, contains(SyncEntityType.refund));
    });
  });

  // ── SyncQueueItem ────────────────────────────────────────

  group('SyncQueueItem', () {
    SyncQueueItem createItem({
      SyncStatus status = SyncStatus.pending,
      int attempts = 0,
      int maxAttempts = 3,
      DateTime? createdAt,
    }) {
      return SyncQueueItem(
        id: 'item-1',
        entityType: SyncEntityType.sale,
        entityId: 'sale-1',
        operation: SyncOperationType.create,
        status: status,
        payload: '{"amount": 100}',
        attempts: attempts,
        maxAttempts: maxAttempts,
        createdAt: createdAt ?? DateTime.now(),
      );
    }

    group('canRetry', () {
      test('returns true when failed and under max attempts', () {
        final item = createItem(status: SyncStatus.failed, attempts: 1);
        expect(item.canRetry, isTrue);
      });

      test('returns false when failed at max attempts', () {
        final item = createItem(
          status: SyncStatus.failed,
          attempts: 3,
          maxAttempts: 3,
        );
        expect(item.canRetry, isFalse);
      });

      test('returns false when pending (not failed)', () {
        final item = createItem(status: SyncStatus.pending, attempts: 0);
        expect(item.canRetry, isFalse);
      });

      test('returns false when synced', () {
        final item = createItem(status: SyncStatus.synced, attempts: 1);
        expect(item.canRetry, isFalse);
      });
    });

    group('needsSync', () {
      test('returns true for pending items', () {
        final item = createItem(status: SyncStatus.pending);
        expect(item.needsSync, isTrue);
      });

      test('returns true for failed items', () {
        final item = createItem(status: SyncStatus.failed);
        expect(item.needsSync, isTrue);
      });

      test('returns false for synced items', () {
        final item = createItem(status: SyncStatus.synced);
        expect(item.needsSync, isFalse);
      });

      test('returns false for syncing items', () {
        final item = createItem(status: SyncStatus.syncing);
        expect(item.needsSync, isFalse);
      });

      test('returns false for conflict items', () {
        final item = createItem(status: SyncStatus.conflict);
        expect(item.needsSync, isFalse);
      });
    });

    group('age', () {
      test('returns positive duration for past creation date', () {
        final item = createItem(
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        );
        expect(item.age.inHours, greaterThanOrEqualTo(5));
      });

      test('returns small duration for recent creation', () {
        final item = createItem(createdAt: DateTime.now());
        expect(item.age.inSeconds, lessThan(2));
      });
    });

    group('JSON serialization', () {
      test('round-trips through JSON', () {
        final original = createItem(
          status: SyncStatus.failed,
          attempts: 2,
        );

        final json = original.toJson();
        final restored = SyncQueueItem.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.entityType, original.entityType);
        expect(restored.entityId, original.entityId);
        expect(restored.operation, original.operation);
        expect(restored.status, original.status);
        expect(restored.attempts, original.attempts);
        expect(restored.maxAttempts, original.maxAttempts);
      });

      test('preserves optional fields through JSON', () {
        final original = SyncQueueItem(
          id: 'item-2',
          entityType: SyncEntityType.order,
          entityId: 'order-1',
          operation: SyncOperationType.update,
          status: SyncStatus.failed,
          payload: '{}',
          attempts: 1,
          lastError: 'Connection timeout',
          createdAt: DateTime(2026, 1, 1),
          nextRetryAt: DateTime(2026, 1, 1, 0, 5),
        );

        final json = original.toJson();
        final restored = SyncQueueItem.fromJson(json);

        expect(restored.lastError, 'Connection timeout');
        expect(restored.nextRetryAt, isNotNull);
      });
    });
  });

  // ── SyncConflict ─────────────────────────────────────────

  group('SyncConflict', () {
    test('stores all required fields', () {
      final conflict = SyncConflict(
        id: 'conflict-1',
        entityType: SyncEntityType.customer,
        entityId: 'cust-1',
        localValue: {'name': 'Ahmed', 'phone': '050'},
        serverValue: {'name': 'Ahmad', 'phone': '055'},
        detectedAt: DateTime(2026, 3, 1),
      );

      expect(conflict.entityType, SyncEntityType.customer);
      expect(conflict.isResolved, isFalse);
      expect(conflict.resolution, isNull);
    });

    test('round-trips through JSON', () {
      final original = SyncConflict(
        id: 'conflict-2',
        entityType: SyncEntityType.product,
        entityId: 'prod-1',
        localValue: {'price': 10.0},
        serverValue: {'price': 12.0},
        detectedAt: DateTime(2026, 3, 15),
        isResolved: true,
        resolution: 'acceptServer',
        resolvedAt: DateTime(2026, 3, 15, 10, 0),
      );

      final json = original.toJson();
      final restored = SyncConflict.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.isResolved, isTrue);
      expect(restored.resolution, 'acceptServer');
    });
  });

  // ── ConflictResolution ───────────────────────────────────

  group('ConflictResolution', () {
    test('has all expected values', () {
      expect(ConflictResolution.values.length, 4);
      expect(ConflictResolution.values, contains(ConflictResolution.acceptLocal));
      expect(ConflictResolution.values, contains(ConflictResolution.acceptServer));
      expect(ConflictResolution.values, contains(ConflictResolution.merge));
      expect(ConflictResolution.values, contains(ConflictResolution.createAdjustment));
    });
  });

  // ── SyncQueueSummary ─────────────────────────────────────

  group('SyncQueueSummary', () {
    test('totalPending sums pending and syncing counts', () {
      const summary = SyncQueueSummary(
        pendingCount: 5,
        syncingCount: 3,
        syncedCount: 10,
        failedCount: 2,
        conflictCount: 1,
      );

      expect(summary.totalPending, 8);
    });

    test('totalIssues sums failed and conflict counts', () {
      const summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 50,
        failedCount: 4,
        conflictCount: 2,
      );

      expect(summary.totalIssues, 6);
    });

    test('hasIssues returns true when there are failures', () {
      const summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 50,
        failedCount: 1,
        conflictCount: 0,
      );

      expect(summary.hasIssues, isTrue);
    });

    test('hasIssues returns true when there are conflicts', () {
      const summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 50,
        failedCount: 0,
        conflictCount: 1,
      );

      expect(summary.hasIssues, isTrue);
    });

    test('hasIssues returns false when no issues', () {
      const summary = SyncQueueSummary(
        pendingCount: 3,
        syncingCount: 1,
        syncedCount: 50,
        failedCount: 0,
        conflictCount: 0,
      );

      expect(summary.hasIssues, isFalse);
    });

    test('isAllSynced returns true when no pending or failed', () {
      const summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 100,
        failedCount: 0,
        conflictCount: 0,
      );

      expect(summary.isAllSynced, isTrue);
    });

    test('isAllSynced returns false when pending items exist', () {
      const summary = SyncQueueSummary(
        pendingCount: 1,
        syncingCount: 0,
        syncedCount: 99,
        failedCount: 0,
        conflictCount: 0,
      );

      expect(summary.isAllSynced, isFalse);
    });

    test('isAllSynced returns false when failed items exist', () {
      const summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 99,
        failedCount: 1,
        conflictCount: 0,
      );

      expect(summary.isAllSynced, isFalse);
    });

    test('stores optional lastSyncAt', () {
      final lastSync = DateTime(2026, 3, 15, 14, 30);
      final summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 10,
        failedCount: 0,
        conflictCount: 0,
        lastSyncAt: lastSync,
      );

      expect(summary.lastSyncAt, lastSync);
    });

    test('lastSyncAt is null by default', () {
      const summary = SyncQueueSummary(
        pendingCount: 0,
        syncingCount: 0,
        syncedCount: 0,
        failedCount: 0,
        conflictCount: 0,
      );

      expect(summary.lastSyncAt, isNull);
    });
  });
}
