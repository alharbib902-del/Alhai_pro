import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/ai_invoice_service.dart';

// ===========================================
// AI Invoice Service Tests
// ===========================================

void main() {
  group('AiInvoiceResult', () {
    test('ينشئ نتيجة بالقيم الأساسية', () {
      final result = AiInvoiceResult(
        supplierName: 'شركة الأغذية',
        invoiceNumber: 'INV-001',
        invoiceDate: DateTime(2024, 1, 15),
        totalAmount: 1000.0,
        taxAmount: 150.0,
        items: [],
      );

      expect(result.supplierName, 'شركة الأغذية');
      expect(result.invoiceNumber, 'INV-001');
      expect(result.invoiceDate, DateTime(2024, 1, 15));
      expect(result.totalAmount, 1000.0);
      expect(result.taxAmount, 150.0);
      expect(result.items, isEmpty);
    });

    test('ينشئ نتيجة مع قيم null', () {
      final result = AiInvoiceResult(
        totalAmount: 500.0,
        taxAmount: 75.0,
        items: [],
      );

      expect(result.supplierName, isNull);
      expect(result.invoiceNumber, isNull);
      expect(result.invoiceDate, isNull);
    });

    group('fromJson', () {
      test('يحول JSON كامل بشكل صحيح', () {
        final json = {
          'supplier_name': 'مورد اختبار',
          'invoice_number': 'TEST-123',
          'invoice_date': '2024-02-15T10:30:00.000',
          'total_amount': 2500.0,
          'tax_amount': 375.0,
          'items': [
            {
              'raw_name': 'منتج 1',
              'quantity': 10,
              'unit_price': 25.0,
              'total': 250.0,
              'confidence': 95,
            }
          ],
        };

        final result = AiInvoiceResult.fromJson(json);

        expect(result.supplierName, 'مورد اختبار');
        expect(result.invoiceNumber, 'TEST-123');
        expect(result.totalAmount, 2500.0);
        expect(result.taxAmount, 375.0);
        expect(result.items.length, 1);
        expect(result.items.first.rawName, 'منتج 1');
      });

      test('يتعامل مع القيم المفقودة', () {
        final json = <String, dynamic>{};

        final result = AiInvoiceResult.fromJson(json);

        expect(result.supplierName, isNull);
        expect(result.invoiceNumber, isNull);
        expect(result.invoiceDate, isNull);
        expect(result.totalAmount, 0.0);
        expect(result.taxAmount, 0.0);
        expect(result.items, isEmpty);
      });

      test('يتعامل مع items = null', () {
        final json = {
          'total_amount': 100,
          'tax_amount': 15,
          'items': null,
        };

        final result = AiInvoiceResult.fromJson(json);
        expect(result.items, isEmpty);
      });
    });

    group('toJson', () {
      test('يحول النتيجة إلى JSON', () {
        final result = AiInvoiceResult(
          supplierName: 'اختبار',
          invoiceNumber: 'INV-001',
          invoiceDate: DateTime(2024, 3, 20),
          totalAmount: 1500.0,
          taxAmount: 225.0,
          items: [],
        );

        final json = result.toJson();

        expect(json['supplier_name'], 'اختبار');
        expect(json['invoice_number'], 'INV-001');
        expect(json['total_amount'], 1500.0);
        expect(json['tax_amount'], 225.0);
        expect(json['items'], isEmpty);
      });

      test('يحافظ على تنسيق التاريخ ISO', () {
        final date = DateTime(2024, 5, 15, 14, 30);
        final result = AiInvoiceResult(
          invoiceDate: date,
          totalAmount: 100,
          taxAmount: 15,
          items: [],
        );

        final json = result.toJson();
        expect(json['invoice_date'], contains('2024-05-15'));
      });
    });
  });

  group('AiInvoiceItem', () {
    test('ينشئ عنصر بالقيم الأساسية', () {
      final item = AiInvoiceItem(
        rawName: 'أرز بسمتي',
        quantity: 10,
        unitPrice: 50.0,
        total: 500.0,
        confidence: 95,
      );

      expect(item.rawName, 'أرز بسمتي');
      expect(item.quantity, 10);
      expect(item.unitPrice, 50.0);
      expect(item.total, 500.0);
      expect(item.confidence, 95);
      expect(item.isConfirmed, false);
      expect(item.matchedProductId, isNull);
    });

    test('ينشئ عنصر مع منتج مطابق', () {
      final item = AiInvoiceItem(
        rawName: 'زيت نباتي',
        quantity: 5,
        unitPrice: 30.0,
        total: 150.0,
        confidence: 88,
        matchedProductId: 'prod_123',
        matchedProductName: 'زيت طبخ 2 لتر',
        isConfirmed: true,
      );

      expect(item.matchedProductId, 'prod_123');
      expect(item.matchedProductName, 'زيت طبخ 2 لتر');
      expect(item.isConfirmed, true);
    });

    group('needsReview', () {
      test('يُرجع true عندما الثقة أقل من 70', () {
        final item = AiInvoiceItem(
          rawName: 'منتج',
          quantity: 1,
          unitPrice: 10,
          total: 10,
          confidence: 69,
        );
        expect(item.needsReview, true);
      });

      test('يُرجع true عندما الثقة = 0', () {
        final item = AiInvoiceItem(
          rawName: 'منتج',
          quantity: 1,
          unitPrice: 10,
          total: 10,
          confidence: 0,
        );
        expect(item.needsReview, true);
      });

      test('يُرجع false عندما الثقة = 70', () {
        final item = AiInvoiceItem(
          rawName: 'منتج',
          quantity: 1,
          unitPrice: 10,
          total: 10,
          confidence: 70,
        );
        expect(item.needsReview, false);
      });

      test('يُرجع false عندما الثقة > 70', () {
        final item = AiInvoiceItem(
          rawName: 'منتج',
          quantity: 1,
          unitPrice: 10,
          total: 10,
          confidence: 95,
        );
        expect(item.needsReview, false);
      });
    });

    group('fromJson', () {
      test('يحول JSON كامل', () {
        final json = {
          'raw_name': 'سكر أبيض',
          'quantity': 20,
          'unit_price': 45.5,
          'total': 910.0,
          'confidence': 92,
          'matched_product_id': 'prod_456',
          'matched_product_name': 'سكر 10 كجم',
          'is_confirmed': true,
        };

        final item = AiInvoiceItem.fromJson(json);

        expect(item.rawName, 'سكر أبيض');
        expect(item.quantity, 20);
        expect(item.unitPrice, 45.5);
        expect(item.total, 910.0);
        expect(item.confidence, 92);
        expect(item.matchedProductId, 'prod_456');
        expect(item.matchedProductName, 'سكر 10 كجم');
        expect(item.isConfirmed, true);
      });

      test('يتعامل مع القيم المفقودة', () {
        final json = <String, dynamic>{};

        final item = AiInvoiceItem.fromJson(json);

        expect(item.rawName, '');
        expect(item.quantity, 0);
        expect(item.unitPrice, 0);
        expect(item.total, 0);
        expect(item.confidence, 0);
        expect(item.isConfirmed, false);
      });
    });

    group('toJson', () {
      test('يحول العنصر إلى JSON', () {
        final item = AiInvoiceItem(
          rawName: 'دقيق',
          quantity: 15,
          unitPrice: 65.0,
          total: 975.0,
          confidence: 88,
          matchedProductId: 'prod_789',
          matchedProductName: 'دقيق فاخر',
          isConfirmed: true,
        );

        final json = item.toJson();

        expect(json['raw_name'], 'دقيق');
        expect(json['quantity'], 15);
        expect(json['unit_price'], 65.0);
        expect(json['total'], 975.0);
        expect(json['confidence'], 88);
        expect(json['matched_product_id'], 'prod_789');
        expect(json['matched_product_name'], 'دقيق فاخر');
        expect(json['is_confirmed'], true);
      });
    });

    test('يمكن تعديل matchedProductId', () {
      final item = AiInvoiceItem(
        rawName: 'منتج',
        quantity: 1,
        unitPrice: 10,
        total: 10,
        confidence: 50,
      );

      expect(item.matchedProductId, isNull);

      item.matchedProductId = 'new_prod_id';
      expect(item.matchedProductId, 'new_prod_id');
    });

    test('يمكن تعديل matchedProductName', () {
      final item = AiInvoiceItem(
        rawName: 'منتج',
        quantity: 1,
        unitPrice: 10,
        total: 10,
        confidence: 50,
      );

      expect(item.matchedProductName, isNull);

      item.matchedProductName = 'اسم المنتج المطابق';
      expect(item.matchedProductName, 'اسم المنتج المطابق');
    });

    test('يمكن تعديل isConfirmed', () {
      final item = AiInvoiceItem(
        rawName: 'منتج',
        quantity: 1,
        unitPrice: 10,
        total: 10,
        confidence: 50,
      );

      expect(item.isConfirmed, false);

      item.isConfirmed = true;
      expect(item.isConfirmed, true);
    });
  });

  group('AiInvoiceException', () {
    test('ينشئ استثناء برسالة', () {
      final exception = AiInvoiceException('فشل في الاتصال');
      expect(exception.message, 'فشل في الاتصال');
    });

    test('toString يُرجع الرسالة', () {
      final exception = AiInvoiceException('خطأ في المعالجة');
      expect(exception.toString(), 'خطأ في المعالجة');
    });
  });

  group('AiInvoiceResult مع عناصر', () {
    test('يحسب مجموع العناصر بشكل صحيح', () {
      final result = AiInvoiceResult(
        totalAmount: 2500.0,
        taxAmount: 375.0,
        items: [
          AiInvoiceItem(rawName: 'منتج 1', quantity: 10, unitPrice: 100, total: 1000, confidence: 90),
          AiInvoiceItem(rawName: 'منتج 2', quantity: 5, unitPrice: 200, total: 1000, confidence: 85),
          AiInvoiceItem(rawName: 'منتج 3', quantity: 2, unitPrice: 250, total: 500, confidence: 60),
        ],
      );

      expect(result.items.length, 3);

      final itemsTotal = result.items.fold(0.0, (sum, item) => sum + item.total);
      expect(itemsTotal, 2500.0);
    });

    test('يحدد العناصر التي تحتاج مراجعة', () {
      final result = AiInvoiceResult(
        totalAmount: 2000.0,
        taxAmount: 300.0,
        items: [
          AiInvoiceItem(rawName: 'منتج 1', quantity: 10, unitPrice: 100, total: 1000, confidence: 90),
          AiInvoiceItem(rawName: 'منتج 2', quantity: 5, unitPrice: 100, total: 500, confidence: 50),
          AiInvoiceItem(rawName: 'منتج 3', quantity: 5, unitPrice: 100, total: 500, confidence: 65),
        ],
      );

      final needsReview = result.items.where((i) => i.needsReview).toList();
      expect(needsReview.length, 2);
      expect(needsReview[0].rawName, 'منتج 2');
      expect(needsReview[1].rawName, 'منتج 3');
    });
  });

  group('JSON round-trip', () {
    test('AiInvoiceResult يحافظ على البيانات بعد التحويل', () {
      final original = AiInvoiceResult(
        supplierName: 'مورد اختبار',
        invoiceNumber: 'INV-TEST-001',
        invoiceDate: DateTime(2024, 6, 15),
        totalAmount: 3500.0,
        taxAmount: 525.0,
        items: [
          AiInvoiceItem(
            rawName: 'منتج اختباري',
            quantity: 25,
            unitPrice: 140.0,
            total: 3500.0,
            confidence: 87,
            matchedProductId: 'prod_test',
            isConfirmed: true,
          ),
        ],
      );

      final json = original.toJson();
      final restored = AiInvoiceResult.fromJson(json);

      expect(restored.supplierName, original.supplierName);
      expect(restored.invoiceNumber, original.invoiceNumber);
      expect(restored.totalAmount, original.totalAmount);
      expect(restored.taxAmount, original.taxAmount);
      expect(restored.items.length, original.items.length);
      expect(restored.items.first.rawName, original.items.first.rawName);
      expect(restored.items.first.confidence, original.items.first.confidence);
    });

    test('AiInvoiceItem يحافظ على البيانات بعد التحويل', () {
      final original = AiInvoiceItem(
        rawName: 'عنصر اختبار',
        quantity: 50,
        unitPrice: 75.5,
        total: 3775.0,
        confidence: 92,
        matchedProductId: 'matched_123',
        matchedProductName: 'منتج مطابق',
        isConfirmed: true,
      );

      final json = original.toJson();
      final restored = AiInvoiceItem.fromJson(json);

      expect(restored.rawName, original.rawName);
      expect(restored.quantity, original.quantity);
      expect(restored.unitPrice, original.unitPrice);
      expect(restored.total, original.total);
      expect(restored.confidence, original.confidence);
      expect(restored.matchedProductId, original.matchedProductId);
      expect(restored.matchedProductName, original.matchedProductName);
      expect(restored.isConfirmed, original.isConfirmed);
    });
  });
}
