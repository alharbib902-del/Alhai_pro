import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';

void main() {
  group('ZatcaInvoice', () {
    late ZatcaSeller seller;
    late ZatcaInvoiceLine line1;
    late ZatcaInvoiceLine line2;
    late ZatcaInvoice invoice;

    setUp(() {
      seller = ZatcaSeller(
        name: 'Test Store',
        vatNumber: '310122393500003',
        streetName: 'King Fahd Road',
        buildingNumber: '1234',
        city: 'Riyadh',
        postalCode: '12345',
      );

      line1 = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Product A',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      line2 = ZatcaInvoiceLine(
        lineId: '2',
        itemName: 'Product B',
        quantity: 1,
        unitPrice: 50.0,
        vatRate: 15.0,
        discountAmount: 10.0,
      );

      invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: '550e8400-e29b-41d4-a716-446655440000',
        issueDate: DateTime(2026, 4, 1),
        issueTime: DateTime(2026, 4, 1, 14, 30, 0),
        typeCode: InvoiceTypeCode.standard,
        subType: InvoiceSubType.simplifiedB2C,
        seller: seller,
        lines: [line1, line2],
      );
    });

    test('should compute totalLineNetAmount correctly', () {
      // line1: 100 * 2 = 200, line2: 50 * 1 - 10 = 40
      expect(invoice.totalLineNetAmount, 240.0);
    });

    test('should compute totalVatAmount correctly', () {
      // line1 VAT: 200 * 0.15 = 30, line2 VAT: 40 * 0.15 = 6
      expect(invoice.totalVatAmount, 36.0);
    });

    test('should compute totalWithVat correctly', () {
      // 240 + 36 = 276
      expect(invoice.totalWithVat, 276.0);
    });

    test('isSimplified should return true for B2C subType', () {
      expect(invoice.isSimplified, isTrue);
    });

    test('isStandard should return true for B2B subType', () {
      final b2bInvoice = invoice.copyWith(subType: InvoiceSubType.standardB2B);
      expect(b2bInvoice.isStandard, isTrue);
      expect(b2bInvoice.isSimplified, isFalse);
    });

    test('default reportingStatus should be pending', () {
      expect(invoice.reportingStatus, ReportingStatus.pending);
    });

    test('resolvedIcv returns invoiceCounterValue when set', () {
      final withIcv = invoice.copyWith(invoiceCounterValue: 42);
      expect(withIcv.resolvedIcv, '42');
    });

    test('resolvedIcv extracts digits from invoiceNumber as fallback', () {
      // invoiceNumber is 'INV-001' -> digits '001'
      expect(invoice.resolvedIcv, '001');
    });

    test('resolvedIcv handles invoice number with year prefix', () {
      final inv = invoice.copyWith(invoiceNumber: 'INV-2026-00001');
      expect(inv.resolvedIcv, '202600001');
    });

    test('resolvedIcv returns "1" for non-numeric invoice number', () {
      final inv = invoice.copyWith(invoiceNumber: 'DRAFT');
      expect(inv.resolvedIcv, '1');
    });

    test('copyWith should create a modified copy', () {
      final updated = invoice.copyWith(
        invoiceNumber: 'INV-002',
        reportingStatus: ReportingStatus.reported,
      );
      expect(updated.invoiceNumber, 'INV-002');
      expect(updated.reportingStatus, ReportingStatus.reported);
      expect(updated.uuid, invoice.uuid); // unchanged
    });
  });

  group('ZatcaInvoiceLine', () {
    test('should compute lineNetAmount correctly', () {
      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Test',
        quantity: 3,
        unitPrice: 100.0,
        vatRate: 15.0,
        discountAmount: 50.0,
      );
      expect(line.lineNetAmount, 250.0); // 300 - 50
    });

    test('should compute vatAmount correctly', () {
      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Test',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );
      expect(line.vatAmount, 15.0);
    });

    test('should serialize to and from JSON', () {
      final line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Test Product',
        quantity: 2,
        unitPrice: 99.99,
        vatRate: 15.0,
        barcode: '1234567890',
      );
      final json = line.toJson();
      final restored = ZatcaInvoiceLine.fromJson(json);
      expect(restored.lineId, line.lineId);
      expect(restored.itemName, line.itemName);
      expect(restored.quantity, line.quantity);
      expect(restored.unitPrice, line.unitPrice);
      expect(restored.barcode, line.barcode);
    });
  });

  group('ZatcaSeller', () {
    test('isVatValid should validate correctly', () {
      final validSeller = ZatcaSeller(
        name: 'Test',
        vatNumber: '310122393500003',
        streetName: 'Street',
        buildingNumber: '1234',
        city: 'Riyadh',
        postalCode: '12345',
      );
      expect(validSeller.isVatValid, isTrue);

      final invalidSeller = validSeller.copyWith(vatNumber: '1234');
      expect(invalidSeller.isVatValid, isFalse);
    });

    test('should serialize to and from JSON', () {
      final seller = ZatcaSeller(
        name: 'My Store',
        vatNumber: '310122393500003',
        streetName: 'King Fahd Road',
        buildingNumber: '1234',
        city: 'Riyadh',
        district: 'Al Olaya',
        postalCode: '12345',
      );
      final json = seller.toJson();
      final restored = ZatcaSeller.fromJson(json);
      expect(restored.name, seller.name);
      expect(restored.vatNumber, seller.vatNumber);
      expect(restored.district, seller.district);
    });
  });

  group('InvoiceTypeCode', () {
    test('fromCode should parse valid codes', () {
      expect(InvoiceTypeCode.fromCode('388'), InvoiceTypeCode.standard);
      expect(InvoiceTypeCode.fromCode('381'), InvoiceTypeCode.creditNote);
      expect(InvoiceTypeCode.fromCode('383'), InvoiceTypeCode.debitNote);
    });

    test('fromCode should throw for invalid code', () {
      expect(() => InvoiceTypeCode.fromCode('999'), throwsArgumentError);
    });
  });

  group('ReportingStatus', () {
    test('isSuccess should be true for reported and cleared', () {
      expect(ReportingStatus.reported.isSuccess, isTrue);
      expect(ReportingStatus.cleared.isSuccess, isTrue);
      expect(ReportingStatus.rejected.isSuccess, isFalse);
    });

    test('needsRetry should be true for failed and queued', () {
      expect(ReportingStatus.failed.needsRetry, isTrue);
      expect(ReportingStatus.queued.needsRetry, isTrue);
      expect(ReportingStatus.reported.needsRetry, isFalse);
    });
  });
}
