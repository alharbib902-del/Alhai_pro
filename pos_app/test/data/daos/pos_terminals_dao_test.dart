import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;

import 'package:pos_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('PosTerminalsDao', () {
    test('create and retrieve terminal', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Terminal 1',
          createdAt: DateTime.now(),
        ),
      );

      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal, isNotNull);
      expect(terminal!.name, 'Terminal 1');
    });

    test('get active terminals', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Active',
          createdAt: DateTime.now(),
        ),
      );

      final active =
          await db.posTerminalsDao.getActiveTerminals('store-1');
      expect(active.length, 1);
    });

    test('update heartbeat', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Terminal 1',
          createdAt: DateTime.now(),
        ),
      );

      await db.posTerminalsDao.updateHeartbeat('term-1');
      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.lastHeartbeatAt, isNotNull);
    });

    test('update current shift', () async {
      await db.posTerminalsDao.upsertTerminal(
        PosTerminalsTableCompanion.insert(
          id: 'term-1',
          storeId: 'store-1',
          orgId: 'org-1',
          name: 'Terminal 1',
          createdAt: DateTime.now(),
        ),
      );

      await db.posTerminalsDao.updateCurrentShift('term-1', 'shift-1');
      final terminal = await db.posTerminalsDao.getTerminal('term-1');
      expect(terminal!.currentShiftId, 'shift-1');
    });
  });
}
