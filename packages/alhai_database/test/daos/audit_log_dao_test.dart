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

  group('AuditLogDao', () {
    test('log creates audit log entry', () async {
      await db.auditLogDao.log(
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'محمد الكاشير',
        action: AuditAction.login,
        description: 'تسجيل دخول',
      );

      final logs = await db.auditLogDao.getLogs('store-1');
      expect(logs, hasLength(1));
      expect(logs.first.action, 'login');
      expect(logs.first.userName, 'محمد الكاشير');
    });

    test('logLogin creates login entry', () async {
      await db.auditLogDao.logLogin('store-1', 'user-1', 'أحمد');

      final logs = await db.auditLogDao.getLogs('store-1');
      expect(logs, hasLength(1));
      expect(logs.first.action, 'login');
    });

    test('logLogout creates logout entry', () async {
      await db.auditLogDao.logLogout('store-1', 'user-1', 'أحمد');

      final logs = await db.auditLogDao.getLogs('store-1');
      expect(logs.first.action, 'logout');
    });

    test('logPriceChange records old and new values', () async {
      await db.auditLogDao.logPriceChange(
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'المدير',
        productId: 'prod-1',
        productName: 'حليب طازج',
        oldPrice: 5.0,
        newPrice: 6.5,
      );

      final logs = await db.auditLogDao.getLogs('store-1');
      expect(logs, hasLength(1));
      expect(logs.first.action, 'priceChange');
      expect(logs.first.entityType, 'product');
      expect(logs.first.entityId, 'prod-1');
      expect(logs.first.oldValue, contains('5.0'));
      expect(logs.first.newValue, contains('6.5'));
    });

    test('logStockAdjust records inventory change', () async {
      await db.auditLogDao.logStockAdjust(
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'المخزنجي',
        productId: 'prod-1',
        productName: 'عصير',
        oldQty: 100,
        newQty: 80,
        reason: 'تلف',
      );

      final logs = await db.auditLogDao.getLogs('store-1');
      expect(logs.first.action, 'stockAdjust');
    });

    test('getLogs respects limit', () async {
      final actions = AuditAction.values;
      for (var i = 0; i < 10; i++) {
        await db.auditLogDao.log(
          storeId: 'store-1',
          userId: 'user-1',
          userName: 'أحمد',
          action: actions[i % actions.length],
          description: 'سجل $i',
        );
        // Ensure unique timestamp-based IDs
        await Future.delayed(const Duration(milliseconds: 2));
      }

      final logs = await db.auditLogDao.getLogs('store-1', limit: 5);
      expect(logs, hasLength(5));
    });

    test('getLogsByAction filters by action type', () async {
      await db.auditLogDao.logLogin('store-1', 'user-1', 'أحمد');
      await db.auditLogDao.logLogout('store-1', 'user-1', 'أحمد');

      final logins = await db.auditLogDao
          .getLogsByAction('store-1', AuditAction.login);
      expect(logins, hasLength(1));
      expect(logins.first.action, 'login');
    });

    test('getLogsByUser filters by userId', () async {
      await db.auditLogDao.logLogin('store-1', 'user-1', 'أحمد');
      await db.auditLogDao.logLogin('store-1', 'user-2', 'خالد');

      final userLogs =
          await db.auditLogDao.getLogsByUser('store-1', 'user-1');
      expect(userLogs, hasLength(1));
      expect(userLogs.first.userName, 'أحمد');
    });

    test('getUnsyncedLogs returns logs without syncedAt', () async {
      await db.auditLogDao.logLogin('store-1', 'user-1', 'أحمد');
      await db.auditLogDao.logLogout('store-1', 'user-1', 'أحمد');

      final unsynced = await db.auditLogDao.getUnsyncedLogs();
      expect(unsynced, hasLength(2));
    });

    test('markAsSynced sets syncedAt for given ids', () async {
      await db.auditLogDao.logLogin('store-1', 'user-1', 'أحمد');
      final logs = await db.auditLogDao.getLogs('store-1');
      final id = logs.first.id;

      await db.auditLogDao.markAsSynced([id]);

      final unsynced = await db.auditLogDao.getUnsyncedLogs();
      expect(unsynced, isEmpty);
    });
  });
}
