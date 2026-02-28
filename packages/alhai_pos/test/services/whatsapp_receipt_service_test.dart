import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:alhai_pos/src/services/whatsapp_receipt_service.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  group('WhatsAppReceiptService', () {
    group('formatReceipt (static)', () {
      test('should format receipt with all fields', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test Store',
          receiptNo: 'POS-20260115-0001',
          date: DateTime(2026, 1, 15, 14, 30),
          items: [
            const ReceiptLineItem(name: 'Product A', quantity: 2, total: 20.0),
            const ReceiptLineItem(name: 'Product B', quantity: 1, total: 15.0),
          ],
          subtotal: 35.0,
          tax: 5.25,
          discount: 0.0,
          total: 40.25,
          paymentMethod: 'cash',
        );

        expect(result, contains('Test Store'));
        expect(result, contains('POS-20260115-0001'));
        expect(result, contains('Product A'));
        expect(result, contains('Product B'));
        expect(result, contains('35.00'));
        expect(result, contains('5.25'));
        expect(result, contains('40.25'));
        expect(result, contains('cash'));
      });

      test('should include item quantities', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test',
          receiptNo: 'R-001',
          date: DateTime(2026, 1, 1),
          items: [
            const ReceiptLineItem(name: 'Item', quantity: 3, total: 30.0),
          ],
          subtotal: 30.0,
          tax: 4.5,
          discount: 0.0,
          total: 34.5,
          paymentMethod: 'card',
        );

        expect(result, contains('3x Item'));
      });

      test('should include discount when > 0', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test',
          receiptNo: 'R-001',
          date: DateTime(2026, 1, 1),
          items: [
            const ReceiptLineItem(name: 'Item', quantity: 1, total: 100.0),
          ],
          subtotal: 100.0,
          tax: 13.5,
          discount: 10.0,
          total: 103.5,
          paymentMethod: 'cash',
        );

        expect(result, contains('-10.00'));
      });

      test('should NOT include discount when 0', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test',
          receiptNo: 'R-001',
          date: DateTime(2026, 1, 1),
          items: [
            const ReceiptLineItem(name: 'Item', quantity: 1, total: 50.0),
          ],
          subtotal: 50.0,
          tax: 7.5,
          discount: 0.0,
          total: 57.5,
          paymentMethod: 'cash',
        );

        // The word "discount" in Arabic should not appear
        expect(result, isNot(contains('-0.00')));
      });

      test('should format total with WhatsApp bold markdown', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test',
          receiptNo: 'R-001',
          date: DateTime(2026, 1, 1),
          items: [
            const ReceiptLineItem(name: 'Item', quantity: 1, total: 100.0),
          ],
          subtotal: 100.0,
          tax: 15.0,
          discount: 0.0,
          total: 115.0,
          paymentMethod: 'cash',
        );

        // WhatsApp bold markdown: *text*
        expect(result, contains('*'));
        expect(result, contains('115.00'));
      });

      test('should use custom tax rate', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test',
          receiptNo: 'R-001',
          date: DateTime(2026, 1, 1),
          items: [
            const ReceiptLineItem(name: 'Item', quantity: 1, total: 100.0),
          ],
          subtotal: 100.0,
          tax: 10.0,
          discount: 0.0,
          total: 110.0,
          paymentMethod: 'cash',
          taxRate: 0.10,
        );

        expect(result, contains('10%'));
      });

      test('should contain dividers', () {
        final result = WhatsAppReceiptService.formatReceipt(
          storeName: 'Test',
          receiptNo: 'R-001',
          date: DateTime(2026, 1, 1),
          items: [
            const ReceiptLineItem(name: 'Item', quantity: 1, total: 10.0),
          ],
          subtotal: 10.0,
          tax: 1.5,
          discount: 0.0,
          total: 11.5,
          paymentMethod: 'cash',
        );

        // Unicode dividers
        expect(result, contains('──────────'));
      });
    });

    group('ReceiptLineItem', () {
      test('should store name, quantity, and total', () {
        const item = ReceiptLineItem(
          name: 'Test Product',
          quantity: 3,
          total: 45.0,
        );

        expect(item.name, equals('Test Product'));
        expect(item.quantity, equals(3));
        expect(item.total, equals(45.0));
      });
    });

    group('WhatsAppReceiptResult', () {
      test('success factory creates success result', () {
        final result =
            WhatsAppReceiptResult.success(messageId: 'msg-123');

        expect(result.isSuccess, isTrue);
        expect(result.messageId, equals('msg-123'));
        expect(result.error, isNull);
      });

      test('error factory creates error result', () {
        final result = WhatsAppReceiptResult.error('Something went wrong');

        expect(result.isSuccess, isFalse);
        expect(result.error, equals('Something went wrong'));
        expect(result.messageId, isNull);
      });
    });
  });
}
