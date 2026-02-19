import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/audit_trail.dart';

void main() {
  setUp(() {
    AuditTrail.clear();
    AuditTrail.clearContext();
  });

  group('AuditTrail', () {
    group('setUserContext', () {
      test('يعين context المستخدم', () async {
        AuditTrail.setUserContext(userId: 'user1', userName: 'John');

        await AuditTrail.log(eventType: AuditEventType.login);

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.userId, equals('user1'));
        expect(entries.first.userName, equals('John'));
      });
    });

    group('log', () {
      test('يسجل حدث بسيط', () async {
        final id = await AuditTrail.log(
          eventType: AuditEventType.login,
          userId: 'user1',
          userName: 'John',
        );

        expect(id, startsWith('audit_'));

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries, hasLength(1));
        expect(entries.first.eventType, equals(AuditEventType.login));
      });

      test('يسجل البيانات القديمة والجديدة', () async {
        await AuditTrail.log(
          eventType: AuditEventType.update,
          entityType: 'product',
          entityId: 'p1',
          oldData: {'price': 100},
          newData: {'price': 150},
        );

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.oldData?['price'], equals(100));
        expect(entries.first.newData?['price'], equals(150));
      });

      test('يخفي البيانات الحساسة', () async {
        await AuditTrail.log(
          eventType: AuditEventType.passwordChanged,
          oldData: {'password': 'secret123'},
          newData: {'password': 'newsecret'},
        );

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.oldData?['password'], equals('***REDACTED***'));
        expect(entries.first.newData?['password'], equals('***REDACTED***'));
      });
    });

    group('convenience methods', () {
      test('logLogin يعمل', () async {
        await AuditTrail.logLogin(userId: 'u1', userName: 'Test');

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.login));
      });

      test('logLogout يعمل', () async {
        await AuditTrail.logLogout();

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.logout));
      });

      test('logLoginFailed يعمل', () async {
        await AuditTrail.logLoginFailed(
          identifier: 'test@test.com',
          reason: 'Invalid password',
        );

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.loginFailed));
        expect(entries.first.severity, equals(AuditSeverity.critical));
      });

      test('logSaleCreated يعمل', () async {
        await AuditTrail.logSaleCreated(
          saleId: 's1',
          total: 500.0,
          itemCount: 3,
        );

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.saleCreated));
        expect(entries.first.entityId, equals('s1'));
      });

      test('logSaleVoided يعمل', () async {
        await AuditTrail.logSaleVoided(saleId: 's1', reason: 'Customer request');

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.saleVoided));
      });

      test('logStockAdjusted يعمل', () async {
        await AuditTrail.logStockAdjusted(
          productId: 'p1',
          oldQty: 10,
          newQty: 5,
          reason: 'Damaged',
        );

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.stockAdjusted));
        expect(entries.first.changes?['stockQty']['from'], equals(10));
        expect(entries.first.changes?['stockQty']['to'], equals(5));
      });

      test('logSuspiciousActivity يعمل', () async {
        await AuditTrail.logSuspiciousActivity(
          activity: 'Multiple failed login attempts',
          details: {'attempts': 10},
        );

        final entries = AuditTrail.query(const AuditFilter());
        expect(entries.first.eventType, equals(AuditEventType.suspiciousActivity));
        expect(entries.first.severity, equals(AuditSeverity.critical));
      });
    });

    group('query', () {
      test('يفلتر حسب eventType', () async {
        await AuditTrail.logLogin(userId: 'u1', userName: 'User1');
        await AuditTrail.logLogout();
        await AuditTrail.logLogin(userId: 'u2', userName: 'User2');

        final entries = AuditTrail.query(const AuditFilter(
          eventTypes: [AuditEventType.login],
        ));

        expect(entries, hasLength(2));
        expect(entries.every((e) => e.eventType == AuditEventType.login), isTrue);
      });

      test('يفلتر حسب userId', () async {
        await AuditTrail.log(eventType: AuditEventType.login, userId: 'u1');
        await AuditTrail.log(eventType: AuditEventType.login, userId: 'u2');
        await AuditTrail.log(eventType: AuditEventType.login, userId: 'u1');

        final entries = AuditTrail.query(const AuditFilter(userId: 'u1'));

        expect(entries, hasLength(2));
      });

      test('يفلتر حسب التاريخ', () async {
        await AuditTrail.log(eventType: AuditEventType.login);

        final entries = AuditTrail.query(AuditFilter(
          startDate: DateTime.now().subtract(const Duration(hours: 1)),
          endDate: DateTime.now().add(const Duration(hours: 1)),
        ));

        expect(entries, hasLength(1));
      });

      test('يدعم limit و offset', () async {
        for (var i = 0; i < 10; i++) {
          await AuditTrail.log(eventType: AuditEventType.login);
        }

        final entries = AuditTrail.query(const AuditFilter(limit: 3, offset: 2));

        expect(entries, hasLength(3));
      });

      test('يرتب بالتاريخ تنازلياً', () async {
        await AuditTrail.log(eventType: AuditEventType.login, description: 'first');
        await Future.delayed(const Duration(milliseconds: 10));
        await AuditTrail.log(eventType: AuditEventType.login, description: 'second');

        final entries = AuditTrail.query(const AuditFilter());

        expect(entries.first.description, equals('second'));
        expect(entries.last.description, equals('first'));
      });
    });

    group('exportToJson', () {
      test('يصدر JSON صحيح', () async {
        await AuditTrail.logLogin(userId: 'u1', userName: 'Test');

        final json = AuditTrail.exportToJson(null);

        expect(json, contains('login'));
        expect(json, contains('u1'));
      });
    });
  });

  group('AuditEntry', () {
    test('changes يحسب الفرق', () {
      final entry = AuditEntry(
        id: '1',
        eventType: AuditEventType.update,
        severity: AuditSeverity.medium,
        oldData: {'price': 100, 'name': 'Test'},
        newData: {'price': 150, 'name': 'Test'},
      );

      expect(entry.changes, isNotNull);
      expect(entry.changes?['price']['from'], equals(100));
      expect(entry.changes?['price']['to'], equals(150));
      expect(entry.changes?.containsKey('name'), isFalse);
    });

    test('toLogString يعيد تنسيق صحيح', () {
      final entry = AuditEntry(
        id: '1',
        eventType: AuditEventType.saleCreated,
        severity: AuditSeverity.high,
        userName: 'John',
        entityType: 'sale',
        entityId: 's1',
        description: 'Sale created',
      );

      final log = entry.toLogString();

      expect(log, contains('HIGH'));
      expect(log, contains('saleCreated'));
      expect(log, contains('John'));
      expect(log, contains('sale:s1'));
    });
  });

  group('AuditSeverity', () {
    test('يحدد الخطورة الصحيحة للأحداث', () async {
      await AuditTrail.logLogin(userId: 'u1', userName: 'Test');
      await AuditTrail.logSaleCreated(saleId: 's1', total: 100, itemCount: 1);
      await AuditTrail.logLoginFailed(reason: 'test');

      final entries = AuditTrail.query(const AuditFilter());

      expect(entries.firstWhere((e) => e.eventType == AuditEventType.loginFailed).severity,
          equals(AuditSeverity.critical));
      expect(entries.firstWhere((e) => e.eventType == AuditEventType.saleCreated).severity,
          equals(AuditSeverity.high));
    });
  });
}
