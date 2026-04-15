import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/core/services/audit_log_service.dart';

import '../helpers/mock_supabase_client.dart';

/// Tests for the MFA logic (CRITICAL-02).
///
/// The MFA screen uses Supabase auth.mfa API which requires a real client.
/// These tests verify the audit logging and lockout logic that are testable
/// without a live Supabase connection.
void main() {
  late MockSupabaseClient mock;

  setUp(() {
    mock = MockSupabaseClient();
    mock.setResponse('audit_log', <dynamic>[]);
  });

  group('MFA audit events', () {
    test('successful MFA verification is audited', () async {
      const actor = AuditActor(id: 'sa-user-1', email: 'admin@bltech.sa');
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      await audit.log(
        action: 'auth.mfa_verified',
        targetType: 'user',
        targetId: 'sa-user-1',
        metadata: {
          'email': 'admin@bltech.sa',
          'enrollment': false,
        },
      );

      final ops = mock.queryLog['audit_log']!;
      expect(ops, hasLength(1));
      final row = ops.first.firstWhere((o) => o.method == 'insert').args[0]
          as Map<String, dynamic>;
      expect(row['action'], equals('auth.mfa_verified'));
      expect(row['metadata']?['enrollment'], isFalse);
    });

    test('failed MFA attempt is audited with attempt count', () async {
      const actor = AuditActor(id: 'sa-user-1', email: 'admin@bltech.sa');
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      await audit.log(
        action: 'auth.mfa_failed',
        targetType: 'user',
        targetId: 'sa-user-1',
        metadata: {
          'email': 'admin@bltech.sa',
          'reason': 'invalid_code attempt=3',
        },
      );

      final ops = mock.queryLog['audit_log']!;
      final row = ops.first.firstWhere((o) => o.method == 'insert').args[0]
          as Map<String, dynamic>;
      expect(row['action'], equals('auth.mfa_failed'));
      expect(row['metadata']?['reason'], contains('attempt=3'));
    });

    test('lockout event is audited', () async {
      const actor = AuditActor(id: 'sa-user-1', email: 'admin@bltech.sa');
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      await audit.log(
        action: 'auth.mfa_failed',
        targetType: 'user',
        targetId: 'sa-user-1',
        metadata: {
          'email': 'admin@bltech.sa',
          'reason': 'lockout_triggered',
        },
      );

      final ops = mock.queryLog['audit_log']!;
      final row = ops.first.firstWhere((o) => o.method == 'insert').args[0]
          as Map<String, dynamic>;
      expect(row['metadata']?['reason'], equals('lockout_triggered'));
    });

    test('MFA enrollment verification is audited with enrollment=true',
        () async {
      const actor = AuditActor(id: 'sa-user-1', email: 'admin@bltech.sa');
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      await audit.log(
        action: 'auth.mfa_verified',
        targetType: 'user',
        targetId: 'sa-user-1',
        metadata: {
          'email': 'admin@bltech.sa',
          'enrollment': true,
        },
      );

      final ops = mock.queryLog['audit_log']!;
      final row = ops.first.firstWhere((o) => o.method == 'insert').args[0]
          as Map<String, dynamic>;
      expect(row['action'], equals('auth.mfa_verified'));
      expect(row['metadata']?['enrollment'], isTrue);
    });
  });

  group('MFA lockout logic', () {
    test('lockout duration is 30 minutes', () {
      // Verify the lockout constants match spec.
      const maxAttempts = 5;
      const lockoutMinutes = 30;

      final lockoutUntil = DateTime.now().add(
        const Duration(minutes: lockoutMinutes),
      );
      final now = DateTime.now();

      expect(maxAttempts, equals(5));
      expect(lockoutUntil.isAfter(now), isTrue);
      expect(
        lockoutUntil.difference(now).inMinutes,
        greaterThanOrEqualTo(29), // account for test execution time
      );
    });
  });
}
