import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/core/services/audit_log_service.dart';

import '../../helpers/mock_supabase_client.dart';

void main() {
  late MockSupabaseClient mock;
  late AuditLogService service;

  const actor = AuditActor(id: 'actor-1', email: 'root@alhai.dev');

  setUp(() {
    mock = MockSupabaseClient();
    service = AuditLogService(mock.client, resolveActor: () => actor);
    // Insert terminates when awaited — just provide an empty response.
    mock.setResponse('audit_log', <dynamic>[]);
  });

  group('AuditLogService.log', () {
    test('inserts a row with actor id + email and required fields', () async {
      await service.log(
        action: 'store.create',
        targetType: 'store',
        targetId: 'store-42',
      );

      final ops = mock.queryLog['audit_log'];
      expect(ops, isNotNull, reason: 'expected an audit_log insert');
      expect(ops!, hasLength(1));

      final insertOp = ops.first.firstWhere((op) => op.method == 'insert');
      final row = insertOp.args[0] as Map<String, dynamic>;
      expect(row['actor_id'], equals('actor-1'));
      expect(row['actor_email'], equals('root@alhai.dev'));
      expect(row['action'], equals('store.create'));
      expect(row['target_type'], equals('store'));
      expect(row['target_id'], equals('store-42'));
      // Optional fields should be absent when not provided.
      expect(row.containsKey('before'), isFalse);
      expect(row.containsKey('after'), isFalse);
      expect(row.containsKey('metadata'), isFalse);
    });

    test('forwards before/after/metadata snapshots into the row', () async {
      await service.log(
        action: 'store.update',
        targetType: 'store',
        targetId: 'store-42',
        before: {'name': 'Old'},
        after: {'name': 'New'},
        metadata: {'reason': 'rename'},
      );

      final ops = mock.queryLog['audit_log']!;
      final insertOp = ops.first.firstWhere((op) => op.method == 'insert');
      final row = insertOp.args[0] as Map<String, dynamic>;
      expect(row['before'], equals({'name': 'Old'}));
      expect(row['after'], equals({'name': 'New'}));
      expect(row['metadata'], equals({'reason': 'rename'}));
    });

    test('omits actor_email when the actor has none', () async {
      final svc = AuditLogService(
        mock.client,
        resolveActor: () => const AuditActor(id: 'actor-2'),
      );

      await svc.log(
        action: 'user.suspend',
        targetType: 'user',
        targetId: 'u-1',
      );

      final ops = mock.queryLog['audit_log']!;
      final insertOp = ops.first.firstWhere((op) => op.method == 'insert');
      final row = insertOp.args[0] as Map<String, dynamic>;
      expect(row['actor_id'], equals('actor-2'));
      expect(row.containsKey('actor_email'), isFalse);
    });

    test(
      'swallows backend errors so the parent mutation is unaffected',
      () async {
        mock.setError('audit_log', Exception('network down'));

        // Must not throw.
        await service.log(
          action: 'subscription.update',
          targetType: 'subscription',
          targetId: 'sub-9',
        );

        // The insert was still attempted.
        expect(mock.queryLog['audit_log'], isNotNull);
      },
    );

    test('does not insert when there is no current actor', () async {
      final svc = AuditLogService(mock.client, resolveActor: () => null);

      await svc.log(
        action: 'store.delete',
        targetType: 'store',
        targetId: 'store-99',
      );

      expect(
        mock.queryLog['audit_log'],
        isNull,
        reason: 'with no actor, we should not attempt the insert',
      );
    });
  });
}
