/// اختبارات خدمة إيصالات واتساب - WhatsApp Receipt Service Tests
///
/// اختبارات وحدة نقية لـ formatReceipt (دالة بحتة، لا تحتاج mocks)
///
/// 9 اختبارات تغطي:
/// - يتضمن اسم المتجر ورقم الفاتورة
/// - يعرض جميع الأصناف مع الكميات
/// - يعرض المجموع الفرعي والضريبة والإجمالي
/// - يحذف سطر الخصم عندما يكون صفراً
/// - يعرض الخصم عندما يكون أكبر من صفر
/// - يعرض طريقة الدفع
/// - يتعامل مع قائمة أصناف فارغة
/// - يعرض التاريخ بالتنسيق الصحيح
/// - WhatsAppReceiptResult factory constructors
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/services/whatsapp_receipt_service.dart';

void main() {
  // تهيئة بيانات التاريخ العربية قبل الاختبارات
  setUpAll(() async {
    await initializeDateFormatting('ar', null);
  });

  group('WhatsAppReceiptService', () {
    group('formatReceipt - تنسيق الإيصال', () {
      test('يتضمن اسم المتجر ورقم الفاتورة', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'متجر الاختبار',
          receiptNo: 'POS-20260218-0001',
          date: DateTime(2026, 2, 18, 14, 30),
          items: [
            const ReceiptLineItem(name: 'بيبسي', quantity: 2, total: 14.0),
          ],
          subtotal: 14.0,
          tax: 2.10,
          discount: 0,
          total: 16.10,
          paymentMethod: 'نقدي',
        );

        // Assert
        expect(text, contains('متجر الاختبار'));
        expect(text, contains('POS-20260218-0001'));
      });

      test('يعرض جميع الأصناف مع الكميات', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18),
          items: [
            const ReceiptLineItem(name: 'بيبسي', quantity: 3, total: 21.0),
            const ReceiptLineItem(name: 'شيبس', quantity: 1, total: 5.50),
          ],
          subtotal: 26.50,
          tax: 3.98,
          discount: 0,
          total: 30.48,
          paymentMethod: 'نقدي',
        );

        // Assert
        expect(text, contains('بيبسي'));
        expect(text, contains('شيبس'));
        expect(text, contains('3x'));
        expect(text, contains('21.00'));
        expect(text, contains('5.50'));
      });

      test('يعرض المجموع الفرعي والضريبة والإجمالي', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18),
          items: [
            const ReceiptLineItem(name: 'منتج', quantity: 1, total: 100.0),
          ],
          subtotal: 100.0,
          tax: 15.0,
          discount: 0,
          total: 115.0,
          paymentMethod: 'بطاقة',
        );

        // Assert
        expect(text, contains('100.00'));
        expect(text, contains('15.00'));
        expect(text, contains('115.00'));
        expect(text, contains('المجموع الفرعي'));
        expect(text, contains('الضريبة'));
        expect(text, contains('الإجمالي'));
      });

      test('يحذف سطر الخصم عندما يكون صفراً', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18),
          items: [
            const ReceiptLineItem(name: 'منتج', quantity: 1, total: 50.0),
          ],
          subtotal: 50.0,
          tax: 7.50,
          discount: 0,
          total: 57.50,
          paymentMethod: 'نقدي',
        );

        // Assert
        expect(text, isNot(contains('الخصم')));
      });

      test('يعرض الخصم عندما يكون أكبر من صفر', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18),
          items: [
            const ReceiptLineItem(name: 'منتج', quantity: 1, total: 50.0),
          ],
          subtotal: 50.0,
          tax: 6.75,
          discount: 5.0,
          total: 51.75,
          paymentMethod: 'نقدي',
        );

        // Assert
        expect(text, contains('الخصم'));
        expect(text, contains('5.00'));
      });

      test('يعرض طريقة الدفع', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18),
          items: [
            const ReceiptLineItem(name: 'منتج', quantity: 1, total: 10.0),
          ],
          subtotal: 10.0,
          tax: 1.50,
          discount: 0,
          total: 11.50,
          paymentMethod: 'بطاقة',
        );

        // Assert
        expect(text, contains('طريقة الدفع'));
        expect(text, contains('بطاقة'));
      });

      test('يتعامل مع قائمة أصناف فارغة', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18),
          items: [],
          subtotal: 0,
          tax: 0,
          discount: 0,
          total: 0,
          paymentMethod: 'نقدي',
        );

        // Assert
        expect(text, contains('المتجر'));
        expect(text, contains('0.00'));
      });

      test('يعرض التاريخ بالتنسيق الصحيح', () {
        // Arrange & Act
        final text = WhatsAppReceiptService.formatReceipt(
          storeName: 'المتجر',
          receiptNo: 'POS-001',
          date: DateTime(2026, 2, 18, 14, 30),
          items: [
            const ReceiptLineItem(name: 'منتج', quantity: 1, total: 10.0),
          ],
          subtotal: 10.0,
          tax: 1.50,
          discount: 0,
          total: 11.50,
          paymentMethod: 'نقدي',
        );

        // Assert - التاريخ يجب أن يحتوي على 2026/02/18
        expect(text, contains('2026/02/18'));
        expect(text, contains('التاريخ'));
      });
    });
  });

  // ==========================================================================
  // اختبارات WhatsAppReceiptResult
  // ==========================================================================

  group('WhatsAppReceiptResult - نتيجة إرسال الإيصال', () {
    test('success يكون isSuccess=true مع messageId', () {
      // Arrange & Act
      final result = WhatsAppReceiptResult.success(messageId: 'msg-123');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.messageId, equals('msg-123'));
      expect(result.error, isNull);
    });

    test('success بدون messageId يكون isSuccess=true', () {
      // Arrange & Act
      final result = WhatsAppReceiptResult.success();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.messageId, isNull);
    });

    test('error يكون isSuccess=false مع رسالة خطأ', () {
      // Arrange & Act
      final result = WhatsAppReceiptResult.error('فشل الإرسال');

      // Assert
      expect(result.isSuccess, isFalse);
      expect(result.error, equals('فشل الإرسال'));
      expect(result.messageId, isNull);
    });
  });

  // ==========================================================================
  // اختبارات ReceiptLineItem
  // ==========================================================================

  group('ReceiptLineItem - عنصر الإيصال', () {
    test('ينشئ عنصراً بالبيانات الصحيحة', () {
      // Arrange & Act
      const item = ReceiptLineItem(
        name: 'بيبسي',
        quantity: 3,
        total: 21.0,
      );

      // Assert
      expect(item.name, equals('بيبسي'));
      expect(item.quantity, equals(3));
      expect(item.total, equals(21.0));
    });
  });
}
