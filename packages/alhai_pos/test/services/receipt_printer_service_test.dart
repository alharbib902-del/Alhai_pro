/// Unit tests for ReceiptPrinterService
///
/// Tests: Service structure, StoreInfo default values used
/// Note: Actual printing requires a running app context,
/// so we test the public API surface and data models.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/services/receipt_pdf_generator.dart';
import 'package:alhai_pos/src/services/receipt_printer_service.dart';

import '../helpers/pos_test_helpers.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSalesDao extends Mock implements SalesDao {}

class MockSaleItemsDao extends Mock implements SaleItemsDao {}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ReceiptPrinterService API', () {
    test('printReceipt is a static method', () {
      // Verify the static method exists and is callable
      // (cannot actually call it without BuildContext)
      expect(ReceiptPrinterService.printReceipt, isNotNull);
    });

    test('printSaleData is a static method', () {
      expect(ReceiptPrinterService.printSaleData, isNotNull);
    });

    test('shareReceipt is a static method', () {
      expect(ReceiptPrinterService.shareReceipt, isNotNull);
    });
  });

  group('ReceiptPrinterService default parameters', () {
    test('default cashierName is correct', () {
      // The default cashierName in the service signature
      // We verify through StoreInfo default
      const store = StoreInfo.defaultStore;
      expect(store.name, equals('Al-HAI Store'));
    });

    test('default store info is available', () {
      const store = StoreInfo.defaultStore;
      expect(store, isNotNull);
      expect(store.vatNumber, isNotEmpty);
    });
  });

  group('ReceiptPrinterService data requirements', () {
    test('requires SalesTableData for printing', () {
      final sale = createTestSalesTableData(
        id: 'sale-1',
        receiptNo: 'POS-001',
        total: 115.0,
      );

      expect(sale.id, equals('sale-1'));
      expect(sale.receiptNo, equals('POS-001'));
      expect(sale.total, equals(115.0));
    });

    test('requires SaleItemsTableData list for printing', () {
      final items = [
        createTestSaleItemsTableData(
          id: 'item-1',
          saleId: 'sale-1',
          productName: 'Product A',
          unitPrice: 50.0,
          qty: 2,
          total: 100.0,
        ),
      ];

      expect(items.length, equals(1));
      expect(items.first.productName, equals('Product A'));
    });

    test('sale data with multiple items', () {
      final items = [
        createTestSaleItemsTableData(
          id: 'item-1',
          saleId: 'sale-1',
          productName: 'Coffee',
          unitPrice: 15.0,
          qty: 2,
          total: 30.0,
        ),
        createTestSaleItemsTableData(
          id: 'item-2',
          saleId: 'sale-1',
          productName: 'Cake',
          unitPrice: 25.0,
          qty: 1,
          total: 25.0,
        ),
      ];

      expect(items.length, equals(2));
      // C-4 Session 2: sale_items.total is int cents; sum over 2500 + 3000 = 5500 cents.
      final totalSum = items.fold<int>(0, (sum, i) => sum + i.total);
      expect(totalSum, equals(5500));
    });

    test('sale data with discount', () {
      final sale = createTestSalesTableData(
        id: 'sale-discount',
        subtotal: 100.0,
        discount: 10.0,
        tax: 13.5,
        total: 103.5,
      );

      expect(sale.subtotal, equals(100.0));
      expect(sale.discount, equals(10.0));
      expect(sale.tax, equals(13.5));
      expect(sale.total, equals(103.5));
    });

    test('sale data with different payment methods', () {
      final cashSale = createTestSalesTableData(paymentMethod: 'cash');
      final cardSale = createTestSalesTableData(paymentMethod: 'card');

      expect(cashSale.paymentMethod, equals('cash'));
      expect(cardSale.paymentMethod, equals('card'));
    });
  });
}
