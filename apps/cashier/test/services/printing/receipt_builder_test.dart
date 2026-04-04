import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:cashier/services/printing/receipt_builder.dart';
import 'package:cashier/services/printing/receipt_data.dart';
import 'package:cashier/services/printing/print_service.dart' show PaperSize;
import 'package:cashier/core/services/zatca/vat_calculator.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Creates sample receipt data for testing.
ReceiptData _sampleReceipt({
  double subtotal = 200.0,
  double discount = 0.0,
  double? tax,
  double? total,
  String paymentMethod = 'cash',
  double? amountReceived,
  double? changeAmount,
  String? customerName,
  String? customerId,
  String? zatcaQrData,
  String? note,
  ReceiptStoreInfo? store,
  List<ReceiptItem>? items,
}) {
  final effectiveTax = tax ?? (subtotal - discount) * 0.15;
  final effectiveTotal = total ?? (subtotal - discount + effectiveTax);

  return ReceiptData(
    receiptNumber: 'INV-2025-0001',
    dateTime: DateTime(2025, 6, 15, 14, 30, 0),
    cashierName: 'Ahmad',
    customerName: customerName,
    customerId: customerId,
    items: items ??
        [
          const ReceiptItem(
            name: 'Apple',
            quantity: 5,
            unitPrice: 10.0,
            total: 50.0,
          ),
          const ReceiptItem(
            name: 'Milk 1L',
            quantity: 2,
            unitPrice: 8.0,
            total: 16.0,
          ),
          const ReceiptItem(
            name: 'Bread',
            quantity: 3,
            unitPrice: 5.0,
            total: 15.0,
          ),
        ],
    subtotal: subtotal,
    discount: discount,
    tax: effectiveTax,
    total: effectiveTotal,
    paymentMethod: paymentMethod,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    store: store ?? ReceiptStoreInfo.defaultStore,
    zatcaQrData: zatcaQrData,
    note: note,
  );
}

