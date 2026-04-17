import 'package:alhai_database/src/constants/retention_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RetentionPolicy — Saudi Legal Compliance', () {
    test('audit log retention is at least 6 years (2190 days)', () {
      expect(
        RetentionPolicy.auditLogRetention.inDays,
        greaterThanOrEqualTo(2190),
        reason: 'Saudi VAT Law Article 66 requires 6+ years retention',
      );
    });

    test('sales retention is at least 6 years', () {
      expect(RetentionPolicy.salesRetention.inDays, greaterThanOrEqualTo(2190));
    });

    test('shifts retention is at least 6 years', () {
      expect(
        RetentionPolicy.shiftsRetention.inDays,
        greaterThanOrEqualTo(2190),
      );
    });

    test('ZATCA XML retention is at least 6 years', () {
      expect(
        RetentionPolicy.zatcaXmlRetention.inDays,
        greaterThanOrEqualTo(2190),
      );
    });

    test('cannot delete audit log younger than 6 years', () {
      final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 1825));
      expect(
        RetentionPolicy.canDeleteAuditLog(fiveYearsAgo),
        isFalse,
        reason: '5-year-old audit log must NOT be deletable',
      );
    });

    test('can delete audit log older than 6 years', () {
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));
      expect(RetentionPolicy.canDeleteAuditLog(sevenYearsAgo), isTrue);
    });

    test('cannot delete sale younger than 6 years', () {
      final fiveYearsAgo = DateTime.now().subtract(const Duration(days: 1825));
      expect(RetentionPolicy.canDeleteSale(fiveYearsAgo), isFalse);
    });

    test('can delete sale older than 6 years', () {
      final sevenYearsAgo = DateTime.now().subtract(const Duration(days: 2555));
      expect(RetentionPolicy.canDeleteSale(sevenYearsAgo), isTrue);
    });

    test('sync queue retention is 30 days (non-legal record)', () {
      expect(RetentionPolicy.syncQueueRetention.inDays, equals(30));
    });
  });

  group('AuditLogDao.cleanupOldLogs — retention guard', () {
    test('default parameter uses 6-year retention', () {
      // The default value is RetentionPolicy.auditLogRetention which is
      // 2190 days.  This test verifies the constant itself.
      expect(RetentionPolicy.auditLogRetention.inDays, equals(2190));
    });
  });
}
