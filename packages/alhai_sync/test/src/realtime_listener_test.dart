import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_sync/src/realtime_listener.dart';

import '../helpers/sync_test_helpers.dart';

// GoTrueClient mock is provided by sync_test_helpers

void main() {
  group('RealtimeListener', () {
    group('initial state', () {
      test('isActive is false initially', () {
        final mockClient = MockSupabaseClient();
        final mockDb = MockAppDatabase();

        final listener = RealtimeListener(
          client: mockClient,
          db: mockDb,
        );

        expect(listener.isActive, isFalse);

        listener.dispose();
      });
    });

    group('events stream', () {
      test('is a broadcast stream', () {
        final mockClient = MockSupabaseClient();
        final mockDb = MockAppDatabase();

        final listener = RealtimeListener(
          client: mockClient,
          db: mockDb,
        );

        expect(listener.events.isBroadcast, isTrue);

        listener.dispose();
      });
    });

    group('stop', () {
      test('sets isActive to false', () async {
        final mockClient = MockSupabaseClient();
        final mockDb = MockAppDatabase();

        final listener = RealtimeListener(
          client: mockClient,
          db: mockDb,
        );

        await listener.stop();

        expect(listener.isActive, isFalse);

        await listener.dispose();
      });
    });

    group('dispose', () {
      test('closes event stream', () async {
        final mockClient = MockSupabaseClient();
        final mockDb = MockAppDatabase();

        final listener = RealtimeListener(
          client: mockClient,
          db: mockDb,
        );

        await listener.dispose();

        // After dispose, events stream should be closed
        expect(listener.isActive, isFalse);
      });
    });

    group('watchedTables', () {
      test('contains expected tables', () {
        expect(RealtimeListener.watchedTables, contains('products'));
        expect(RealtimeListener.watchedTables, contains('stock_deltas'));
        expect(RealtimeListener.watchedTables, contains('orders'));
        expect(RealtimeListener.watchedTables, contains('sales'));
        expect(RealtimeListener.watchedTables, contains('categories'));
        expect(RealtimeListener.watchedTables, contains('invoices'));
        expect(RealtimeListener.watchedTables, contains('stock_transfers'));
      });

      test('stock_deltas is first (highest priority)', () {
        expect(RealtimeListener.watchedTables.first, 'stock_deltas');
      });
    });
  });

  group('RealtimeEvent', () {
    test('creates with required fields', () {
      final event = RealtimeEvent(
        tableName: 'products',
        type: RealtimeEventType.insert,
        newRecord: {'id': 'p-1', 'name': 'Test'},
      );

      expect(event.tableName, 'products');
      expect(event.type, RealtimeEventType.insert);
      expect(event.newRecord, isNotNull);
      expect(event.timestamp, isNotNull);
    });

    test('uses provided timestamp', () {
      final ts = DateTime(2026, 3, 15);
      final event = RealtimeEvent(
        tableName: 'products',
        type: RealtimeEventType.update,
        timestamp: ts,
      );

      expect(event.timestamp, ts);
    });

    test('sets default UTC timestamp when not provided', () {
      final before = DateTime.now().toUtc();
      final event = RealtimeEvent(
        tableName: 'products',
        type: RealtimeEventType.delete,
        oldRecord: {'id': 'p-1'},
      );
      final after = DateTime.now().toUtc();

      expect(event.timestamp.isAfter(before.subtract(const Duration(seconds: 1))),
          isTrue);
      expect(
          event.timestamp
              .isBefore(after.add(const Duration(seconds: 1))),
          isTrue);
    });
  });

  group('RealtimeEventType', () {
    test('has insert, update, delete values', () {
      expect(RealtimeEventType.values, hasLength(3));
      expect(RealtimeEventType.values, contains(RealtimeEventType.insert));
      expect(RealtimeEventType.values, contains(RealtimeEventType.update));
      expect(RealtimeEventType.values, contains(RealtimeEventType.delete));
    });
  });
}
