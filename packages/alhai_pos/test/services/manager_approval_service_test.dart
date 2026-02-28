import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_pos/src/services/manager_approval_service.dart';

void main() {
  group('ManagerApprovalService', () {
    group('protectedActions', () {
      test('should contain all expected actions', () {
        expect(
          ManagerApprovalService.protectedActions,
          containsAll([
            'delete_product',
            'delete_customer',
            'void_sale',
            'refund',
            'modify_price',
            'apply_discount',
            'discount_over_20',
            'cash_out',
            'close_day',
            'view_reports',
            'export_data',
            'modify_inventory',
          ]),
        );
      });

      test('should have 12 protected actions', () {
        expect(ManagerApprovalService.protectedActions.length, equals(12));
      });
    });

    group('requiresApproval', () {
      test('should return true for protected actions', () {
        expect(
            ManagerApprovalService.requiresApproval('void_sale'), isTrue);
        expect(ManagerApprovalService.requiresApproval('refund'), isTrue);
        expect(
            ManagerApprovalService.requiresApproval('delete_product'), isTrue);
        expect(ManagerApprovalService.requiresApproval('cash_out'), isTrue);
        expect(ManagerApprovalService.requiresApproval('discount_over_20'),
            isTrue);
      });

      test('should return false for non-protected actions', () {
        expect(
            ManagerApprovalService.requiresApproval('view_products'), isFalse);
        expect(ManagerApprovalService.requiresApproval('add_to_cart'), isFalse);
        expect(ManagerApprovalService.requiresApproval(''), isFalse);
        expect(
            ManagerApprovalService.requiresApproval('random_action'), isFalse);
      });
    });

    group('getActionDescription', () {
      test('should return Arabic description for known actions', () {
        expect(
          ManagerApprovalService.getActionDescription('void_sale'),
          isNotEmpty,
        );
        expect(
          ManagerApprovalService.getActionDescription('refund'),
          isNotEmpty,
        );
        expect(
          ManagerApprovalService.getActionDescription('delete_product'),
          isNotEmpty,
        );
      });

      test('should return default description for unknown actions', () {
        final description =
            ManagerApprovalService.getActionDescription('unknown_action');
        expect(description, isNotEmpty);
      });

      test('each protected action has a description', () {
        for (final action in ManagerApprovalService.protectedActions) {
          final description =
              ManagerApprovalService.getActionDescription(action);
          expect(description, isNotEmpty,
              reason: 'Action "$action" should have a description');
        }
      });
    });

    group('getActionName', () {
      test('should return Arabic name for known actions', () {
        expect(
          ManagerApprovalService.getActionName('void_sale'),
          isNotEmpty,
        );
        expect(
          ManagerApprovalService.getActionName('refund'),
          isNotEmpty,
        );
      });

      test('should return the action code for unknown actions', () {
        expect(
          ManagerApprovalService.getActionName('unknown'),
          equals('unknown'),
        );
      });

      test('each protected action has a name', () {
        for (final action in ManagerApprovalService.protectedActions) {
          final name = ManagerApprovalService.getActionName(action);
          expect(name, isNotEmpty,
              reason: 'Action "$action" should have a name');
          // Known actions should not return the raw action code
          expect(name, isNot(equals(action)),
              reason:
                  'Action "$action" name should be Arabic, not the code');
        }
      });

      test('descriptions differ from names', () {
        for (final action in ManagerApprovalService.protectedActions) {
          final name = ManagerApprovalService.getActionName(action);
          final description =
              ManagerApprovalService.getActionDescription(action);
          // Description should generally be longer than name
          expect(description.length >= name.length, isTrue,
              reason:
                  'Description for "$action" should be >= name length');
        }
      });
    });
  });
}