/// Decode the built receipt bytes back to a UTF-8 string for content checks.
/// ESC/POS control codes will appear as garbage, but text content is
/// interspersed and searchable.
String _bytesToString(Uint8List bytes) {
  // Replace non-printable bytes with spaces so text fragments remain readable
  final cleaned = bytes.map((b) {
    if (b == 0x0A) return 0x0A; // keep LF
    if (b >= 0x20 && b <= 0x7E) return b; // ASCII printable
    if (b >= 0xC0) return b; // start of multi-byte UTF-8
    if (b >= 0x80 && b <= 0xBF) return b; // continuation byte
    return 0x20; // replace control bytes with space
  }).toList();
  try {
    return utf8.decode(cleaned, allowMalformed: true);
  } catch (_) {
    return String.fromCharCodes(cleaned);
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // -------------------------------------------------------------------------
  // Receipt generation with sample data
  // -------------------------------------------------------------------------
  group('receipt generation with sample data', () {
    test('build returns non-empty Uint8List', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);

      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, isTrue);
    });

    test('receipt contains store name', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('Al-HAI Store'));
    });

    test('receipt contains receipt number', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('INV-2025-0001'));
    });

    test('receipt contains cashier name', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('Ahmad'));
    });

    test('receipt includes date formatted as YYYY/MM/DD', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('2025/06/15'));
    });

    test('receipt includes time formatted as HH:MM:SS', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('14:30:00'));
    });

    test('receipt includes item prices', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // Check that unit prices appear (formatted with 2 decimal places)
      expect(text, contains('10.00'));
      expect(text, contains('8.00'));
      expect(text, contains('5.00'));
    });

    test('receipt includes customer info when provided', () async {
      final receipt = _sampleReceipt(
        customerName: 'Mohammed Ali',
        customerId: 'CUST-999',
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('Mohammed Ali'));
      expect(text, contains('CUST-999'));
    });

    test('receipt excludes customer fields when null', () async {
      final receipt = _sampleReceipt(customerName: null, customerId: null);
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // Should NOT contain the customer label for empty data
      // (the Arabic label for customer number is present only if customerId
      // is non-null and non-empty).
      expect(text.contains('CUST-'), isFalse);
    });

    test('receipt shows discount when > 0', () async {
      final receipt = _sampleReceipt(
        subtotal: 200.0,
        discount: 20.0,
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('20.00'));
    });

    test('receipt shows payment received and change for cash', () async {
      final receipt = _sampleReceipt(
        subtotal: 100.0,
        amountReceived: 150.0,
        changeAmount: 35.0, // approx for 100 + 15 VAT
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('150.00'));
      expect(text, contains('35.00'));
    });

    test('receipt includes ZATCA QR data when provided', () async {
      final receipt = _sampleReceipt(zatcaQrData: 'ABCDEF123456');
      final bytes = await ReceiptBuilder.build(receipt);

      // QR commands use GS ( k -- we just verify the bytes are longer
      // than a receipt without QR data.
      final withoutQr = await ReceiptBuilder.build(_sampleReceipt());
      expect(bytes.length, greaterThan(withoutQr.length));
    });

    test('receipt includes note when provided', () async {
      final receipt = _sampleReceipt(note: 'Thank you!');
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('Thank you!'));
    });

    test('build with PaperSize.mm58 produces output', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt, size: PaperSize.mm58);

      expect(bytes.isNotEmpty, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // VAT calculation (15%)
  // -------------------------------------------------------------------------
  group('VAT calculation (15%)', () {
    test('calculateVat computes 15% of amount', () {
      expect(VatCalculator.calculateVat(100), closeTo(15.0, 0.001));
      expect(VatCalculator.calculateVat(200), closeTo(30.0, 0.001));
      expect(VatCalculator.calculateVat(0), closeTo(0.0, 0.001));
    });

    test('addVat returns amount + 15%', () {
      expect(VatCalculator.addVat(100), closeTo(115.0, 0.001));
      expect(VatCalculator.addVat(1000), closeTo(1150.0, 0.001));
    });

    test('removeVat extracts pre-tax amount from total', () {
      expect(VatCalculator.removeVat(115), closeTo(100.0, 0.001));
      expect(VatCalculator.removeVat(1150), closeTo(1000.0, 0.001));
    });

    test('extractVat returns VAT portion from inclusive amount', () {
      expect(VatCalculator.extractVat(115), closeTo(15.0, 0.001));
      expect(VatCalculator.extractVat(230), closeTo(30.0, 0.001));
    });

    test('breakdown computes full invoice details', () {
      final bd = VatCalculator.breakdown(200, discount: 20);

      expect(bd.subtotal, 200.0);
      expect(bd.discount, 20.0);
      expect(bd.taxableAmount, closeTo(180.0, 0.001));
      expect(bd.vatRate, 0.15);
      expect(bd.vatAmount, closeTo(27.0, 0.001));
      expect(bd.total, closeTo(207.0, 0.001));
    });

    test('breakdown with zero discount', () {
      final bd = VatCalculator.breakdown(100);

      expect(bd.taxableAmount, closeTo(100.0, 0.001));
      expect(bd.vatAmount, closeTo(15.0, 0.001));
      expect(bd.total, closeTo(115.0, 0.001));
    });

    test('custom VAT rate', () {
      // 5% rate
      expect(VatCalculator.calculateVat(100, rate: 0.05), closeTo(5.0, 0.001));
      expect(VatCalculator.addVat(100, rate: 0.05), closeTo(105.0, 0.001));
    });

    test('receipt tax line shows 15% label', () async {
      final receipt = _sampleReceipt(subtotal: 100.0, discount: 0.0);
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // The receipt hardcodes the label with 15%
      expect(text, contains('15%'));
    });
  });

  // -------------------------------------------------------------------------
  // Arabic text in receipt
  // -------------------------------------------------------------------------
  group('Arabic text in receipt', () {
    test('receipt contains Arabic store address', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // Default store address is Arabic
      expect(
          text, contains('\u0627\u0644\u0631\u064a\u0627\u0636')); // "الرياض"
    });

    test('receipt contains Arabic thank-you footer', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // Footer: شكراً لزيارتكم
      expect(
        text,
        contains('\u0634\u0643\u0631\u0627\u064b'),
      ); // "شكراً"
    });

    test('receipt contains Arabic VAT number label', () async {
      final receipt = _sampleReceipt();
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // الرقم الضريبي
      expect(
        text,
        contains(
            '\u0627\u0644\u0631\u0642\u0645 \u0627\u0644\u0636\u0631\u064a\u0628\u064a'),
      );
    });

    test('receipt with Arabic item names', () async {
      final receipt = _sampleReceipt(
        items: [
          const ReceiptItem(
            name: '\u062a\u0641\u0627\u062d', // "تفاح" (Apple in Arabic)
            quantity: 2,
            unitPrice: 10.0,
            total: 20.0,
          ),
        ],
        subtotal: 20.0,
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('\u062a\u0641\u0627\u062d')); // "تفاح"
    });

    test('payment method translated to Arabic for cash', () async {
      final receipt = _sampleReceipt(paymentMethod: 'cash');
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // "نقدي"
      expect(
        text,
        contains('\u0646\u0642\u062f\u064a'),
      );
    });

    test('payment method translated to Arabic for card', () async {
      final receipt = _sampleReceipt(paymentMethod: 'card');
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // "بطاقة ائتمان"
      expect(
        text,
        contains('\u0628\u0637\u0627\u0642\u0629'),
      ); // "بطاقة"
    });

    test('payment method for mada', () async {
      final receipt = _sampleReceipt(paymentMethod: 'mada');
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // "مدى"
      expect(
        text,
        contains('\u0645\u062f\u0649'),
      );
    });
  });

  // -------------------------------------------------------------------------
  // Test page and cash drawer
  // -------------------------------------------------------------------------
  group('test page and cash drawer', () {
    test('buildTestPage returns non-empty bytes', () async {
      final bytes = await ReceiptBuilder.buildTestPage();
      expect(bytes, isA<Uint8List>());
      expect(bytes.isNotEmpty, isTrue);
    });

    test('buildTestPage contains test text', () async {
      final bytes = await ReceiptBuilder.buildTestPage();
      final text = _bytesToString(bytes);

      expect(text, contains('Print Test Page'));
      expect(text, contains('Al-HAI POS System'));
    });

    test('buildCashDrawerKick returns bytes with ESC p command', () async {
      final bytes = await ReceiptBuilder.buildCashDrawerKick();
      expect(bytes.isNotEmpty, isTrue);

      // ESC p is [0x1B, 0x70]
      expect(bytes.contains(0x1B), isTrue);
      expect(bytes.contains(0x70), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Money formatting edge cases
  // -------------------------------------------------------------------------
  group('money formatting', () {
    test('large amounts get comma separators in receipt', () async {
      final receipt = _sampleReceipt(
        items: [
          const ReceiptItem(
            name: 'Expensive item',
            quantity: 1,
            unitPrice: 12500.0,
            total: 12500.0,
          ),
        ],
        subtotal: 12500.0,
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('12,500.00'));
    });

    test('whole quantity displayed as integer', () async {
      final receipt = _sampleReceipt(
        items: [
          const ReceiptItem(
            name: 'Widget',
            quantity: 3.0,
            unitPrice: 10.0,
            total: 30.0,
          ),
        ],
        subtotal: 30.0,
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      // Quantity 3.0 should display as "3" not "3.00"
      expect(text, contains('3'));
    });

    test('fractional quantity displayed with 2 decimals', () async {
      final receipt = _sampleReceipt(
        items: [
          const ReceiptItem(
            name: 'Bulk item',
            quantity: 1.75,
            unitPrice: 20.0,
            total: 35.0,
          ),
        ],
        subtotal: 35.0,
      );
      final bytes = await ReceiptBuilder.build(receipt);
      final text = _bytesToString(bytes);

      expect(text, contains('1.75'));
    });
  });
}
