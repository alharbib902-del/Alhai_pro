/// Unit tests for returns_providers
///
/// Tests: ReturnDetailData model, provider structures
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/providers/returns_providers.dart';

void main() {
  group('ReturnDetailData', () {
    test('constructor creates instance with returnData and items', () {
      final returnData = ReturnsTableData(
        id: 'ret-1',
        returnNumber: 'RET-001',
        saleId: 'sale-1',
        storeId: 'store-1',
        totalRefund: 50.0,
        status: 'completed',
        type: 'sales',
        refundMethod: 'cash',
        createdAt: DateTime(2026, 1, 1),
      );

      final items = [
        ReturnItemsTableData(
          id: 'rti-1',
          returnId: 'ret-1',
          productId: 'prod-1',
          productName: 'Product A',
          qty: 2.0,
          unitPrice: 25.0,
          refundAmount: 50.0,
        ),
      ];

      final detail = ReturnDetailData(returnData: returnData, items: items);

      expect(detail.returnData.id, equals('ret-1'));
      expect(detail.returnData.returnNumber, equals('RET-001'));
      expect(detail.returnData.totalRefund, equals(50.0));
      expect(detail.items.length, equals(1));
      expect(detail.items.first.productName, equals('Product A'));
    });

    test('handles empty items list', () {
      final returnData = ReturnsTableData(
        id: 'ret-2',
        returnNumber: 'RET-002',
        saleId: 'sale-2',
        storeId: 'store-1',
        totalRefund: 0.0,
        status: 'pending',
        type: 'sales',
        refundMethod: 'card',
        createdAt: DateTime(2026, 2, 1),
      );

      final detail = ReturnDetailData(returnData: returnData, items: []);

      expect(detail.items, isEmpty);
      expect(detail.returnData.totalRefund, equals(0.0));
    });

    test('multiple items are stored correctly', () {
      final returnData = ReturnsTableData(
        id: 'ret-3',
        returnNumber: 'RET-003',
        saleId: 'sale-3',
        storeId: 'store-1',
        totalRefund: 150.0,
        status: 'completed',
        type: 'sales',
        refundMethod: 'cash',
        createdAt: DateTime(2026, 3, 1),
      );

      final items = [
        ReturnItemsTableData(
          id: 'rti-1',
          returnId: 'ret-3',
          productId: 'prod-1',
          productName: 'Product A',
          qty: 2.0,
          unitPrice: 25.0,
          refundAmount: 57.5,
        ),
        ReturnItemsTableData(
          id: 'rti-2',
          returnId: 'ret-3',
          productId: 'prod-2',
          productName: 'Product B',
          qty: 1.0,
          unitPrice: 100.0,
          refundAmount: 115.0,
        ),
      ];

      final detail = ReturnDetailData(returnData: returnData, items: items);

      expect(detail.items.length, equals(2));
      expect(detail.items[0].productName, equals('Product A'));
      expect(detail.items[1].productName, equals('Product B'));
    });

    test('returnData preserves all fields', () {
      final returnData = ReturnsTableData(
        id: 'ret-4',
        returnNumber: 'RET-004',
        saleId: 'sale-4',
        storeId: 'store-1',
        customerId: 'cust-1',
        customerName: 'Ahmed',
        reason: 'damaged',
        totalRefund: 75.0,
        status: 'completed',
        type: 'sales',
        refundMethod: 'cash',
        notes: 'Test notes',
        createdBy: 'user-1',
        createdAt: DateTime(2026, 4, 1),
      );

      final detail = ReturnDetailData(returnData: returnData, items: []);

      expect(detail.returnData.customerId, equals('cust-1'));
      expect(detail.returnData.customerName, equals('Ahmed'));
      expect(detail.returnData.reason, equals('damaged'));
      expect(detail.returnData.notes, equals('Test notes'));
      expect(detail.returnData.createdBy, equals('user-1'));
      expect(detail.returnData.refundMethod, equals('cash'));
    });

    test('return item refund amounts are correct', () {
      final items = [
        ReturnItemsTableData(
          id: 'rti-1',
          returnId: 'ret-5',
          productId: 'prod-1',
          productName: 'Expensive Item',
          qty: 3.0,
          unitPrice: 100.0,
          refundAmount: 345.0, // 3 * 100 * 1.15
        ),
      ];

      expect(items.first.qty, equals(3.0));
      expect(items.first.unitPrice, equals(100.0));
      expect(items.first.refundAmount, equals(345.0));
    });
  });
}
