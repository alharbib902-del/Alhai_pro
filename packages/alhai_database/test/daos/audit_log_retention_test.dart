import 'package:drift/drift.dart';
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

  group('cleanupOldLogs — 6-year retention integration', () {
    Future<void> _insertAuditLog({
      required DateTime createdAt,
      DateTime? syncedAt,
    }) async {
      final id = 'test_${createdAt.millisecondsSinceEpoch}';
      await db
          .into(db.auditLogTable)
          .insert(
            AuditLogTableCompanion.insert(
              id: id,
              storeId: 'store-1',
              userId: 'user-1',
              userName: 'test',
              action: 'login',
              createdAt: createdAt,
              syncedAt: Value(syncedAt),
            ),
          );
    }

    test('does NOT delete synced audit logs younger than 6 years', () async {
      // 5-year-old synced log — must survive cleanup
      final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 1825));
      await _insertAuditLog(
        createdAt: fiveYearsAgo,
        syncedAt: fiveYearsAgo.add(const Duration(hours: 1)),
      );

      await db.auditLogDao.cleanupOldLogs();

      final remaining = await db.select(db.auditLogTable).get();
      expect(
        remaining.length,
        equals(1),
        reason: '5-year-old audit log must NOT be deleted',
      );
    });

    test('deletes synced audit logs older than 6 years', () async {
      // 7-year-old synced log — should be cleaned
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));
      await _insertAuditLog(
        createdAt: sevenYearsAgo,
        syncedAt: sevenYearsAgo.add(const Duration(hours: 1)),
      );

      final deleted = await db.auditLogDao.cleanupOldLogs();

      expect(deleted, equals(1));
      final remaining = await db.select(db.auditLogTable).get();
      expect(remaining, isEmpty);
    });

    test('never deletes unsynced audit logs regardless of age', () async {
      // 8-year-old UNSYNCED log — must survive (not yet backed up)
      final eightYearsAgo = DateTime.now().subtract(const Duration(days: 2920));
      await _insertAuditLog(
        createdAt: eightYearsAgo,
        syncedAt: null, // not synced
      );

      await db.auditLogDao.cleanupOldLogs();

      final remaining = await db.select(db.auditLogTable).get();
      expect(
        remaining.length,
        equals(1),
        reason: 'Unsynced audit log must NEVER be deleted',
      );
    });

    test('mixed scenario: only old+synced records are deleted', () async {
      // 1) Recent synced — keep
      await _insertAuditLog(
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        syncedAt: DateTime.now().subtract(const Duration(days: 29)),
      );
      // 2) 5-year-old synced — keep (under 6 years)
      final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 1825));
      await _insertAuditLog(createdAt: fiveYearsAgo, syncedAt: fiveYearsAgo);
      // 3) 7-year-old synced — delete
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));
      await _insertAuditLog(createdAt: sevenYearsAgo, syncedAt: sevenYearsAgo);
      // 4) 8-year-old unsynced — keep (not synced)
      await _insertAuditLog(
        createdAt: DateTime.now().subtract(const Duration(days: 2920)),
        syncedAt: null,
      );

      final deleted = await db.auditLogDao.cleanupOldLogs();

      expect(deleted, equals(1), reason: 'Only record #3 should be deleted');
      final remaining = await db.select(db.auditLogTable).get();
      expect(remaining.length, equals(3));
    });
  });
}
