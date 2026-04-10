/// Integration test: Cashier Offline Sync
///
/// The cashier app is designed as "100% offline" (see pubspec description).
/// Every user action is written to the local Drift database first; network
/// sync is a background process managed by `alhai_sync.SyncService`.
///
/// This test verifies that the offline queue primitives work end-to-end
/// without any network connection:
///   1. Queue creation - new sync operations land in sync_queue table
///   2. Queue persistence - items survive across reads (real local DB)
///   3. Queue processing on reconnect - items can be moved from pending
///      -> syncing -> synced without a real Supabase client
///   4. Dedup / idempotency - duplicate enqueues do not create duplicates
///   5. Graceful degradation - SyncService handles empty queue correctly
///
/// Network failure is simulated implicitly: we never instantiate a real
/// Supabase client, so any code path that tries to push to a remote will
/// throw or remain pending. The queue itself is local-only and fully
/// exercised against an in-memory Drift database.
///
/// Run with:
///   flutter test integration_test/offline_sync_test.dart
///   (requires a running device or emulator - sqlcipher_flutter_libs needs native)
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // GROUP 1: Offline Queue Creation
  // ==========================================================================
  //
  // Verifies that enqueueing a sync operation against a freshly-created
  // in-memory Drift database:
  //   * creates a new sync_queue row
  //   * returns a non-empty item id
  //   * exposes the item via getPendingItems() / getPendingCount()
  //
  // This is the path a sale takes when a cashier rings up a transaction
  // with no network: write to local DB + enqueue -> let background worker
  // sync later.
  // ==========================================================================
  group('Offline Sync: Queue Creation', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('enqueueCreate for a sale produces a pending queue item',
        (tester) async {
      // Simulate an offline sale creation
      final itemId = await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-offline-001',
        data: {
          'id': 'sale-offline-001',
          'storeId': 'test-store-001',
          'total': 115.0,
          'subtotal': 100.0,
          'tax': 15.0,
          'paymentMethod': 'cash',
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
        },
        priority: SyncPriority.high,
      );

      expect(itemId, isNotEmpty);

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.tableName_, equals('sales'));
      expect(pending.first.recordId, equals('sale-offline-001'));
      expect(pending.first.operation, equals('CREATE'));
      expect(pending.first.status, equals('pending'));
    });

    testWidgets('multiple enqueues are tracked by getPendingCount',
        (tester) async {
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-offline-a',
        data: {'id': 'sale-offline-a', 'total': 50.0},
        priority: SyncPriority.high,
      );
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-offline-b',
        data: {'id': 'sale-offline-b', 'total': 75.0},
        priority: SyncPriority.high,
      );
      await sync.enqueueCreate(
        tableName: 'inventory_movements',
        recordId: 'mov-1',
        data: {'id': 'mov-1', 'qty': -2},
        priority: SyncPriority.high,
      );

      final count = await sync.getPendingCount();
      expect(count, equals(3));
    });

    testWidgets('enqueueUpdate records an UPDATE operation', (tester) async {
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'prod-001',
        changes: {'price': 7.50},
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.operation, equals('UPDATE'));
    });

    testWidgets('enqueueDelete records a DELETE operation', (tester) async {
      await sync.enqueueDelete(
        tableName: 'products',
        recordId: 'prod-001',
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.operation, equals('DELETE'));
    });
  });

  // ==========================================================================
  // GROUP 2: Queue Persistence
  // ==========================================================================
  //
  // Ensures queue items remain intact when the SyncService is re-created
  // against the same database. This mirrors the scenario where the app is
  // closed and reopened while offline - queued sales must not be lost.
  // ==========================================================================
  group('Offline Sync: Queue Persistence', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('queue items survive SyncService re-instantiation',
        (tester) async {
      final sync1 = SyncService(db.syncQueueDao);
      await sync1.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-persist-1',
        data: {'id': 'sale-persist-1', 'total': 200.0},
        priority: SyncPriority.high,
      );

      // Re-instantiate SyncService (simulating app restart)
      final sync2 = SyncService(db.syncQueueDao);
      final pendingAfter = await sync2.getPendingItems();

      expect(pendingAfter, hasLength(1));
      expect(pendingAfter.first.recordId, equals('sale-persist-1'));
      expect(pendingAfter.first.status, equals('pending'));
    });

    testWidgets('direct DAO read finds enqueued items', (tester) async {
      final sync = SyncService(db.syncQueueDao);
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-dao-1',
        data: {'id': 'sale-dao-1', 'total': 10.0},
        priority: SyncPriority.high,
      );

      // Bypass the service and hit the DAO directly
      final items = await db.syncQueueDao.getPendingItems();
      expect(items, isNotEmpty);
      expect(
        items.any((i) => i.recordId == 'sale-dao-1'),
        isTrue,
      );
    });

    testWidgets('queue count matches number of enqueued items',
        (tester) async {
      final sync = SyncService(db.syncQueueDao);

      const n = 5;
      for (var i = 0; i < n; i++) {
        await sync.enqueueCreate(
          tableName: 'sales',
          recordId: 'sale-bulk-$i',
          data: {'id': 'sale-bulk-$i', 'total': i * 10.0},
          priority: SyncPriority.high,
        );
      }

      expect(await sync.getPendingCount(), equals(n));
    });
  });

  // ==========================================================================
  // GROUP 3: Sync on Reconnect
  // ==========================================================================
  //
  // Simulates the state transitions a queue item goes through when the
  // network comes back online:
  //   pending -> syncing -> synced
  //
  // We do not talk to a real Supabase client in this test. Instead, we
  // drive the DAO directly to verify that the queue machinery supports
  // a successful sync path.
  // ==========================================================================
  group('Offline Sync: Reconnect Processing', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('item can transition pending -> syncing -> synced',
        (tester) async {
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-reconnect-1',
        data: {'id': 'sale-reconnect-1', 'total': 500.0},
        priority: SyncPriority.high,
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      final itemId = pending.first.id;

      // Mark as syncing (worker picks it up)
      await sync.markAsSyncing(itemId);
      // Simulate successful push to remote
      await sync.markAsSynced(itemId);

      // After successful sync, item should no longer be in pending
      final pendingAfter = await sync.getPendingItems();
      expect(pendingAfter, isEmpty);
    });

    testWidgets('failed item stays in queue with retry available',
        (tester) async {
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-retry-1',
        data: {'id': 'sale-retry-1', 'total': 50.0},
        priority: SyncPriority.high,
      );

      final pending = await sync.getPendingItems();
      final itemId = pending.first.id;

      await sync.markAsSyncing(itemId);
      await sync.markAsFailed(itemId, 'Network error');

      // Failed item should still show up in getPendingItems (retry-eligible)
      final afterFail = await sync.getPendingItems();
      expect(afterFail, isNotEmpty);
      expect(afterFail.first.id, equals(itemId));
    });
  });

  // ==========================================================================
  // GROUP 4: Dedup / Idempotency
  // ==========================================================================
  //
  // SyncService has idempotency guards that prevent duplicate rows from
  // being inserted for the same record/operation. This is critical because
  // a bug in cashier UI could easily fire the same enqueue twice.
  // ==========================================================================
  group('Offline Sync: Idempotency', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('duplicate enqueue for same sale coalesces into one item',
        (tester) async {
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-dup-1',
        data: {'id': 'sale-dup-1', 'total': 100.0},
        priority: SyncPriority.high,
      );
      // Second enqueue for the same record id + operation
      await sync.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-dup-1',
        data: {'id': 'sale-dup-1', 'total': 100.0},
        priority: SyncPriority.high,
      );

      // Dedup should keep it at a single row
      final count = await sync.getPendingCount();
      expect(count, equals(1));
    });
  });

  // ==========================================================================
  // GROUP 5: Graceful Degradation
  // ==========================================================================
  //
  // Verifies that the sync primitives behave correctly when the queue is
  // empty (the common case after a successful sync cycle).
  // ==========================================================================
  group('Offline Sync: Empty Queue', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('getPendingItems returns empty list with no queued work',
        (tester) async {
      final items = await sync.getPendingItems();
      expect(items, isEmpty);
    });

    testWidgets('getPendingCount is zero on a fresh DB', (tester) async {
      final count = await sync.getPendingCount();
      expect(count, equals(0));
    });

    testWidgets('DAO accepts a direct insert companion', (tester) async {
      // Sanity check that the sync_queue table is real and writable.
      // Uses a companion directly (bypassing SyncService) so we know the
      // table, schema and migrations are wired up correctly on device.
      final result = await db.syncQueueDao.enqueue(
        id: 'raw-1',
        tableName: 'sales',
        recordId: 'sale-raw-1',
        operation: 'CREATE',
        payload: '{"id":"sale-raw-1","total":1.0}',
        idempotencyKey: 'sales_sale-raw-1_create_raw',
        priority: 3,
      );
      // enqueue returns the number of affected rows or the inserted id
      expect(result, greaterThanOrEqualTo(0));

      final count = await db.syncQueueDao.getPendingCount();
      expect(count, equals(1));
    });
  });
}
