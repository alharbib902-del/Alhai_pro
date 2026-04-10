/// Integration test: Admin Lite Offline Sync
///
/// The admin_lite app uses the same `alhai_sync` queue infrastructure that
/// cashier and admin use. Most lite operations are read-only (dashboards,
/// reports), but approval actions and quick edits still need to flow
/// through the offline-tolerant queue.
///
/// This test exercises the SyncService primitives end-to-end against an
/// in-memory Drift database (no Supabase, no network):
///   1. Approval write is queued
///   2. Queue items persist across SyncService instances
///   3. State transitions: pending -> syncing -> synced
///   4. Empty-queue is the default and remains stable
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
  group('Admin Lite Offline Sync: Queue Creation', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('approval action enqueues an audit log entry', (tester) async {
      // Approving an order generates an audit_log row that needs to sync
      await sync.enqueueCreate(
        tableName: 'audit_log',
        recordId: 'audit-001',
        data: {
          'id': 'audit-001',
          'action': 'order_approved',
          'orderId': 'order-001',
          'approvedBy': 'lite-admin-001',
          'createdAt': DateTime(2026, 1, 15).toIso8601String(),
        },
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.tableName_, equals('audit_log'));
      expect(pending.first.operation, equals('CREATE'));
    });

    testWidgets('order status update is queued', (tester) async {
      await sync.enqueueUpdate(
        tableName: 'orders',
        recordId: 'order-pending-001',
        changes: {'status': 'approved', 'approvedAt': '2026-01-15T10:00:00Z'},
      );

      final pending = await sync.getPendingItems();
      expect(pending, hasLength(1));
      expect(pending.first.operation, equals('UPDATE'));
    });

    testWidgets('multiple approval actions all queue independently',
        (tester) async {
      for (var i = 0; i < 4; i++) {
        await sync.enqueueUpdate(
          tableName: 'orders',
          recordId: 'order-bulk-$i',
          changes: {'status': 'approved'},
        );
      }
      expect(await sync.getPendingCount(), equals(4));
    });
  });

  // ==========================================================================
  // GROUP 2: Persistence
  // ==========================================================================
  group('Admin Lite Offline Sync: Persistence', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('queue items survive a fresh SyncService', (tester) async {
      final s1 = SyncService(db.syncQueueDao);
      await s1.enqueueUpdate(
        tableName: 'orders',
        recordId: 'order-persist',
        changes: {'status': 'approved'},
      );

      final s2 = SyncService(db.syncQueueDao);
      final items = await s2.getPendingItems();
      expect(items, hasLength(1));
      expect(items.first.recordId, equals('order-persist'));
    });

    testWidgets('reading directly from DAO finds queued items', (tester) async {
      final s = SyncService(db.syncQueueDao);
      await s.enqueueUpdate(
        tableName: 'orders',
        recordId: 'order-dao-1',
        changes: {'status': 'approved'},
      );

      final items = await db.syncQueueDao.getPendingItems();
      expect(items.any((i) => i.recordId == 'order-dao-1'), isTrue);
    });
  });

  // ==========================================================================
  // GROUP 3: State Transitions
  // ==========================================================================
  group('Admin Lite Offline Sync: State Transitions', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('approved order syncs successfully', (tester) async {
      await sync.enqueueUpdate(
        tableName: 'orders',
        recordId: 'order-tx-1',
        changes: {'status': 'approved'},
      );
      final pending = await sync.getPendingItems();
      final id = pending.first.id;

      await sync.markAsSyncing(id);
      await sync.markAsSynced(id);

      expect(await sync.getPendingItems(), isEmpty);
    });

    testWidgets('failed approval is retry-eligible', (tester) async {
      await sync.enqueueUpdate(
        tableName: 'orders',
        recordId: 'order-tx-fail',
        changes: {'status': 'approved'},
      );
      final pending = await sync.getPendingItems();
      final id = pending.first.id;

      await sync.markAsSyncing(id);
      await sync.markAsFailed(id, 'Network unreachable');

      // Failed items still surface for retry
      final after = await sync.getPendingItems();
      expect(after, isNotEmpty);
      expect(after.first.id, equals(id));
    });
  });

  // ==========================================================================
  // GROUP 4: Empty Queue
  // ==========================================================================
  group('Admin Lite Offline Sync: Empty Queue', () {
    late AppDatabase db;
    late SyncService sync;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      sync = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('fresh DB has empty pending list', (tester) async {
      expect(await sync.getPendingItems(), isEmpty);
      expect(await sync.getPendingCount(), equals(0));
    });

    testWidgets('DAO is wired up against the in-memory db', (tester) async {
      final result = await db.syncQueueDao.enqueue(
        id: 'lite-raw-1',
        tableName: 'orders',
        recordId: 'order-raw-1',
        operation: 'UPDATE',
        payload: '{"status":"approved"}',
        idempotencyKey: 'orders_order-raw-1_update_lite_raw',
        priority: 2,
      );
      expect(result, greaterThanOrEqualTo(0));
      expect(await db.syncQueueDao.getPendingCount(), equals(1));
    });
  });
}
