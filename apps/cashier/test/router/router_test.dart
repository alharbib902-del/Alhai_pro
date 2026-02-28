/// Cashier Router Tests
///
/// Verifies that the GoRouter configuration for the Cashier app
/// is correctly defined with all expected routes.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppRoutes;

void main() {
  group('Cashier Router - Configuration', () {
    test('initial location is splash screen', () {
      expect(AppRoutes.splash, equals('/splash'));
    });
  });

  group('Cashier Router - Route Definitions', () {
    test('AppRoutes defines splash route', () {
      expect(AppRoutes.splash, equals('/splash'));
    });

    test('AppRoutes defines login route', () {
      expect(AppRoutes.login, equals('/login'));
    });

    test('AppRoutes defines store-select route', () {
      expect(AppRoutes.storeSelect, equals('/store-select'));
    });

    test('AppRoutes defines POS route', () {
      expect(AppRoutes.pos, equals('/pos'));
    });

    test('AppRoutes defines payment route', () {
      expect(AppRoutes.posPayment, equals('/pos/payment'));
    });

    test('AppRoutes defines receipt route', () {
      expect(AppRoutes.posReceipt, equals('/pos/receipt'));
    });

    test('AppRoutes defines quick sale route', () {
      expect(AppRoutes.quickSale, equals('/pos/quick-sale'));
    });

    test('AppRoutes defines cash drawer route', () {
      expect(AppRoutes.cashDrawer, equals('/cash-drawer'));
    });

    test('AppRoutes defines returns route', () {
      expect(AppRoutes.returns, equals('/returns'));
    });

    test('AppRoutes defines refund request route', () {
      expect(AppRoutes.refundRequest, equals('/returns/request'));
    });

    test('AppRoutes defines customers route', () {
      expect(AppRoutes.customers, equals('/customers'));
    });

    test('AppRoutes defines customer detail route', () {
      expect(AppRoutes.customerDetail, equals('/customers/:id'));
    });

    test('AppRoutes defines customer ledger route', () {
      expect(AppRoutes.customerLedger, equals('/customers/:id/ledger'));
    });

    test('AppRoutes defines shifts route', () {
      expect(AppRoutes.shifts, equals('/shifts'));
    });

    test('AppRoutes defines shift open route', () {
      expect(AppRoutes.shiftOpen, equals('/shifts/open'));
    });

    test('AppRoutes defines shift close route', () {
      expect(AppRoutes.shiftClose, equals('/shifts/close'));
    });

    test('AppRoutes defines shift summary route', () {
      expect(AppRoutes.shiftSummary, equals('/shifts/summary'));
    });

    test('AppRoutes defines notifications route', () {
      expect(AppRoutes.notificationsCenter, equals('/notifications'));
    });

    test('AppRoutes defines profile route', () {
      expect(AppRoutes.profile, equals('/profile'));
    });
  });

  group('Cashier Router - Route Helpers', () {
    test('customerDetailPath generates correct path', () {
      expect(
        AppRoutes.customerDetailPath('123'),
        equals('/customers/123'),
      );
    });

    test('customerLedgerPath generates correct path', () {
      expect(
        AppRoutes.customerLedgerPath('456'),
        equals('/customers/456/ledger'),
      );
    });

    test('refundReceiptPath generates correct path', () {
      expect(
        AppRoutes.refundReceiptPath('789'),
        equals('/returns/receipt/789'),
      );
    });
  });
}
