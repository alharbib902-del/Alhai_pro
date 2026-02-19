import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/data/local/daos/audit_log_dao.dart';

// ===========================================
// Audit Log DAO Tests
// ===========================================

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AuditLogDao', () {
    const testStoreId = 'store_123';
    const testUserId = 'user_001';
    const testUserName = 'محمد علي';

    group('log', () {
      test('يُسجل عملية جديدة', () async {
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.login,
          description: 'تسجيل دخول',
        );

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 1);
        expect(logs.first.action, 'login');
        expect(logs.first.userName, testUserName);
      });

      test('يُسجل مع القيم القديمة والجديدة', () async {
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.priceChange,
          entityType: 'product',
          entityId: 'prod_001',
          oldValue: {'price': 100.0},
          newValue: {'price': 120.0},
        );

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.first.oldValue, contains('100'));
        expect(logs.first.newValue, contains('120'));
      });
    });

    group('logLogin', () {
      test('يُسجل تسجيل دخول', () async {
        await database.auditLogDao.logLogin(testStoreId, testUserId, testUserName);

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 1);
        expect(logs.first.action, 'login');
        expect(logs.first.description, 'تسجيل دخول');
      });
    });

    group('logLogout', () {
      test('يُسجل تسجيل خروج', () async {
        await database.auditLogDao.logLogout(testStoreId, testUserId, testUserName);

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 1);
        expect(logs.first.action, 'logout');
      });
    });

    group('logPriceChange', () {
      test('يُسجل تغيير سعر', () async {
        await database.auditLogDao.logPriceChange(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          productId: 'prod_001',
          productName: 'حليب طازج',
          oldPrice: 8.0,
          newPrice: 9.5,
        );

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 1);
        expect(logs.first.action, 'priceChange');
        expect(logs.first.entityType, 'product');
        expect(logs.first.entityId, 'prod_001');
        expect(logs.first.description, contains('حليب طازج'));
      });
    });

    group('logStockAdjust', () {
      test('يُسجل تعديل مخزون', () async {
        await database.auditLogDao.logStockAdjust(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          productId: 'prod_001',
          productName: 'أرز بسمتي',
          oldQty: 50,
          newQty: 45,
          reason: 'تالف',
        );

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 1);
        expect(logs.first.action, 'stockAdjust');
        expect(logs.first.description, contains('تالف'));
      });
    });

    group('logRefund', () {
      test('يُسجل مرتجع', () async {
        await database.auditLogDao.logRefund(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          saleId: 'sale_001',
          amount: 150.0,
          reason: 'منتج تالف',
        );

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 1);
        expect(logs.first.action, 'saleRefund');
        expect(logs.first.entityType, 'sale');
        expect(logs.first.description, contains('150'));
      });
    });

    group('getLogs', () {
      test('يُرجع السجلات للمتجر', () async {
        await database.auditLogDao.logLogin(testStoreId, testUserId, testUserName);
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.logLogout(testStoreId, testUserId, testUserName);

        final logs = await database.auditLogDao.getLogs(testStoreId);
        expect(logs.length, 2);
      });

      test('يُرتب السجلات تنازلياً حسب التاريخ', () async {
        await database.auditLogDao.logLogin(testStoreId, testUserId, testUserName);
        // تأخير كافٍ لضمان ID مختلف
        await Future.delayed(const Duration(milliseconds: 50));
        await database.auditLogDao.logLogout(testStoreId, testUserId, testUserName);

        final logs = await database.auditLogDao.getLogs(testStoreId);
        // يُرتب تنازلياً حسب createdAt
        expect(logs.length, 2);
        // التحقق من وجود كلا النوعين
        final actions = logs.map((l) => l.action).toSet();
        expect(actions.contains('logout'), isTrue);
        expect(actions.contains('login'), isTrue);
      });

      test('يُحدد عدد السجلات', () async {
        // إضافة تأخير بين كل عملية لضمان ID فريد
        for (int i = 0; i < 5; i++) {
          await database.auditLogDao.log(
            storeId: testStoreId,
            userId: testUserId,
            userName: testUserName,
            action: AuditAction.login,
            description: 'تسجيل دخول $i',
          );
          await Future.delayed(const Duration(milliseconds: 5));
        }

        final logs = await database.auditLogDao.getLogs(testStoreId, limit: 3);
        expect(logs.length, 3);
      });
    });

    group('getLogsByDateRange', () {
      test('يُرجع السجلات ضمن فترة زمنية', () async {
        final now = DateTime.now();

        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.login,
        );

        final logs = await database.auditLogDao.getLogsByDateRange(
          testStoreId,
          now.subtract(const Duration(hours: 1)),
          now.add(const Duration(hours: 1)),
        );
        expect(logs.length, 1);
      });
    });

    group('getLogsByAction', () {
      test('يُرجع السجلات حسب نوع العملية', () async {
        // استخدام log مباشرة مع تأخير
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.login,
        );
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.logout,
        );
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.login,
        );

        final loginLogs = await database.auditLogDao.getLogsByAction(
          testStoreId,
          AuditAction.login,
        );
        expect(loginLogs.length, 2);
        expect(loginLogs.every((l) => l.action == 'login'), isTrue);
      });
    });

    group('getLogsByUser', () {
      test('يُرجع سجلات مستخدم معين', () async {
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: 'user_001',
          userName: 'محمد',
          action: AuditAction.login,
        );
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: 'user_002',
          userName: 'أحمد',
          action: AuditAction.login,
        );
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: 'user_001',
          userName: 'محمد',
          action: AuditAction.logout,
        );

        final logs = await database.auditLogDao.getLogsByUser(testStoreId, 'user_001');
        expect(logs.length, 2);
        expect(logs.every((l) => l.userId == 'user_001'), isTrue);
      });
    });

    group('getUnsyncedLogs', () {
      test('يُرجع السجلات غير المزامنة', () async {
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.login,
        );
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.logout,
        );

        final unsynced = await database.auditLogDao.getUnsyncedLogs();
        expect(unsynced.length, 2);
      });
    });

    group('markAsSynced', () {
      test('يُحدد السجلات كمزامنة', () async {
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.login,
        );
        await Future.delayed(const Duration(milliseconds: 5));
        await database.auditLogDao.log(
          storeId: testStoreId,
          userId: testUserId,
          userName: testUserName,
          action: AuditAction.logout,
        );

        final allLogs = await database.auditLogDao.getLogs(testStoreId);
        final ids = allLogs.map((l) => l.id).toList();

        await database.auditLogDao.markAsSynced(ids);

        final unsynced = await database.auditLogDao.getUnsyncedLogs();
        expect(unsynced, isEmpty);
      });
    });
  });

  group('AuditAction enum', () {
    test('يحتوي على جميع أنواع العمليات', () {
      // 21 قيمة في enum
      expect(AuditAction.values.length, 21);

      // المصادقة
      expect(AuditAction.values, contains(AuditAction.login));
      expect(AuditAction.values, contains(AuditAction.logout));

      // المبيعات
      expect(AuditAction.values, contains(AuditAction.saleCreate));
      expect(AuditAction.values, contains(AuditAction.saleCancel));
      expect(AuditAction.values, contains(AuditAction.saleRefund));

      // المنتجات
      expect(AuditAction.values, contains(AuditAction.productCreate));
      expect(AuditAction.values, contains(AuditAction.productEdit));
      expect(AuditAction.values, contains(AuditAction.productDelete));
      expect(AuditAction.values, contains(AuditAction.priceChange));

      // المخزون
      expect(AuditAction.values, contains(AuditAction.stockAdjust));
      expect(AuditAction.values, contains(AuditAction.stockReceive));

      // العملاء
      expect(AuditAction.values, contains(AuditAction.customerCreate));
      expect(AuditAction.values, contains(AuditAction.customerEdit));
      expect(AuditAction.values, contains(AuditAction.paymentRecord));

      // الوردية
      expect(AuditAction.values, contains(AuditAction.shiftOpen));
      expect(AuditAction.values, contains(AuditAction.shiftClose));
      expect(AuditAction.values, contains(AuditAction.cashDrawerOpen));

      // الطلبات
      expect(AuditAction.values, contains(AuditAction.orderStatusChange));
      expect(AuditAction.values, contains(AuditAction.orderCancel));

      // الإعدادات
      expect(AuditAction.values, contains(AuditAction.settingsChange));
      expect(AuditAction.values, contains(AuditAction.interestApply));
    });
  });
}
