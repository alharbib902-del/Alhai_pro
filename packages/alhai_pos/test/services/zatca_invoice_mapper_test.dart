import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_pos/src/services/invoice_service.dart';
import 'package:alhai_pos/src/services/zatca_invoice_mapper.dart';
import 'package:alhai_zatca/alhai_zatca.dart';

/// Wave 3b-2b: ZatcaInvoiceMapper unit tests.
///
/// These cover the conversion-purity contract: every transformation
/// (cents → SAR, per-tender list, B2C/B2B split, type-code mapping,
/// rate inference) must be reproducible without any DB or network.
/// Failures here indicate mis-mapping that would cause the ZATCA portal
/// to silently reject the invoice or accept it with wrong totals.
void main() {
  group('ZatcaInvoiceMapper', () {
    final fixedNow = DateTime(2026, 4, 25, 14, 30);

    StoresTableData store({
      String id = 'store-1',
      String name = 'Al-Hai Test Store',
      String? taxNumber = '300000000000003',
      String? streetName = 'King Abdullah Road',
      String? buildingNumber = '1234',
      String? city = 'Riyadh',
      String? postalCode = '12345',
      String? district,
      String? plotIdentification,
      String? additionalAddressNumber,
      String? commercialReg,
      String? address,
    }) {
      return StoresTableData(
        id: id,
        name: name,
        taxNumber: taxNumber,
        commercialReg: commercialReg,
        address: address,
        streetName: streetName,
        buildingNumber: buildingNumber,
        plotIdentification: plotIdentification,
        district: district,
        postalCode: postalCode,
        additionalAddressNumber: additionalAddressNumber,
        city: city,
        currency: 'SAR',
        timezone: 'Asia/Riyadh',
        isActive: true,
        createdAt: fixedNow,
      );
    }

    SalesTableData sale({
      String id = 'sale-1',
      String storeId = 'store-1',
      int subtotal = 10000, // 100 SAR
      int discount = 0,
      int tax = 1500, // 15 SAR (15%)
      int total = 11500,
      String paymentMethod = 'cash',
      int? cashAmount,
      int? cardAmount,
      int? creditAmount,
      String? customerName,
      String? customerId,
    }) {
      return SalesTableData(
        id: id,
        receiptNo: 'R-001',
        storeId: storeId,
        cashierId: 'cashier-1',
        customerName: customerName,
        customerId: customerId,
        subtotal: subtotal,
        discount: discount,
        tax: tax,
        total: total,
        paymentMethod: paymentMethod,
        isPaid: true,
        cashAmount: cashAmount,
        cardAmount: cardAmount,
        creditAmount: creditAmount,
        channel: 'POS',
        status: 'completed',
        createdAt: fixedNow,
      );
    }

    SaleItemsTableData item({
      String id = 'item-1',
      String saleId = 'sale-1',
      String productId = 'prod-1',
      String productName = 'Coffee',
      double qty = 1,
      int unitPrice = 10000,
      int subtotal = 10000,
      int total = 10000,
      int discount = 0,
      String? productSku,
      String? productBarcode,
    }) {
      return SaleItemsTableData(
        id: id,
        saleId: saleId,
        productId: productId,
        productName: productName,
        productSku: productSku,
        productBarcode: productBarcode,
        qty: qty,
        unitPrice: unitPrice,
        subtotal: subtotal,
        total: total,
        discount: discount,
      );
    }

    group('fromSale', () {
      test('converts cents to SAR doubles for all money fields', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        // 10000 cents = 100.0 SAR
        expect(invoice.lines.first.unitPrice, 100.0);
        // 1500 cents tax / 10000 cents subtotal = 15%
        expect(invoice.lines.first.vatRate, 15.0);
      });

      test('emits B2C subtype + null buyer when customer VAT is absent', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        expect(invoice.subType, InvoiceSubType.simplifiedB2C);
        expect(invoice.buyer, isNull);
        expect(invoice.isSimplified, isTrue);
      });

      test('emits B2B subtype + buyer when customer VAT is provided', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(customerName: 'Acme Co'),
          items: [item()],
          store: store(),
          invoiceNumber: 'TAX-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.standardTax,
          issuedAt: fixedNow,
          customerVatNumber: '310000000000003',
          customerName: 'Acme Co',
        );

        expect(invoice.subType, InvoiceSubType.standardB2B);
        expect(invoice.isStandard, isTrue);
        expect(invoice.buyer, isNotNull);
        expect(invoice.buyer!.vatNumber, '310000000000003');
        expect(invoice.buyer!.name, 'Acme Co');
      });

      test('maps multi-tender amounts to ZatcaPaymentMeans list', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          // 50 cash + 30 card + 20 credit = 100 SAR + 15 tax
          sale: sale(
            paymentMethod: 'mixed',
            cashAmount: 5000,
            cardAmount: 3000,
            creditAmount: 2000,
            total: 11500,
          ),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        expect(invoice.paymentMeans, isNotNull);
        expect(invoice.paymentMeans!.length, 3);
        // ZATCA codes: 10=cash, 48=card, 30=credit
        expect(invoice.paymentMeans![0].code, '10');
        expect(invoice.paymentMeans![0].amount, 50.0);
        expect(invoice.paymentMeans![1].code, '48');
        expect(invoice.paymentMeans![1].amount, 30.0);
        expect(invoice.paymentMeans![2].code, '30');
        expect(invoice.paymentMeans![2].amount, 20.0);
      });

      test('falls back to legacy single payment-means when no per-tender split', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          // No cashAmount/cardAmount/creditAmount → null paymentMeans list
          sale: sale(paymentMethod: 'card'),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        expect(invoice.paymentMeans, isNull);
        // legacy code: '48' for card
        expect(invoice.paymentMeansCode, '48');
      });

      test('populates ICV from caller, not extracted from invoice number', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-99999',
          invoiceCounterValue: 42,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        // resolvedIcv prefers invoiceCounterValue over digits in number
        expect(invoice.invoiceCounterValue, 42);
        expect(invoice.resolvedIcv, '42');
      });

      test('builds seller from structured-address columns', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(
            streetName: 'King Fahd Road',
            buildingNumber: '7777',
            plotIdentification: 'Block 12',
            district: 'Olaya',
            postalCode: '11564',
            additionalAddressNumber: '0001',
            commercialReg: '1010101010',
          ),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        expect(invoice.seller.name, 'Al-Hai Test Store');
        expect(invoice.seller.vatNumber, '300000000000003');
        expect(invoice.seller.streetName, 'King Fahd Road');
        expect(invoice.seller.buildingNumber, '7777');
        expect(invoice.seller.plotIdentification, 'Block 12');
        expect(invoice.seller.district, 'Olaya');
        expect(invoice.seller.postalCode, '11564');
        expect(invoice.seller.additionalId, '0001');
        expect(invoice.seller.crNumber, '1010101010');
      });

      test('falls back to legacy address when streetName missing', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(
            streetName: null,
            address: 'Riyadh, Saudi Arabia',
          ),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        // streetName is required; falls back to legacy `address` text
        expect(invoice.seller.streetName, 'Riyadh, Saudi Arabia');
      });

      test('infers VAT rate from sale.tax / sale.subtotal (not hardcoded 15%)', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          // 10000 subtotal + 0 tax → 0% rate (e.g. zero-rated zone)
          sale: sale(subtotal: 10000, tax: 0, total: 10000),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        expect(invoice.lines.first.vatRate, 0.0);
      });

      test('uses creditNote type code when called via fromCreditNote', () {
        final invoice = ZatcaInvoiceMapper.fromCreditNote(
          store: store(),
          invoiceNumber: 'CN-2026-00001',
          invoiceCounterValue: 1,
          issuedAt: fixedNow,
          refInvoiceNumber: 'INV-2026-00001',
          reason: 'Customer return',
          subtotalCents: 5000, // 50 SAR
          taxCents: 750, // 7.5 SAR (15%)
        );

        expect(invoice.typeCode, InvoiceTypeCode.creditNote);
        expect(invoice.typeCode.code, '381');
        expect(invoice.billingReferenceId, 'INV-2026-00001');
        expect(invoice.lines.first.unitPrice, 50.0);
        expect(invoice.lines.first.vatRate, 15.0);
      });

      test('credit note mirrors original lines when provided', () {
        final invoice = ZatcaInvoiceMapper.fromCreditNote(
          store: store(),
          invoiceNumber: 'CN-2026-00001',
          invoiceCounterValue: 1,
          issuedAt: fixedNow,
          refInvoiceNumber: 'INV-2026-00001',
          reason: 'Customer return',
          subtotalCents: 5000,
          taxCents: 750,
          originalLines: [
            item(productName: 'Coffee', qty: 1, unitPrice: 5000, total: 5000),
          ],
        );

        expect(invoice.lines.length, 1);
        expect(invoice.lines.first.itemName, 'Coffee');
      });

      test('credit note synthesises a single line when originalLines empty', () {
        final invoice = ZatcaInvoiceMapper.fromCreditNote(
          store: store(),
          invoiceNumber: 'CN-2026-00001',
          invoiceCounterValue: 1,
          issuedAt: fixedNow,
          refInvoiceNumber: 'INV-2026-00001',
          reason: 'Cash refund',
          subtotalCents: 5000,
          taxCents: 750,
        );

        expect(invoice.lines.length, 1);
        expect(invoice.lines.first.itemName, 'Cash refund');
        expect(invoice.lines.first.unitPrice, 50.0);
      });

      test('issue date and time set from caller', () {
        final issued = DateTime(2026, 6, 15, 9, 45, 30);
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: issued,
        );

        expect(invoice.issueDate, issued);
        expect(invoice.issueTime, issued);
      });
    });

    group('fromSale type-code mapping', () {
      test('simplifiedTax → standard (388) + B2C subtype', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(),
          invoiceNumber: 'INV-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.simplifiedTax,
          issuedAt: fixedNow,
        );

        expect(invoice.typeCode, InvoiceTypeCode.standard);
        expect(invoice.subType, InvoiceSubType.simplifiedB2C);
      });

      test('standardTax → standard (388) + B2B subtype', () {
        final invoice = ZatcaInvoiceMapper.fromSale(
          sale: sale(),
          items: [item()],
          store: store(),
          invoiceNumber: 'TAX-2026-00001',
          invoiceCounterValue: 1,
          type: InvoiceType.standardTax,
          issuedAt: fixedNow,
        );

        expect(invoice.typeCode, InvoiceTypeCode.standard);
        expect(invoice.subType, InvoiceSubType.standardB2B);
      });
    });
  });
}
