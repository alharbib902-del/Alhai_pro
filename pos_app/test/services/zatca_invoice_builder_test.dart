import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/zatca/zatca_invoice_builder.dart';

void main() {
  group('ZatcaInvoiceType', () {
    test('has correct codes', () {
      expect(ZatcaInvoiceType.simplified.code, '388');
      expect(ZatcaInvoiceType.standard.code, '380');
      expect(ZatcaInvoiceType.creditNote.code, '381');
      expect(ZatcaInvoiceType.debitNote.code, '383');
    });
  });

  group('ZatcaTransactionType', () {
    test('has correct codes', () {
      expect(ZatcaTransactionType.nominal.code, '0100000');
      expect(ZatcaTransactionType.export.code, '0200000');
      expect(ZatcaTransactionType.internal.code, '0300000');
    });
  });

  group('ZatcaSeller', () {
    test('validates VAT number correctly', () {
      const validSeller = ZatcaSeller(
        name: 'Test Company',
        vatNumber: '300123456789012', // 15 digits, starts with 3
        buildingNumber: '1234',
        streetName: 'Test Street',
        district: 'Test District',
        city: 'Riyadh',
        postalCode: '12345',
      );

      expect(validSeller.isValidVat, true);
    });

    test('rejects invalid VAT number', () {
      const invalidSeller1 = ZatcaSeller(
        name: 'Test',
        vatNumber: '12345', // Too short
        buildingNumber: '1234',
        streetName: 'Test',
        district: 'Test',
        city: 'Riyadh',
        postalCode: '12345',
      );

      const invalidSeller2 = ZatcaSeller(
        name: 'Test',
        vatNumber: '100123456789012', // Doesn't start with 3
        buildingNumber: '1234',
        streetName: 'Test',
        district: 'Test',
        city: 'Riyadh',
        postalCode: '12345',
      );

      expect(invalidSeller1.isValidVat, false);
      expect(invalidSeller2.isValidVat, false);
    });
  });

  group('ZatcaBuyer', () {
    test('isProvided returns true when name is set', () {
      const buyer = ZatcaBuyer(
        name: 'Customer Name',
        vatNumber: '300123456789012',
      );

      expect(buyer.isProvided, true);
    });

    test('isProvided returns false when name is null', () {
      const buyer = ZatcaBuyer();
      expect(buyer.isProvided, false);
    });

    test('isProvided returns false when name is empty', () {
      const buyer = ZatcaBuyer(name: '');
      expect(buyer.isProvided, false);
    });
  });

  group('ZatcaLineItem', () {
    test('calculates line net amount correctly', () {
      const item = ZatcaLineItem(
        id: '1',
        name: 'Test Product',
        quantity: 2,
        unitPrice: 100.0,
        discount: 20.0,
      );

      expect(item.lineNetAmount, 180.0); // (2 * 100) - 20
    });

    test('calculates VAT amount correctly', () {
      const item = ZatcaLineItem(
        id: '1',
        name: 'Test Product',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: 15,
      );

      expect(item.vatAmount, 30.0); // 200 * 15%
    });

    test('calculates line total correctly', () {
      const item = ZatcaLineItem(
        id: '1',
        name: 'Test Product',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: 15,
      );

      expect(item.lineTotal, 230.0); // 200 + 30
    });

    test('handles zero discount', () {
      const item = ZatcaLineItem(
        id: '1',
        name: 'Test',
        quantity: 1,
        unitPrice: 100.0,
      );

      expect(item.lineNetAmount, 100.0);
    });
  });

  group('ZatcaInvoice', () {
    late ZatcaInvoice invoice;

    setUp(() {
      invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime(2024, 1, 15),
        issueTime: DateTime(2024, 1, 15, 10, 30, 0),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test Company',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Test Street',
          district: 'Test District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product A',
            quantity: 2,
            unitPrice: 100.0,
            discount: 10.0,
            vatRate: 15,
          ),
          const ZatcaLineItem(
            id: '2',
            name: 'Product B',
            quantity: 1,
            unitPrice: 50.0,
            vatRate: 15,
          ),
        ],
      );
    });

    test('calculates total discount correctly', () {
      expect(invoice.totalDiscount, 10.0);
    });

    test('calculates taxable amount correctly', () {
      // Item 1: (2 * 100) - 10 = 190
      // Item 2: (1 * 50) - 0 = 50
      // Total: 240
      expect(invoice.taxableAmount, 240.0);
    });

    test('calculates total VAT correctly', () {
      // Item 1: 190 * 15% = 28.5
      // Item 2: 50 * 15% = 7.5
      // Total: 36
      expect(invoice.totalVat, 36.0);
    });

    test('calculates total with VAT correctly', () {
      expect(invoice.totalWithVat, 276.0); // 240 + 36
    });
  });

  group('ZatcaInvoiceBuilder', () {
    group('buildXml', () {
      test('generates valid XML structure', () {
        final invoice = ZatcaInvoice(
          invoiceNumber: 'INV-001',
          uuid: 'test-uuid',
          issueDate: DateTime(2024, 1, 15),
          issueTime: DateTime(2024, 1, 15, 10, 30, 0),
          type: ZatcaInvoiceType.simplified,
          transactionType: ZatcaTransactionType.nominal,
          seller: const ZatcaSeller(
            name: 'Test Company',
            vatNumber: '300123456789012',
            buildingNumber: '1234',
            streetName: 'Test Street',
            district: 'Test District',
            city: 'Riyadh',
            postalCode: '12345',
          ),
          items: [
            const ZatcaLineItem(
              id: '1',
              name: 'Test Product',
              quantity: 1,
              unitPrice: 100.0,
            ),
          ],
        );

        final xml = ZatcaInvoiceBuilder.buildXml(invoice);

        expect(xml, contains('<?xml version="1.0" encoding="UTF-8"?>'));
        expect(xml, contains('<Invoice'));
        expect(xml, contains('urn:oasis:names:specification:ubl:schema:xsd:Invoice-2'));
        expect(xml, contains('<cbc:ID>INV-001</cbc:ID>'));
        expect(xml, contains('<cbc:UUID>test-uuid</cbc:UUID>'));
        expect(xml, contains('<cbc:IssueDate>2024-01-15</cbc:IssueDate>'));
        expect(xml, contains('<cbc:IssueTime>10:30:00</cbc:IssueTime>'));
        expect(xml, contains('<cbc:InvoiceTypeCode name="0100000">388</cbc:InvoiceTypeCode>'));
        expect(xml, contains('Test Company'));
        expect(xml, contains('300123456789012'));
        expect(xml, contains('</Invoice>'));
      });

      test('escapes XML special characters', () {
        final invoice = ZatcaInvoice(
          invoiceNumber: 'INV-001',
          uuid: 'test-uuid',
          issueDate: DateTime.now(),
          issueTime: DateTime.now(),
          type: ZatcaInvoiceType.simplified,
          transactionType: ZatcaTransactionType.nominal,
          seller: const ZatcaSeller(
            name: 'Test & Company <LLC>',
            vatNumber: '300123456789012',
            buildingNumber: '1234',
            streetName: 'Test "Street"',
            district: "Test's District",
            city: 'Riyadh',
            postalCode: '12345',
          ),
          items: [
            const ZatcaLineItem(
              id: '1',
              name: 'Product <with> "special" chars & more',
              quantity: 1,
              unitPrice: 100.0,
            ),
          ],
        );

        final xml = ZatcaInvoiceBuilder.buildXml(invoice);

        expect(xml, contains('Test &amp; Company &lt;LLC&gt;'));
        expect(xml, contains('Test &quot;Street&quot;'));
        expect(xml, contains('Test&apos;s District'));
      });

      test('includes buyer info for standard invoice', () {
        final invoice = ZatcaInvoice(
          invoiceNumber: 'INV-001',
          uuid: 'test-uuid',
          issueDate: DateTime.now(),
          issueTime: DateTime.now(),
          type: ZatcaInvoiceType.standard,
          transactionType: ZatcaTransactionType.nominal,
          seller: const ZatcaSeller(
            name: 'Seller',
            vatNumber: '300123456789012',
            buildingNumber: '1234',
            streetName: 'Street',
            district: 'District',
            city: 'Riyadh',
            postalCode: '12345',
          ),
          buyer: const ZatcaBuyer(
            name: 'Buyer Company',
            vatNumber: '300098765432109',
          ),
          items: [
            const ZatcaLineItem(
              id: '1',
              name: 'Product',
              quantity: 1,
              unitPrice: 100.0,
            ),
          ],
        );

        final xml = ZatcaInvoiceBuilder.buildXml(invoice);

        expect(xml, contains('AccountingCustomerParty'));
        expect(xml, contains('Buyer Company'));
        expect(xml, contains('300098765432109'));
      });
    });

    group('calculateHash', () {
      test('generates SHA-256 hash', () {
        const xml = '<Invoice>Test Content</Invoice>';
        final hash = ZatcaInvoiceBuilder.calculateHash(xml);

        expect(hash, isNotEmpty);
        // Base64 encoded SHA-256 is 44 characters
        expect(hash.length, 44);
      });

      test('different XML produces different hash', () {
        const xml1 = '<Invoice>Content 1</Invoice>';
        const xml2 = '<Invoice>Content 2</Invoice>';

        final hash1 = ZatcaInvoiceBuilder.calculateHash(xml1);
        final hash2 = ZatcaInvoiceBuilder.calculateHash(xml2);

        expect(hash1, isNot(hash2));
      });

      test('same XML produces same hash', () {
        const xml = '<Invoice>Same Content</Invoice>';

        final hash1 = ZatcaInvoiceBuilder.calculateHash(xml);
        final hash2 = ZatcaInvoiceBuilder.calculateHash(xml);

        expect(hash1, hash2);
      });
    });

    group('generateQrData', () {
      test('generates TLV encoded data', () {
        final invoice = ZatcaInvoice(
          invoiceNumber: 'INV-001',
          uuid: 'test-uuid',
          issueDate: DateTime(2024, 1, 15),
          issueTime: DateTime(2024, 1, 15, 10, 30, 0),
          type: ZatcaInvoiceType.simplified,
          transactionType: ZatcaTransactionType.nominal,
          seller: const ZatcaSeller(
            name: 'Test Company',
            vatNumber: '300123456789012',
            buildingNumber: '1234',
            streetName: 'Street',
            district: 'District',
            city: 'Riyadh',
            postalCode: '12345',
          ),
          items: [
            const ZatcaLineItem(
              id: '1',
              name: 'Product',
              quantity: 1,
              unitPrice: 100.0,
              vatRate: 15,
            ),
          ],
        );

        // Use actual hash generated from XML to ensure valid base64
        final xml = ZatcaInvoiceBuilder.buildXml(invoice);
        final hash = ZatcaInvoiceBuilder.calculateHash(xml);
        final qrData = ZatcaInvoiceBuilder.generateQrData(invoice, hash);

        expect(qrData, isNotEmpty);
        // QR data is base64 encoded
        expect(qrData, isA<String>());
      });
    });

    group('generateUuid', () {
      test('generates valid UUID format', () {
        final uuid = ZatcaInvoiceBuilder.generateUuid();

        // UUID format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
        expect(uuid.length, 36);
        expect(uuid[8], '-');
        expect(uuid[13], '-');
        expect(uuid[14], '4'); // Version 4
        expect(uuid[18], '-');
        expect(uuid[23], '-');
      });

      test('generates unique UUIDs', () {
        final uuid1 = ZatcaInvoiceBuilder.generateUuid();
        final uuid2 = ZatcaInvoiceBuilder.generateUuid();

        expect(uuid1, isNot(uuid2));
      });
    });
  });

  group('ZatcaValidator', () {
    test('validates valid invoice', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test Company',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product',
            quantity: 1,
            unitPrice: 100.0,
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, true);
      expect(result.errors, isEmpty);
    });

    test('rejects invalid VAT number', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '12345', // Invalid
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product',
            quantity: 1,
            unitPrice: 100.0,
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, false);
      expect(result.errors, contains(contains('الرقم الضريبي')));
    });

    test('rejects empty seller name', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: '', // Empty
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product',
            quantity: 1,
            unitPrice: 100.0,
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, false);
      expect(result.errors, contains(contains('اسم البائع')));
    });

    test('rejects invoice without items', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [], // Empty
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, false);
      expect(result.errors, contains(contains('بند واحد')));
    });

    test('rejects zero quantity', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product',
            quantity: 0, // Invalid
            unitPrice: 100.0,
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, false);
      expect(result.errors, anyElement(contains('الكمية')));
    });

    test('rejects negative price', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product',
            quantity: 1,
            unitPrice: -100.0, // Invalid
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, false);
      expect(result.errors, anyElement(contains('السعر')));
    });

    test('requires buyer for standard invoice', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.standard, // B2B
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        // No buyer
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Product',
            quantity: 1,
            unitPrice: 100.0,
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      expect(result.isValid, false);
      expect(result.errors, contains(contains('المشتري')));
    });

    test('warns about zero total', () {
      final invoice = ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: 'test-uuid',
        issueDate: DateTime.now(),
        issueTime: DateTime.now(),
        type: ZatcaInvoiceType.simplified,
        transactionType: ZatcaTransactionType.nominal,
        seller: const ZatcaSeller(
          name: 'Test',
          vatNumber: '300123456789012',
          buildingNumber: '1234',
          streetName: 'Street',
          district: 'District',
          city: 'Riyadh',
          postalCode: '12345',
        ),
        items: [
          const ZatcaLineItem(
            id: '1',
            name: 'Free Item',
            quantity: 1,
            unitPrice: 0, // Zero price
          ),
        ],
      );

      final result = ZatcaValidator.validate(invoice);

      // Still valid, but has warning
      expect(result.isValid, true);
      expect(result.warnings, contains(contains('صفر')));
    });
  });
}
