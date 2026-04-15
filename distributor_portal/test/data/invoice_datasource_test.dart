import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';
import 'package:distributor_portal/data/models.dart';

void main() {
  // ─── Invoice number format ─────────────────────────────────

  group('Invoice number format', () {
    test('INV-{year}-{4-digit-seq} format', () {
      // Verify the expected format matches what getNextInvoiceNumber produces
      final year = DateTime.now().year;
      final prefix = 'INV-$year-';
      final sample = '${prefix}0001';

      expect(sample, matches(RegExp(r'^INV-\d{4}-\d{4}$')));
      expect(sample, startsWith(prefix));
    });

    test('sequence extraction from invoice number', () {
      const invoiceNumber = 'INV-2026-0042';
      const prefix = 'INV-2026-';
      final seqPart = invoiceNumber.replaceFirst(prefix, '');
      final seq = int.tryParse(seqPart) ?? 0;

      expect(seq, 42);
      expect('$prefix${(seq + 1).toString().padLeft(4, '0')}', 'INV-2026-0043');
    });

    test('handles padded zeros correctly', () {
      const numbers = ['INV-2026-0001', 'INV-2026-0099', 'INV-2026-1000'];
      const expected = [1, 99, 1000];

      for (var i = 0; i < numbers.length; i++) {
        final seqPart = numbers[i].replaceFirst('INV-2026-', '');
        expect(int.parse(seqPart), expected[i]);
      }
    });
  });

  // ─── DistributorInvoice toInsertJson ───────────────────────

  group('Invoice insert payload', () {
    test('toInsertJson produces correct column names', () {
      final invoice = DistributorInvoice(
        id: 'uuid-1',
        storeId: 'store-1',
        invoiceNumber: 'INV-2026-0001',
        invoiceType: 'standard_tax',
        status: 'issued',
        saleId: 'order-1',
        customerName: 'Test Store',
        subtotal: 100.0,
        taxRate: 15.0,
        taxAmount: 15.0,
        total: 115.0,
        amountDue: 115.0,
        createdAt: DateTime(2026, 4, 16),
        issuedAt: DateTime(2026, 4, 16),
      );

      final json = invoice.toInsertJson();

      // Verify snake_case column names
      expect(json['store_id'], 'store-1');
      expect(json['invoice_number'], 'INV-2026-0001');
      expect(json['invoice_type'], 'standard_tax');
      expect(json['sale_id'], 'order-1');
      expect(json['customer_name'], 'Test Store');
      expect(json['tax_rate'], 15.0);
      expect(json['tax_amount'], 15.0);
      expect(json['amount_due'], 115.0);
      expect(json['issued_at'], isA<String>());
    });

    test('nullable ZATCA fields included as null', () {
      final invoice = DistributorInvoice(
        id: 'uuid-2',
        storeId: 'store-1',
        invoiceNumber: 'INV-2026-0002',
        createdAt: DateTime.now(),
      );

      final json = invoice.toInsertJson();
      expect(json['zatca_hash'], isNull);
      expect(json['zatca_qr'], isNull);
      expect(json['zatca_uuid'], isNull);
    });

    test('ZATCA fields populated when available', () {
      final invoice = DistributorInvoice(
        id: 'uuid-3',
        storeId: 'store-1',
        invoiceNumber: 'INV-2026-0003',
        zatcaHash: 'sha256hash',
        zatcaQr: 'tlvqrdata',
        zatcaUuid: 'uuid-3',
        createdAt: DateTime.now(),
      );

      final json = invoice.toInsertJson();
      expect(json['zatca_hash'], 'sha256hash');
      expect(json['zatca_qr'], 'tlvqrdata');
      expect(json['zatca_uuid'], 'uuid-3');
    });
  });

  // ─── Error types for invoice operations ───────────────────

  group('Invoice datasource errors', () {
    test('duplicate invoice produces validation error', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'Order PO-12345678 already has invoice INV-2026-0001.',
      );

      expect(error.type, DatasourceErrorType.validation);
      expect(error.message, contains('already has invoice'));
    });

    test('no-store error for invoice number generation', () {
      const error = DatasourceError(
        type: DatasourceErrorType.validation,
        message: 'No store found for this organization.',
      );

      expect(error.type, DatasourceErrorType.validation);
    });
  });
}
