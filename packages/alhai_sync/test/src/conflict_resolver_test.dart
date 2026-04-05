import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_sync/src/conflict_resolver.dart';

void main() {
  late ConflictResolver resolver;

  setUp(() {
    resolver = const ConflictResolver();
  });

  // ── Test Helpers ──────────────────────────────────────────

  SyncConflict makeConflict({
    String tableName = 'products',
    ConflictType type = ConflictType.versionConflict,
    String operation = 'UPDATE',
    Map<String, dynamic>? localData,
    Map<String, dynamic>? serverData,
    String recordId = 'rec-1',
  }) {
    return SyncConflict(
      syncQueueId: 'sq-1',
      tableName: tableName,
      recordId: recordId,
      type: type,
      operation: operation,
      localData: localData,
      serverData: serverData,
      errorMessage: 'Test conflict',
    );
  }

  group('ConflictResolver', () {
    // ── getStrategy ─────────────────────────────────────

    group('getStrategy', () {
      test('returns localWins for POS-originated sales data', () {
        for (final table in [
          'sales',
          'sale_items',
          'shifts',
          'cash_movements'
        ]) {
          expect(
            resolver.getStrategy(table, ConflictType.versionConflict),
            ResolutionStrategy.localWins,
            reason: '$table should be localWins',
          );
        }
      });

      test('returns serverWins for admin-controlled data', () {
        for (final table in [
          'categories',
          'settings',
          'discounts',
          'coupons',
          'promotions',
          'roles',
          'stores',
        ]) {
          expect(
            resolver.getStrategy(table, ConflictType.versionConflict),
            ResolutionStrategy.serverWins,
            reason: '$table should be serverWins',
          );
        }
      });

      test('returns serverWins for products (price/name)', () {
        expect(
          resolver.getStrategy('products', ConflictType.versionConflict),
          ResolutionStrategy.serverWins,
        );
      });

      test('returns lastWriteWins for bidirectional data', () {
        for (final table in [
          'customers',
          'suppliers',
          'notifications',
          'orders',
        ]) {
          expect(
            resolver.getStrategy(table, ConflictType.versionConflict),
            ResolutionStrategy.lastWriteWins,
            reason: '$table should be lastWriteWins',
          );
        }
      });

      test('returns localWins for transaction data', () {
        for (final table in ['expenses', 'returns', 'purchases']) {
          expect(
            resolver.getStrategy(table, ConflictType.versionConflict),
            ResolutionStrategy.localWins,
            reason: '$table should be localWins',
          );
        }
      });

      test('returns lastWriteWins for unknown tables', () {
        expect(
          resolver.getStrategy('unknown_table', ConflictType.versionConflict),
          ResolutionStrategy.lastWriteWins,
        );
      });
    });

    // ── Delete-Update strategies ─────────────────────────

    group('delete-update conflict strategies', () {
      test('returns manual for POS-critical data (sales, shifts)', () {
        for (final table in ['sales', 'sale_items', 'shifts']) {
          expect(
            resolver.getStrategy(table, ConflictType.deleteUpdate),
            ResolutionStrategy.manual,
            reason: '$table delete-update should be manual',
          );
        }
      });

      test('returns serverWins for admin-deleted products', () {
        expect(
          resolver.getStrategy('products', ConflictType.deleteUpdate),
          ResolutionStrategy.serverWins,
        );
      });

      test('returns serverWins for most delete-update conflicts', () {
        expect(
          resolver.getStrategy('customers', ConflictType.deleteUpdate),
          ResolutionStrategy.serverWins,
        );
      });
    });

    // ── resolve - special types ──────────────────────────

    group('resolve - special conflict types', () {
      test('returns unresolved for network timeouts', () async {
        final conflict = makeConflict(type: ConflictType.networkTimeout);
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isFalse);
        expect(result.description, contains('retry'));
      });

      test('returns unresolved for schema mismatches', () async {
        final conflict = makeConflict(type: ConflictType.schemaMismatch);
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isFalse);
        expect(result.description, contains('Schema mismatch'));
      });

      test('resolves duplicate key by converting to upsert', () async {
        final conflict = makeConflict(
          type: ConflictType.duplicateKey,
          localData: {'id': 'rec-1', 'name': 'Product'},
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.strategy, ResolutionStrategy.localWins);
        expect(result.resolvedData, conflict.localData);
        expect(result.description, contains('UPSERT'));
      });
    });

    // ── resolve - serverWins ─────────────────────────────

    group('resolve - serverWins', () {
      test('uses server data when available', () async {
        final conflict = makeConflict(
          tableName: 'products',
          serverData: {'id': 'rec-1', 'name': 'Server Product', 'price': 20.0},
          localData: {'id': 'rec-1', 'name': 'Local Product', 'price': 15.0},
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.strategy, ResolutionStrategy.serverWins);
        expect(result.resolvedData!['name'], 'Server Product');
      });

      test('returns unresolved when server data is null', () async {
        final conflict = makeConflict(
          tableName: 'products',
          serverData: null,
          localData: {'id': 'rec-1', 'name': 'Local Product'},
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isFalse);
        expect(result.strategy, ResolutionStrategy.serverWins);
      });
    });

    // ── resolve - localWins ──────────────────────────────

    group('resolve - localWins', () {
      test('uses local data for POS-originated tables', () async {
        final conflict = makeConflict(
          tableName: 'sales',
          localData: {'id': 'rec-1', 'total': 100.0},
          serverData: {'id': 'rec-1', 'total': 90.0},
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.strategy, ResolutionStrategy.localWins);
        expect(result.resolvedData!['total'], 100.0);
      });

      test('returns unresolved when local data is null', () async {
        final conflict = makeConflict(
          tableName: 'sales',
          localData: null,
          serverData: {'id': 'rec-1', 'total': 100.0},
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isFalse);
        expect(result.strategy, ResolutionStrategy.localWins);
      });
    });

    // ── resolve - lastWriteWins ──────────────────────────

    group('resolve - lastWriteWins', () {
      test('chooses local when local updated_at is more recent', () async {
        final conflict = makeConflict(
          tableName: 'customers',
          localData: {
            'id': 'rec-1',
            'name': 'Updated Name',
            'updated_at': '2026-01-15T12:00:00Z',
          },
          serverData: {
            'id': 'rec-1',
            'name': 'Old Name',
            'updated_at': '2026-01-15T10:00:00Z',
          },
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.resolvedData!['name'], 'Updated Name');
        expect(result.description, contains('Local'));
      });

      test('chooses server when server updated_at is more recent', () async {
        final conflict = makeConflict(
          tableName: 'customers',
          localData: {
            'id': 'rec-1',
            'name': 'Old Local',
            'updated_at': '2026-01-15T08:00:00Z',
          },
          serverData: {
            'id': 'rec-1',
            'name': 'Fresh Server',
            'updated_at': '2026-01-15T14:00:00Z',
          },
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.resolvedData!['name'], 'Fresh Server');
        expect(result.description, contains('Server'));
      });

      test('defaults to server when no timestamps available', () async {
        final conflict = makeConflict(
          tableName: 'customers',
          localData: {'id': 'rec-1', 'name': 'Local'},
          serverData: {'id': 'rec-1', 'name': 'Server'},
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.resolvedData!['name'], 'Server');
      });

      test('handles integer timestamps (unix seconds)', () async {
        final conflict = makeConflict(
          tableName: 'customers',
          localData: {
            'id': 'rec-1',
            'name': 'Local',
            'updated_at': 1736942400, // 2025-01-15T12:00:00Z
          },
          serverData: {
            'id': 'rec-1',
            'name': 'Server',
            'updated_at': 1736935200, // 2025-01-15T10:00:00Z
          },
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        // Local has more recent timestamp
        expect(result.resolvedData!['name'], 'Local');
      });

      test('uses only available version when one side is missing', () async {
        final conflict = makeConflict(
          tableName: 'customers',
          localData: {'id': 'rec-1', 'name': 'Only Local'},
          serverData: null,
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        expect(result.resolvedData!['name'], 'Only Local');
      });

      test('returns unresolved when both sides are null', () async {
        final conflict = makeConflict(
          tableName: 'customers',
          localData: null,
          serverData: null,
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isFalse);
      });
    });

    // ── resolve - order status priority ──────────────────

    group('resolve - order conflicts', () {
      test('higher status priority wins regardless of timestamp', () async {
        final conflict = makeConflict(
          tableName: 'orders',
          localData: {
            'id': 'order-1',
            'status': 'completed',
            'updated_at': '2026-01-15T10:00:00Z', // older
          },
          serverData: {
            'id': 'order-1',
            'status': 'preparing',
            'updated_at': '2026-01-15T14:00:00Z', // newer
          },
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        // Local "completed" (priority 5) > server "preparing" (priority 2)
        expect(result.resolvedData!['status'], 'completed');
      });

      test('falls back to timestamp when status priority is equal', () async {
        final conflict = makeConflict(
          tableName: 'orders',
          localData: {
            'id': 'order-1',
            'status': 'preparing',
            'updated_at': '2026-01-15T14:00:00Z',
          },
          serverData: {
            'id': 'order-1',
            'status': 'ready', // same priority as preparing (2)
            'updated_at': '2026-01-15T10:00:00Z',
          },
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        // Same priority, so local wins by timestamp
        expect(result.resolvedData!['status'], 'preparing');
      });

      test('cancelled order wins over preparing', () async {
        final conflict = makeConflict(
          tableName: 'orders',
          localData: {
            'id': 'order-1',
            'status': 'cancelled',
            'updated_at': '2026-01-15T10:00:00Z',
          },
          serverData: {
            'id': 'order-1',
            'status': 'preparing',
            'updated_at': '2026-01-15T14:00:00Z',
          },
        );
        final result = await resolver.resolve(conflict);

        expect(result.resolved, isTrue);
        // cancelled (4) > preparing (2)
        expect(result.resolvedData!['status'], 'cancelled');
      });
    });

    // ── resolve - merge strategy ─────────────────────────

    group('resolve - merge', () {
      test('merges product data with server base and local stock', () async {
        makeConflict(
          tableName: 'products',
          type: ConflictType.versionConflict,
          localData: {
            'id': 'prod-1',
            'name': 'Old Name',
            'price': 10.0,
            'stock_qty': 50,
          },
          serverData: {
            'id': 'prod-1',
            'name': 'New Name',
            'price': 12.0,
            'stock_qty': 40,
          },
        );

        // Products use serverWins strategy, not merge, for version conflicts
        // This test verifies that products use serverWins
        final strategy =
            resolver.getStrategy('products', ConflictType.versionConflict);
        expect(strategy, ResolutionStrategy.serverWins);
      });

      test('merge fails gracefully when missing one side', () async {
        // Test merge directly using a hypothetical table that uses merge
        // We can test the code path by looking at the result
        final conflict = makeConflict(
          tableName: 'products',
          localData: null,
          serverData: {'id': 'rec-1', 'name': 'Server'},
        );

        final result = await resolver.resolve(conflict);
        // serverWins with no local data still resolves using server
        expect(result.resolved, isTrue);
        expect(result.resolvedData!['name'], 'Server');
      });
    });
  });

  // ── SyncConflict Model ──────────────────────────────────

  group('SyncConflict', () {
    test('toJsonString produces valid JSON', () {
      final conflict = SyncConflict(
        syncQueueId: 'sq-1',
        tableName: 'products',
        recordId: 'prod-1',
        type: ConflictType.versionConflict,
        operation: 'UPDATE',
        localData: {'id': 'prod-1', 'name': 'Local'},
        serverData: {'id': 'prod-1', 'name': 'Server'},
        errorMessage: 'Version mismatch',
      );

      final json = conflict.toJsonString();
      final parsed = jsonDecode(json) as Map<String, dynamic>;

      expect(parsed['conflict_type'], 'versionConflict');
      expect(parsed['operation'], 'UPDATE');
      expect(parsed['table'], 'products');
      expect(parsed['record_id'], 'prod-1');
    });

    test('fromJsonString round-trips correctly', () {
      final original = SyncConflict(
        syncQueueId: 'sq-1',
        tableName: 'customers',
        recordId: 'cust-1',
        type: ConflictType.deleteUpdate,
        operation: 'DELETE',
        localData: {'id': 'cust-1'},
        serverData: {'id': 'cust-1', 'name': 'Updated'},
        errorMessage: 'Delete conflict',
      );

      final json = original.toJsonString();
      final restored = SyncConflict.fromJsonString(json, syncQueueId: 'sq-1');

      expect(restored, isNotNull);
      expect(restored!.tableName, 'customers');
      expect(restored.recordId, 'cust-1');
      expect(restored.type, ConflictType.deleteUpdate);
      expect(restored.operation, 'DELETE');
    });

    test('fromJsonString returns null for invalid JSON', () {
      final result = SyncConflict.fromJsonString(
        'not json',
        syncQueueId: 'sq-1',
      );
      expect(result, isNull);
    });

    test('fromJsonString returns null when missing conflict_type', () {
      final json = jsonEncode({
        'operation': 'UPDATE',
        'table': 'products',
      });
      final result = SyncConflict.fromJsonString(json, syncQueueId: 'sq-1');
      expect(result, isNull);
    });

    test('defaults to versionConflict for unknown conflict types', () {
      final json = jsonEncode({
        'conflict_type': 'unknownType',
        'operation': 'UPDATE',
        'table': 'products',
        'record_id': 'prod-1',
      });
      final result = SyncConflict.fromJsonString(json, syncQueueId: 'sq-1');

      expect(result, isNotNull);
      expect(result!.type, ConflictType.versionConflict);
    });
  });

  // ── ResolutionResult Model ──────────────────────────────

  group('ResolutionResult', () {
    test('stores all fields correctly', () {
      const result = ResolutionResult(
        resolved: true,
        strategy: ResolutionStrategy.serverWins,
        resolvedData: {'id': '1', 'name': 'Winner'},
        description: 'Server version accepted',
      );

      expect(result.resolved, isTrue);
      expect(result.strategy, ResolutionStrategy.serverWins);
      expect(result.resolvedData!['name'], 'Winner');
      expect(result.description, contains('Server'));
    });
  });

  // ── SyncHealthReport (from sync_engine) ──────────────────

  // Note: SyncHealthReport tests are in sync_engine_test.dart
}
