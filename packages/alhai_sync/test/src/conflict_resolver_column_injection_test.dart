import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';

import 'package:alhai_sync/src/conflict_resolver.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Seed minimal parent data required by FK constraints
    final now = DateTime(2025, 1, 1);
    for (final id in ['store-1']) {
      await db.storesDao.insertStore(
        StoresTableCompanion.insert(id: id, name: 'Store $id', createdAt: now),
      );
    }
    for (final id in ['user-1']) {
      await db
          .into(db.usersTable)
          .insert(
            UsersTableCompanion.insert(
              id: id,
              name: 'User $id',
              createdAt: now,
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  group('Column Injection Prevention in ConflictResolver', () {
    test('resolveConflict with malicious column is silently filtered', () async {
      // Enqueue a conflict item with a payload that includes a malicious column
      final maliciousPayload = jsonEncode({
        'id': 'prod-1',
        'store_id': 'store-1',
        'name': 'Safe Product',
        'price': 10.0,
        'created_at': DateTime(2025, 1, 1).millisecondsSinceEpoch,
        // SQL injection attempt via column name
        "name); DROP TABLE sales; --": 'payload',
      });

      // Insert a sync_queue item to act as the conflict record
      await db.syncQueueDao.enqueue(
        id: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        operation: 'INSERT',
        payload: maliciousPayload,
        idempotencyKey: 'key-1',
      );

      // Get the item and mark as conflict
      final items = await db.syncQueueDao.getPendingItems();
      expect(items, isNotEmpty);
      final item = items.first;
      await db.syncQueueDao.markAsConflict(item.id, 'test conflict');

      // Resolve using serverWins — should filter out the malicious column
      const resolver = ConflictResolver();
      await resolver.resolveConflict(
        conflictId: item.id,
        strategy: ResolutionStrategy.serverWins,
        db: db,
        syncQueueDao: db.syncQueueDao,
      );

      // Verify: the product was inserted with safe columns only
      final product = await db.productsDao.getProductById('prod-1');
      expect(product, isNotNull);
      expect(product!.name, 'Safe Product');

      // Verify: sales table still exists (injection attempt failed)
      final salesCount = await db
          .customSelect(
            "SELECT COUNT(*) as cnt FROM sqlite_master WHERE type='table' AND name='sales'",
          )
          .getSingle();
      expect(salesCount.data['cnt'], 1);
    });

    test('resolveConflict with valid columns succeeds normally', () async {
      final validPayload = jsonEncode({
        'id': 'prod-2',
        'store_id': 'store-1',
        'name': 'Normal Product',
        'price': 25.0,
        'created_at': DateTime(2025, 1, 1).millisecondsSinceEpoch,
      });

      await db.syncQueueDao.enqueue(
        id: 'sq-2',
        tableName: 'products',
        recordId: 'prod-2',
        operation: 'INSERT',
        payload: validPayload,
        idempotencyKey: 'key-2',
      );

      final items = await db.syncQueueDao.getPendingItems();
      final item = items.first;
      await db.syncQueueDao.markAsConflict(item.id, 'test conflict');

      const resolver = ConflictResolver();
      await resolver.resolveConflict(
        conflictId: item.id,
        strategy: ResolutionStrategy.serverWins,
        db: db,
        syncQueueDao: db.syncQueueDao,
      );

      final product = await db.productsDao.getProductById('prod-2');
      expect(product, isNotNull);
      expect(product!.name, 'Normal Product');
      expect(product.price, 25.0);
    });
  });
}
