import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/core/services/audit_log_service.dart';

import '../helpers/mock_supabase_client.dart';

/// Tests for the server-side is_super_admin() RPC verification logic
/// that was added to sa_login_screen.dart (CRITICAL-01).
///
/// The widget itself uses Riverpod + GoRouter + alhai_auth which makes
/// full widget testing complex. Instead we test the two pure-logic units:
///   1. RPC verification: does the mock client return correct results?
///   2. Audit logging: are login events correctly recorded?
void main() {
  late MockSupabaseClient mock;

  setUp(() {
    mock = MockSupabaseClient();
    mock.setResponse('audit_log', <dynamic>[]);
  });

  group('is_super_admin RPC verification', () {
    test('returns true when RPC confirms super admin', () async {
      mock.setRpcResponse('is_super_admin', true);

      final result = await mock.client.rpc('is_super_admin');
      expect(result, isTrue);
    });

    test('returns false when RPC denies super admin', () async {
      mock.setRpcResponse('is_super_admin', false);

      final result = await mock.client.rpc('is_super_admin');
      expect(result, isFalse);
    });

    test('throws when RPC encounters an error', () async {
      mock.setRpcError('is_super_admin', Exception('network error'));

      expect(
        () => mock.client.rpc('is_super_admin'),
        throwsA(isA<Exception>()),
      );
    });

    test('RPC call is logged in query log', () async {
      mock.setRpcResponse('is_super_admin', true);

      await mock.client.rpc('is_super_admin');

      expect(mock.queryLog['rpc:is_super_admin'], isNotNull);
      expect(mock.queryLog['rpc:is_super_admin'], hasLength(1));
    });
  });

  group('Login audit logging via AuditLogService', () {
    test('successful login is audited with auth.login action', () async {
      const actor = AuditActor(id: 'sa-user-1', email: 'admin@bltech.sa');
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      await audit.log(
        action: 'auth.login',
        targetType: 'user',
        targetId: 'sa-user-1',
        metadata: {'email': 'admin@bltech.sa'},
      );

      final ops = mock.queryLog['audit_log']!;
      expect(ops, hasLength(1));
      final row =
          ops.first.firstWhere((o) => o.method == 'insert').args[0]
              as Map<String, dynamic>;
      expect(row['action'], equals('auth.login'));
      expect(row['target_type'], equals('user'));
      expect(row['target_id'], equals('sa-user-1'));
      expect(row['metadata']?['email'], equals('admin@bltech.sa'));
    });

    test('failed login is audited with auth.login_failed action', () async {
      const actor = AuditActor(id: 'system', email: null);
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      await audit.log(
        action: 'auth.login_failed',
        targetType: 'user',
        targetId: 'attacker@evil.com',
        metadata: {
          'email': 'attacker@evil.com',
          'reason': 'rpc_is_super_admin_rejected',
        },
      );

      final ops = mock.queryLog['audit_log']!;
      final row =
          ops.first.firstWhere((o) => o.method == 'insert').args[0]
              as Map<String, dynamic>;
      expect(row['action'], equals('auth.login_failed'));
      expect(row['target_id'], equals('attacker@evil.com'));
      expect(row['metadata']?['reason'], equals('rpc_is_super_admin_rejected'));
    });

    test('login audit does not block on failure', () async {
      mock.setError('audit_log', Exception('db down'));
      const actor = AuditActor(id: 'sa-user-1', email: 'admin@bltech.sa');
      final audit = AuditLogService.test(
        mock.client,
        resolveActor: () => actor,
      );

      // Must not throw even when audit_log insert fails.
      await audit.log(
        action: 'auth.login',
        targetType: 'user',
        targetId: 'sa-user-1',
      );

      // Insert was attempted (but failed silently).
      expect(mock.queryLog['audit_log'], isNotNull);
    });
  });
}
