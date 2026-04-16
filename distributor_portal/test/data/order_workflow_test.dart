import 'package:flutter_test/flutter_test.dart';
import 'package:distributor_portal/data/models/distributor_order.dart';
import 'package:distributor_portal/data/distributor_datasource.dart';

void main() {
  group('Post-approval workflow helpers', () {
    test('isPostApprovalStatus returns true for workflow stages', () {
      expect(isPostApprovalStatus('preparing'), isTrue);
      expect(isPostApprovalStatus('packed'), isTrue);
      expect(isPostApprovalStatus('shipped'), isTrue);
      expect(isPostApprovalStatus('delivered'), isTrue);
    });

    test('isPostApprovalStatus returns false for legacy statuses', () {
      expect(isPostApprovalStatus('draft'), isFalse);
      expect(isPostApprovalStatus('sent'), isFalse);
      expect(isPostApprovalStatus('approved'), isFalse);
      expect(isPostApprovalStatus('rejected'), isFalse);
      expect(isPostApprovalStatus('received'), isFalse);
    });

    test('nextWorkflowStatus returns correct transitions', () {
      expect(nextWorkflowStatus('approved'), 'preparing');
      expect(nextWorkflowStatus('preparing'), 'packed');
      expect(nextWorkflowStatus('packed'), 'shipped');
      expect(nextWorkflowStatus('shipped'), 'delivered');
    });

    test('nextWorkflowStatus returns null for terminal/invalid', () {
      expect(nextWorkflowStatus('delivered'), isNull);
      expect(nextWorkflowStatus('rejected'), isNull);
      expect(nextWorkflowStatus('draft'), isNull);
    });

    test('workflowStatusLabel returns Arabic labels for all statuses', () {
      expect(workflowStatusLabel('approved'), 'مقبول');
      expect(workflowStatusLabel('preparing'), 'قيد التحضير');
      expect(workflowStatusLabel('packed'), 'تم التغليف');
      expect(workflowStatusLabel('shipped'), 'تم الشحن');
      expect(workflowStatusLabel('delivered'), 'تم التسليم');
      expect(workflowStatusLabel('rejected'), 'مرفوض');
    });

    test('workflowStatusLabel returns raw string for unknown status', () {
      expect(workflowStatusLabel('custom_status'), 'custom_status');
    });

    test('orderWorkflowStages contains all expected stages in order', () {
      expect(orderWorkflowStages, [
        'draft',
        'sent',
        'approved',
        'preparing',
        'packed',
        'shipped',
        'delivered',
      ]);
    });
  });

  group('Status transition validation with post-approval workflow', () {
    test('approved can transition to preparing', () {
      expect(validateStatusTransition('approved', 'preparing'), isNull);
    });

    test('approved can still transition to received (legacy)', () {
      expect(validateStatusTransition('approved', 'received'), isNull);
    });

    test('preparing can only transition to packed', () {
      expect(validateStatusTransition('preparing', 'packed'), isNull);
      expect(validateStatusTransition('preparing', 'shipped'), isNotNull);
    });

    test('packed can only transition to shipped', () {
      expect(validateStatusTransition('packed', 'shipped'), isNull);
      expect(validateStatusTransition('packed', 'delivered'), isNotNull);
    });

    test('shipped can only transition to delivered', () {
      expect(validateStatusTransition('shipped', 'delivered'), isNull);
      expect(validateStatusTransition('shipped', 'packed'), isNotNull);
    });

    test('delivered is terminal - no transitions', () {
      expect(validateStatusTransition('delivered', 'shipped'), isNotNull);
      expect(validateStatusTransition('delivered', 'approved'), isNotNull);
    });
  });

  group('DistributorOrder model with new statuses', () {
    test('fromJson handles new workflow statuses', () {
      for (final status in ['preparing', 'packed', 'shipped', 'delivered']) {
        final order = DistributorOrder.fromJson({
          'id': 'test-id-12345678',
          'store_id': 'store-1',
          'total': 100.0,
          'status': status,
          'created_at': '2026-01-01T00:00:00Z',
        });
        expect(order.status, status);
      }
    });

    test('fromJson gracefully handles unknown status', () {
      final order = DistributorOrder.fromJson({
        'id': 'test-id-12345678',
        'store_id': 'store-1',
        'total': 50.0,
        'status': 'some_future_status',
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(order.status, 'some_future_status');
    });
  });
}
