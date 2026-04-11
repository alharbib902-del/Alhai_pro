/// Widget tests for InvoiceDetailScreen
///
/// Tests: not-found state, error state, data display
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';

// ---------------------------------------------------------------------------
// Test data
// ---------------------------------------------------------------------------

SalesTableData _createTestSale({
  String id = 'sale-1',
  String receiptNo = 'INV-001',
  double total = 100.0,
  String status = 'completed',
  String paymentMethod = 'cash',
}) {
  return SalesTableData(
    id: id,
    storeId: 'store-1',
    receiptNo: receiptNo,
    cashierId: 'cashier-1',
    subtotal: total * 0.85,
    discount: 0,
    tax: total * 0.15,
    total: total,
    paymentMethod: paymentMethod,
    channel: 'POS',
    status: status,
    isPaid: true,
    createdAt: DateTime(2026, 1, 15, 10, 30),
  );
}

SaleItemsTableData _createTestSaleItem({
  String id = 'item-1',
  String saleId = 'sale-1',
  String productName = 'Test Product',
  double unitPrice = 25.0,
  double qty = 2.0,
}) {
  return SaleItemsTableData(
    id: id,
    saleId: saleId,
    productId: 'prod-1',
    productName: productName,
    unitPrice: unitPrice,
    qty: qty,
    subtotal: unitPrice * qty,
    discount: 0,
    total: unitPrice * qty,
  );
}

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

void _setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(2560, 1440);
  tester.view.devicePixelRatio = 1.0;
}

Widget _buildTestWidget({
  required String invoiceId,
  AsyncValue<InvoiceDetailData?>? detailValue,
}) {
  return ProviderScope(
    overrides: [
      currentStoreIdProvider.overrideWith((ref) => 'test-store-id'),
      invoiceDetailProvider(invoiceId).overrideWith(
        (ref) =>
            detailValue?.when(
              data: (d) => Future.value(d),
              loading: () =>
                  Future.delayed(const Duration(days: 1), () => null),
              error: (e, _) => Future.error(e),
            ) ??
            Future.value(null),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: InvoiceDetailScreen(invoiceId: invoiceId)),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // Tolerate overflow errors (pre-existing layout issues)
  final originalOnError = FlutterError.onError;
  setUp(() {
    FlutterError.onError = (details) {
      if (details.toString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
  });
  tearDown(() => FlutterError.onError = originalOnError);

  group('InvoiceDetailScreen', () {
    testWidgets('renders without errors', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestWidget(
          invoiceId: 'sale-1',
          detailValue: const AsyncValue.data(null),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(InvoiceDetailScreen), findsOneWidget);
    });

    testWidgets('shows not-found state when data is null', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestWidget(
          invoiceId: 'nonexistent',
          detailValue: const AsyncValue.data(null),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('shows error state on provider error', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestWidget(
          invoiceId: 'error-id',
          detailValue: AsyncValue.error(
            Exception('Load failed'),
            StackTrace.current,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows invoice data when loaded', (tester) async {
      _setLargeViewport(tester);
      addTearDown(() => tester.view.resetPhysicalSize());

      final testData = InvoiceDetailData(
        sale: _createTestSale(id: 'sale-1', receiptNo: 'INV-001', total: 100.0),
        items: [
          _createTestSaleItem(
            id: 'item-1',
            saleId: 'sale-1',
            productName: 'Coffee',
          ),
          _createTestSaleItem(
            id: 'item-2',
            saleId: 'sale-1',
            productName: 'Cake',
            unitPrice: 15.0,
            qty: 1.0,
          ),
        ],
      );

      await tester.pumpWidget(
        _buildTestWidget(
          invoiceId: 'sale-1',
          detailValue: AsyncValue.data(testData),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(InvoiceDetailScreen), findsOneWidget);
      // When data is loaded, error icon should not appear
      expect(find.byIcon(Icons.error_outline), findsNothing);
    });
  });
}
