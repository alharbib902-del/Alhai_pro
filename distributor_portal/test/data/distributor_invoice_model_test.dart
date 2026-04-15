import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models.dart';

void main() {
  // ─── Sample JSON matching invoices table schema ──────────────

  final sampleJson = <String, dynamic>{
    'id': 'inv-001',
    'org_id': 'org-1',
    'store_id': 'store-1',
    'invoice_number': 'INV-2026-0001',
    'invoice_type': 'standard_tax',
    'status': 'issued',
    'sale_id': 'order-1',
    'ref_invoice_id': null,
    'ref_reason': null,
    'customer_id': null,
    'customer_name': 'Test Store',
    'customer_phone': null,
    'customer_email': null,
    'customer_vat_number': '300000000000003',
    'customer_address': 'Riyadh',
    'subtotal': 100.0,
    'discount': 0.0,
    'tax_rate': 15.0,
    'tax_amount': 15.0,
    'total': 115.0,
    'payment_method': null,
    'amount_paid': 0.0,
    'amount_due': 115.0,
    'currency': 'SAR',
    'zatca_hash': 'abc123hash',
    'zatca_qr': 'qrdata',
    'zatca_uuid': 'inv-001',
    'pdf_url': null,
    'notes': 'Test invoice',
    'created_by': 'user-1',
    'cashier_name': null,
    'issued_at': '2026-04-16T10:00:00.000Z',
    'due_at': '2026-05-16T10:00:00.000Z',
    'paid_at': null,
    'created_at': '2026-04-16T10:00:00.000Z',
    'updated_at': null,
  };

  group('DistributorInvoice.fromJson', () {
    test('parses all fields correctly', () {
      final inv = DistributorInvoice.fromJson(sampleJson);

      expect(inv.id, 'inv-001');
      expect(inv.orgId, 'org-1');
      expect(inv.storeId, 'store-1');
      expect(inv.invoiceNumber, 'INV-2026-0001');
      expect(inv.invoiceType, 'standard_tax');
      expect(inv.status, 'issued');
      expect(inv.saleId, 'order-1');
      expect(inv.customerName, 'Test Store');
      expect(inv.customerVatNumber, '300000000000003');
      expect(inv.customerAddress, 'Riyadh');
      expect(inv.subtotal, 100.0);
      expect(inv.discount, 0.0);
      expect(inv.taxRate, 15.0);
      expect(inv.taxAmount, 15.0);
      expect(inv.total, 115.0);
      expect(inv.amountPaid, 0.0);
      expect(inv.amountDue, 115.0);
      expect(inv.currency, 'SAR');
      expect(inv.zatcaHash, 'abc123hash');
      expect(inv.zatcaQr, 'qrdata');
      expect(inv.zatcaUuid, 'inv-001');
      expect(inv.notes, 'Test invoice');
      expect(inv.issuedAt, isNotNull);
      expect(inv.dueAt, isNotNull);
      expect(inv.paidAt, isNull);
    });

    test('uses defaults for missing fields', () {
      final minimal = DistributorInvoice.fromJson({
        'id': 'inv-002',
        'created_at': '2026-04-16T10:00:00.000Z',
      });

      expect(minimal.invoiceType, 'standard_tax');
      expect(minimal.status, 'issued');
      expect(minimal.subtotal, 0.0);
      expect(minimal.taxRate, 15.0);
      expect(minimal.currency, 'SAR');
      expect(minimal.storeId, '');
    });

    test('handles null created_at gracefully', () {
      final inv = DistributorInvoice.fromJson({
        'id': 'inv-003',
        'created_at': null,
      });
      // Falls back to DateTime.now()
      expect(inv.createdAt, isNotNull);
    });
  });

  group('DistributorInvoice.toInsertJson', () {
    test('produces valid insert payload', () {
      final inv = DistributorInvoice.fromJson(sampleJson);
      final json = inv.toInsertJson();

      expect(json['id'], 'inv-001');
      expect(json['store_id'], 'store-1');
      expect(json['invoice_number'], 'INV-2026-0001');
      expect(json['invoice_type'], 'standard_tax');
      expect(json['subtotal'], 100.0);
      expect(json['tax_rate'], 15.0);
      expect(json['zatca_hash'], 'abc123hash');
      expect(json['issued_at'], isNotNull);
    });

    test('does not include server-managed created_at or synced_at', () {
      final inv = DistributorInvoice.fromJson(sampleJson);
      final json = inv.toInsertJson();

      expect(json.containsKey('created_at'), isFalse);
      expect(json.containsKey('synced_at'), isFalse);
      expect(json.containsKey('updated_at'), isFalse);
    });

    test('includes org_id', () {
      final inv = DistributorInvoice.fromJson(sampleJson);
      final json = inv.toInsertJson();
      expect(json['org_id'], 'org-1');
    });
  });

  group('DistributorInvoice equality', () {
    test('equal invoices are ==', () {
      final a = DistributorInvoice.fromJson(sampleJson);
      final b = DistributorInvoice.fromJson(sampleJson);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different id means not equal', () {
      final a = DistributorInvoice.fromJson(sampleJson);
      final modifiedJson = Map<String, dynamic>.from(sampleJson)
        ..['id'] = 'inv-999';
      final b = DistributorInvoice.fromJson(modifiedJson);
      expect(a, isNot(equals(b)));
    });

    test('different status means not equal', () {
      final a = DistributorInvoice.fromJson(sampleJson);
      final modifiedJson = Map<String, dynamic>.from(sampleJson)
        ..['status'] = 'paid';
      final b = DistributorInvoice.fromJson(modifiedJson);
      expect(a, isNot(equals(b)));
    });
  });
}
