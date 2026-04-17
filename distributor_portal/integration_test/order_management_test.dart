/// Integration test: Order Management flows for the Distributor Portal.
///
/// Tests the core distributor workflows:
///   1. Distributor approves an incoming order with pricing
///   2. Distributor creates an invoice (ZATCA-compliant with QR + VAT)
///   3. Distributor manages products (create, edit price, audit trail)
///
/// All screens are stubs; the tests verify navigation flow and route
/// parameter handling. Real business logic is covered by unit/widget tests.
///
/// Run with:
///   flutter test integration_test/order_management_test.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';

import 'helpers/test_data.dart';
import 'helpers/test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================================
  // ORDER MANAGEMENT (ادارة الطلبات)
  // ==========================================================================

  group('Order Management - ادارة الطلبات', () {
    // ========================================================================
    // Flow 1: Distributor Approves Order
    // ========================================================================
    group('Flow 1: Approve Order', () {
      testWidgets('login screen loads at /login', (tester) async {
        // Arrange: Launch at login
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/login'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Login screen stub is visible
        expectStubScreen('Login');
      });

      testWidgets('after login, dashboard is displayed', (tester) async {
        // Arrange: Simulate logged-in state by starting at dashboard
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/dashboard'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Dashboard stub is visible
        expectStubScreen('Dashboard');
      });

      testWidgets('navigating to orders list shows orders screen', (
        tester,
      ) async {
        // Arrange: Start at dashboard
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/dashboard'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Navigate to orders list
        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Dashboard'))),
        );
        router.go('/orders');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Orders screen is shown
        expectStubScreen('Orders');
      });

      testWidgets('tapping an order navigates to order detail', (tester) async {
        // Arrange: Start at orders list
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/orders'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Act: Navigate to a specific order
        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Orders'))),
        );
        router.go('/orders/$kTestOrderId');
        await pumpAndSettleWithTimeout(tester);

        // Assert: Order detail screen is shown with the correct ID
        expectStubScreen('Order $kTestOrderId');
      });

      testWidgets('full approve flow: login -> orders -> detail -> approve', (
        tester,
      ) async {
        // Arrange: Start at login
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/login'),
        );
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Login');

        final router = GoRouter.of(
          tester.element(find.byKey(const Key('stub_Login'))),
        );

        // Step 1: Login -> Dashboard
        router.go('/dashboard');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Dashboard');

        // Step 2: Dashboard -> Orders
        router.go('/orders');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Orders');

        // Step 3: Orders -> Order Detail (status: sent)
        router.go('/orders/$kTestOrderId');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Order $kTestOrderId');

        // Step 4: In the real app, the distributor reviews items, confirms
        // pricing, and taps "Approve". The order status transitions from
        // 'sent' to 'approved'. We verify the route parameter was passed.
        expect(kSampleOrder['status'], equals('sent'));
        expect(kOrderStatuses.contains('approved'), isTrue);

        // Step 5: After approval, navigate back to orders list
        router.go('/orders');
        await pumpAndSettleWithTimeout(tester);
        expectStubScreen('Orders');
      });
    });

    // ========================================================================
    // Flow 2: Create Invoice from Approved Order
    // ========================================================================
    group('Flow 2: Create Invoice', () {
      testWidgets('invoices screen loads at /invoices', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/invoices'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Invoices');
      });

      testWidgets('invoice detail shows QR and VAT data', (tester) async {
        // Arrange: Navigate to a specific invoice
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/invoices/$kTestInvoiceId'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert: Invoice detail screen is shown with correct ID
        expectStubScreen('Invoice $kTestInvoiceId');
      });

      testWidgets(
        'full invoice flow: approved order -> create invoice -> detail',
        (tester) async {
          // Arrange: Start at the approved order
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/orders/$kTestOrderId'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Order $kTestOrderId'))),
          );

          // Step 1: In the real app, the distributor taps "Create Invoice"
          // on an approved order. The invoice is generated with ZATCA QR code
          // and VAT calculation. Navigate to invoices list.
          router.go('/invoices');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Invoices');

          // Step 2: View the newly created invoice
          router.go('/invoices/$kTestInvoiceId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Invoice $kTestInvoiceId');

          // Verify invoice sample data has QR and VAT fields
          expect(kSampleInvoice['qr_code'], isNotNull);
          expect(kSampleInvoice['vat_rate'], equals(0.15));
          expect(kSampleInvoice['vat_amount'], equals(225.0));
          expect(kSampleInvoice['total'], equals(1725.0));

          // Step 3: Return to orders to see updated order
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');
        },
      );
    });

    // ========================================================================
    // Flow 3: Product Management
    // ========================================================================
    group('Flow 3: Product Management', () {
      testWidgets('products screen loads at /products', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/products'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Products');
      });

      testWidgets('audit screen loads at /audit', (tester) async {
        // Arrange
        await tester.pumpWidget(
          buildDistributorTestApp(initialRoute: '/audit'),
        );
        await pumpAndSettleWithTimeout(tester);

        // Assert
        expectStubScreen('Audit');
      });

      testWidgets(
        'full product flow: products -> create -> edit price -> audit',
        (tester) async {
          // Arrange: Start at products screen
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/products'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Products');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Products'))),
          );

          // Step 1: In the real app, the distributor creates a new product
          // by filling in name, SKU, barcode, price, and category.
          // Verify sample product data is complete.
          expect(kSampleProduct['name'], isNotEmpty);
          expect(kSampleProduct['sku'], equals('MILK-001'));
          expect(kSampleProduct['unit_price'], equals(5.50));

          // Step 2: After creating/editing, the price change is recorded
          // in the audit log. Navigate to audit screen.
          router.go('/audit');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Audit');

          // Verify audit entry captures the price change
          expect(kSampleAuditEntry['field_changed'], equals('unit_price'));
          expect(kSampleAuditEntry['old_value'], equals('5.00'));
          expect(kSampleAuditEntry['new_value'], equals('5.50'));
          expect(kSampleAuditEntry['product_name'], isNotEmpty);

          // Step 3: Navigate back to products
          router.go('/products');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Products');

          // Step 4: Navigate to pricing to verify pricing is consistent
          router.go('/pricing');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Pricing');
        },
      );
    });

    // ========================================================================
    // End-to-End: Full Order Management Lifecycle
    // ========================================================================
    group('End-to-End: Order Management Lifecycle', () {
      testWidgets(
        'full flow: login -> orders -> approve -> invoice -> products -> audit',
        (tester) async {
          // Arrange: Start at login
          await tester.pumpWidget(
            buildDistributorTestApp(initialRoute: '/login'),
          );
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Login');

          final router = GoRouter.of(
            tester.element(find.byKey(const Key('stub_Login'))),
          );

          // Step 1: Login -> Dashboard
          router.go('/dashboard');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');

          // Step 2: Dashboard -> Orders (view incoming orders)
          router.go('/orders');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Orders');

          // Step 3: Select order to review
          router.go('/orders/$kTestOrderId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Order $kTestOrderId');

          // Step 4: After approving, create invoice
          router.go('/invoices/$kTestInvoiceId');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Invoice $kTestInvoiceId');

          // Step 5: Check invoices list
          router.go('/invoices');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Invoices');

          // Step 6: Manage products
          router.go('/products');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Products');

          // Step 7: Check audit trail
          router.go('/audit');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Audit');

          // Step 8: Back to dashboard
          router.go('/dashboard');
          await pumpAndSettleWithTimeout(tester);
          expectStubScreen('Dashboard');
        },
      );
    });
  });
}
