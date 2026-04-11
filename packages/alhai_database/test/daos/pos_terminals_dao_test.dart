import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  PosTerminalsTableCompanion makeTerminal({
    String id = 'term-1',
    String storeId = 'store-1',
    String orgId = 'org-1',
    String name = 'كاشير 1',
    bool isActive = true,
  }) {
    return PosTerminalsTableCompanion.insert(
      id: id,
      storeId: storeId,
      orgId: orgId,
      name: name,
      isActive: Value(isActive),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('PosTerminalsDao', () {
    test('upsertTerminal and getTerminal', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal, isNotNull);
      expect(terminal!.name, 'كاشير 1');
      expect(terminal.storeId, 'store-1');
    });

    test('getTerminal returns null for non-existent', () async {
      final terminal = await db.posTerminalsDao.getTerminal('non-existent');
      expect(terminal, isNull);
    });

    test('getStoreTerminals returns all terminals for store', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());
      await db.posTerminalsDao.upsertTerminal(
        makeTerminal(id: 'term-2', name: 'كاشير 2'),
      );

      final terminals = await db.posTerminalsDao.getStoreTerminals('store-1');
      expect(terminals, hasLength(2));
    });

    test('getActiveTerminals returns only active', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal(isActive: true));
      await db.posTerminalsDao.upsertTerminal(
        makeTerminal(id: 'term-2', name: 'معطل', isActive: false),
      );

      final active = await db.posTerminalsDao.getActiveTerminals('store-1');
      expect(active, hasLength(1));
      expect(active.first.name, 'كاشير 1');
    });

    test('deleteTerminal removes terminal', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());

      final deleted = await db.posTerminalsDao.deleteTerminal('term-1');
      expect(deleted, 1);

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal, isNull);
    });

    test('updateHeartbeat sets lastHeartbeatAt', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());

      await db.posTerminalsDao.updateHeartbeat('term-1');

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.lastHeartbeatAt, isNotNull);
    });

    test('updateCurrentShift sets currentShiftId', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());

      await db.posTerminalsDao.updateCurrentShift('term-1', 'shift-1');

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.currentShiftId, 'shift-1');
    });

    test('updateCurrentShift clears shiftId with null', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());
      await db.posTerminalsDao.updateCurrentShift('term-1', 'shift-1');
      await db.posTerminalsDao.updateCurrentShift('term-1', null);

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.currentShiftId, isNull);
    });

    test('updateCurrentUser sets currentUserId', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());

      await db.posTerminalsDao.updateCurrentUser('term-1', 'user-1');

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.currentUserId, 'user-1');
    });

    test('markAsSynced sets syncedAt', () async {
      await db.posTerminalsDao.upsertTerminal(makeTerminal());

      await db.posTerminalsDao.markAsSynced('term-1');

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.syncedAt, isNotNull);
    });
  });
}
