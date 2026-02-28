import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_invoice_service.dart';

void main() {
  group('AiInvoiceException', () {
    test('creates with message', () {
      final exception = AiInvoiceException('test error');
      expect(exception.message, 'test error');
    });

    test('toString returns message', () {
      final exception = AiInvoiceException('test error');
      expect(exception.toString(), 'test error');
    });
  });

  group('AiInvoiceItem', () {
    test('needsReview is true when confidence < 70', () {
      final item = AiInvoiceItem(
        rawName: 'Test',
        quantity: 10,
        unitPrice: 5.0,
        total: 50.0,
        confidence: 60,
      );

      expect(item.needsReview, isTrue);
    });

    test('needsReview is false when confidence >= 70', () {
      final item = AiInvoiceItem(
        rawName: 'Test',
        quantity: 10,
        unitPrice: 5.0,
        total: 50.0,
        confidence: 70,
      );

      expect(item.needsReview, isFalse);
    });

    test('needsReview is false when confidence is high', () {
      final item = AiInvoiceItem(
        rawName: 'Test',
        quantity: 10,
        unitPrice: 5.0,
        total: 50.0,
        confidence: 95,
      );

      expect(item.needsReview, isFalse);
    });

    test('fromJson creates item correctly', () {
      final json = {
        'raw_name': 'Test Product',
        'quantity': 5,
        'unit_price': 10.0,
        'total': 50.0,
        'confidence': 85,
        'matched_product_id': 'p1',
        'matched_product_name': 'Matched',
        'is_confirmed': true,
      };

      final item = AiInvoiceItem.fromJson(json);

      expect(item.rawName, 'Test Product');
      expect(item.quantity, 5.0);
      expect(item.unitPrice, 10.0);
      expect(item.total, 50.0);
      expect(item.confidence, 85);
      expect(item.matchedProductId, 'p1');
      expect(item.matchedProductName, 'Matched');
      expect(item.isConfirmed, isTrue);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final item = AiInvoiceItem.fromJson(json);

      expect(item.rawName, '');
      expect(item.quantity, 0);
      expect(item.unitPrice, 0);
      expect(item.total, 0);
      expect(item.confidence, 0);
      expect(item.matchedProductId, isNull);
      expect(item.isConfirmed, isFalse);
    });

    test('toJson produces correct map', () {
      final item = AiInvoiceItem(
        rawName: 'Test',
        quantity: 10,
        unitPrice: 5.0,
        total: 50.0,
        confidence: 90,
        matchedProductId: 'p1',
        matchedProductName: 'Match',
        isConfirmed: true,
      );

      final json = item.toJson();

      expect(json['raw_name'], 'Test');
      expect(json['quantity'], 10.0);
      expect(json['unit_price'], 5.0);
      expect(json['total'], 50.0);
      expect(json['confidence'], 90);
      expect(json['matched_product_id'], 'p1');
      expect(json['matched_product_name'], 'Match');
      expect(json['is_confirmed'], true);
    });

    test('toJson and fromJson are round-trip compatible', () {
      final original = AiInvoiceItem(
        rawName: 'Round Trip Test',
        quantity: 7,
        unitPrice: 12.5,
        total: 87.5,
        confidence: 80,
        matchedProductId: 'p2',
        matchedProductName: 'Matched Product',
        isConfirmed: false,
      );

      final json = original.toJson();
      final restored = AiInvoiceItem.fromJson(json);

      expect(restored.rawName, original.rawName);
      expect(restored.quantity, original.quantity);
      expect(restored.unitPrice, original.unitPrice);
      expect(restored.total, original.total);
      expect(restored.confidence, original.confidence);
      expect(restored.matchedProductId, original.matchedProductId);
    });
  });

  group('AiInvoiceResult', () {
    test('fromJson creates result correctly', () {
      final json = {
        'supplier_name': 'Test Supplier',
        'invoice_number': 'INV-001',
        'invoice_date': '2024-01-15T00:00:00.000',
        'total_amount': 1000.0,
        'tax_amount': 150.0,
        'items': [
          {
            'raw_name': 'Item 1',
            'quantity': 10,
            'unit_price': 100.0,
            'total': 1000.0,
            'confidence': 90,
          },
        ],
      };

      final result = AiInvoiceResult.fromJson(json);

      expect(result.supplierName, 'Test Supplier');
      expect(result.invoiceNumber, 'INV-001');
      expect(result.invoiceDate, isNotNull);
      expect(result.totalAmount, 1000.0);
      expect(result.taxAmount, 150.0);
      expect(result.items.length, 1);
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{
        'total_amount': 500,
        'tax_amount': 75,
      };

      final result = AiInvoiceResult.fromJson(json);

      expect(result.supplierName, isNull);
      expect(result.invoiceNumber, isNull);
      expect(result.invoiceDate, isNull);
      expect(result.totalAmount, 500.0);
      expect(result.taxAmount, 75.0);
      expect(result.items, isEmpty);
    });

    test('toJson produces correct map', () {
      final result = AiInvoiceResult(
        supplierName: 'Supplier',
        invoiceNumber: 'INV-002',
        invoiceDate: DateTime(2024, 6, 15),
        totalAmount: 2000.0,
        taxAmount: 300.0,
        items: [
          AiInvoiceItem(
            rawName: 'Product',
            quantity: 5,
            unitPrice: 400.0,
            total: 2000.0,
            confidence: 95,
          ),
        ],
      );

      final json = result.toJson();

      expect(json['supplier_name'], 'Supplier');
      expect(json['invoice_number'], 'INV-002');
      expect(json['total_amount'], 2000.0);
      expect(json['tax_amount'], 300.0);
      expect(json['items'], isNotEmpty);
    });

    test('toJson and fromJson are round-trip compatible', () {
      final original = AiInvoiceResult(
        supplierName: 'Round Trip Supplier',
        invoiceNumber: 'INV-RT-001',
        invoiceDate: DateTime(2024, 3, 20),
        totalAmount: 5000.0,
        taxAmount: 750.0,
        items: [
          AiInvoiceItem(
            rawName: 'Item A',
            quantity: 10,
            unitPrice: 250.0,
            total: 2500.0,
            confidence: 88,
          ),
          AiInvoiceItem(
            rawName: 'Item B',
            quantity: 5,
            unitPrice: 500.0,
            total: 2500.0,
            confidence: 92,
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
    });
  });
}
