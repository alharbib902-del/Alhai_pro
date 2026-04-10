/// Integration test: Admin Offline Sync
///
/// The admin app is online-first but still relies on the same `alhai_sync`
/// queue infrastructure used by the cashier app. Admins frequently perform
/// management operations (price changes, inventory adjustments, supplier
/// edits, etc.) that need to be queued, deduped, and retried in the same
/// way cashier sales are.
///
/// This test exercises the SyncService primitives end-to-end against an
/// in-memory Drift database (no Supabase, no network):
///   1. Queue creation - admin updates land in sync_queue table
///   2. Queue persistence - items survive across reads
///   3. State transitions - pending -> syncing -> synced
///   4. Idempotency - duplicate enqueues coalesce
///   5. Empty-queue behavior - no work to do is the common case
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
  // GROUP 1: Queue Creation
  // ==========================================================================
  group('Admin Offline Sync: Queue Creation', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('admin product update is queued', (tester) async {
      final id = await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'prod-001',
        changes: {'price': 8.50, 'updatedBy': 'admin-001'},
      );
      expect(id, isNotEmpty);

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.tableName_, equals('products'));
      expect(pending.first.operation, equals('UPDATE'));
    });

    testWidgets('admin can queue a delete operation', (tester) async {
      await sync.enqueueDelete(
        tableName: 'products',
        recordId: 'prod-discontinued',
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.operation, equals('DELETE'));
    });

    testWidgets('admin can queue a new supplier creation', (tester) async {
      await sync.enqueueCreate(
        tableName: 'suppliers',
        recordId: 'sup-new-001',
        data: {
          'id': 'sup-new-001',
          'storeId': 'store-001',
          'name': 'New Supplier',
        },
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.tableName_, equals('suppliers'));
      expect(pending.first.operation, equals('CREATE'));
    });

    testWidgets('multiple admin operations all land in queue', (tester) async {
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-1',
        changes: {'price': 1.0},
      );
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-2',
        changes: {'price': 2.0},
      );
      await sync.enqueueCreate(
        tableName: 'suppliers',
        recordId: 's-1',
        data: {'id': 's-1', 'storeId': 'store-1', 'name': 'Sup One'},
      );

      expect(await sync.getPendingCount(), equals(3));
    });
  });

  // ==========================================================================
  // GROUP 2: Persistence
  // ==========================================================================
  group('Admin Offline Sync: Persistence', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('queue items survive a fresh SyncService instance',
        (tester) async {
      final sync1 = SyncService(db.syncQueueDao);
      await sync1.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-persist-1',
        changes: {'name': 'Updated Name'},
      );

      final sync2 = SyncService(db.syncQueueDao);
      final items = await sync2.getPendingItems();

      expect(items, hasLength(1));
      expect(items.first.recordId, equals('p-persist-1'));
    });

    testWidgets('DAO direct query finds enqueued items', (tester) async {
      final sync = SyncService(db.syncQueueDao);
      await sync.enqueueCreate(
        tableName: 'expenses',
        recordId: 'exp-001',
        data: {'id': 'exp-001', 'amount': 100.0, 'category': 'rent'},
      );

      final items = await db.syncQueueDao.getPendingItems();
      expect(items, isNotEmpty);
      expect(items.any((i) => i.recordId == 'exp-001'), isTrue);
    });
  });

  // ==========================================================================
  // GROUP 3: State Transitions
  // ==========================================================================
  group('Admin Offline Sync: State Transitions', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('admin update transitions pending -> syncing -> synced',
        (tester) async {
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-tx-1',
        changes: {'price': 99.99},
      );
      final pending = await sync.getPendingItems();
      final id = pending.first.id;

      await sync.markAsSyncing(id);
      await sync.markAsSynced(id);

      expect(await sync.getPendingItems(), isEmpty);
    });

    testWidgets('failed item is still retry-eligible', (tester) async {
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-tx-fail',
        changes: {'price': 50.0},
      );

      final pending = await sync.getPendingItems();
      final id = pending.first.id;

      await sync.markAsSyncing(id);
      await sync.markAsFailed(id, 'HTTP 500 from /products/p-tx-fail');

      // Failed items still appear in getPendingItems for retry
      final after = await sync.getPendingItems();
      expect(after, isNotEmpty);
      expect(after.first.id, equals(id));
    });
  });

  // ==========================================================================
  // GROUP 4: Idempotency
  // ==========================================================================
  group('Admin Offline Sync: Idempotency', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('duplicate update enqueue coalesces into single item',
        (tester) async {
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-dup',
        changes: {'price': 10.0},
      );
      // Same operation again - should not create a new row
      await sync.enqueueUpdate(
        tableName: 'products',
        recordId: 'p-dup',
        changes: {'price': 12.0},
      );

      expect(await sync.getPendingCount(), equals(1));
    });
  });

  // ==========================================================================
  // GROUP 5: Empty Queue
  // ==========================================================================
  group('Admin Offline Sync: Empty Queue', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('fresh database returns empty pending list', (tester) async {
      final items = await sync.getPendingItems();
      expect(items, isEmpty);
    });

    testWidgets('fresh database has zero pending count', (tester) async {
      expect(await sync.getPendingCount(), equals(0));
    });

    testWidgets('DAO is wired up and the table exists', (tester) async {
      final result = await db.syncQueueDao.enqueue(
        id: 'admin-raw-1',
        tableName: 'products',
        recordId: 'p-raw',
        operation: 'UPDATE',
        payload: '{"price":1.0}',
        idempotencyKey: 'products_p-raw_update_admin_raw',
        priority: 2,
      );
      expect(result, greaterThanOrEqualTo(0));
      expect(await db.syncQueueDao.getPendingCount(), equals(1));
    });
  });
}
