import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/zatca_service.dart';

// ===========================================
// ZATCA Service Tests
// ===========================================

void main() {
  group('ZatcaService', () {
    group('generateQrData', () {
      test('يُولّد بيانات QR Code صالحة', () {
        final qrData = ZatcaService.generateQrData(
          sellerName: 'متجر الحي',
          vatNumber: '300000000000003',
          timestamp: DateTime(2024, 1, 15, 10, 30, 0),
          totalWithVat: 115.0,
          vatAmount: 15.0,
        );

        expect(qrData, isNotEmpty);
        expect(qrData, isA<String>());
        // التحقق من أنه Base64 صالح
        expect(() => base64Decode(qrData), returnsNormally);
      });

      test('يحتوي QR Code على جميع البيانات المطلوبة', () {
        final qrData = ZatcaService.generateQrData(
          sellerName: 'Test Store',
          vatNumber: '300000000000003',
          timestamp: DateTime(2024, 1, 15),
          totalWithVat: 100.0,
          vatAmount: 13.04,
        );

        final decoded = base64Decode(qrData);

        // التحقق من وجود 5 tags في البيانات
        // TLV format: [tag][length][value]
        expect(decoded.length, greaterThan(0));

        // التحقق من أن البيانات تبدأ بـ tag 1
        expect(decoded[0], 1);
      });

      test('يُنسق الأرقام العشرية بشكل صحيح', () {
        final qrData = ZatcaService.generateQrData(
          sellerName: 'متجر',
          vatNumber: '300000000000003',
          timestamp: DateTime.now(),
          totalWithVat: 99.999,
          vatAmount: 13.043,
        );

        final decoded = base64Decode(qrData);
        final decodedString = utf8.decode(decoded, allowMalformed: true);

        // الأرقام يجب أن تكون بصيغة .XX
        expect(decodedString, contains('100.00'));
        expect(decodedString, contains('13.04'));
      });
    });

    group('isValidVatNumber', () {
      test('يقبل رقم ضريبي صحيح', () {
        expect(ZatcaService.isValidVatNumber('300000000000003'), isTrue);
        expect(ZatcaService.isValidVatNumber('310123456789012'), isTrue);
        expect(ZatcaService.isValidVatNumber('399999999999999'), isTrue);
      });

      test('يرفض رقم ضريبي قصير', () {
        expect(ZatcaService.isValidVatNumber('30000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('3'), isFalse);
        expect(ZatcaService.isValidVatNumber(''), isFalse);
      });

      test('يرفض رقم ضريبي طويل', () {
        expect(ZatcaService.isValidVatNumber('3000000000000000'), isFalse);
        expect(ZatcaService.isValidVatNumber('30000000000000000000'), isFalse);
      });

      test('يرفض رقم لا يبدأ بـ 3', () {
        expect(ZatcaService.isValidVatNumber('100000000000003'), isFalse);
        expect(ZatcaService.isValidVatNumber('200000000000003'), isFalse);
        expect(ZatcaService.isValidVatNumber('400000000000003'), isFalse);
      });

      test('يرفض رقم يحتوي على أحرف', () {
        expect(ZatcaService.isValidVatNumber('30000000000000A'), isFalse);
        expect(ZatcaService.isValidVatNumber('3AAAABBBBCCCC3'), isFalse);
      });

      test('يرفض رقم يحتوي على رموز', () {
        expect(ZatcaService.isValidVatNumber('300-000-000-000'), isFalse);
        expect(ZatcaService.isValidVatNumber('300 000 000 003'), isFalse);
      });
    });

    group('formatVatNumber', () {
      test('يُنسق الرقم الضريبي بشكل صحيح', () {
        expect(
          ZatcaService.formatVatNumber('300000000000003'),
          '300 000 000 000 003',
        );
        expect(
          ZatcaService.formatVatNumber('310123456789012'),
          '310 123 456 789 012',
        );
      });

      test('يُرجع الرقم كما هو إذا كان طوله غير صحيح', () {
        expect(ZatcaService.formatVatNumber('30000000000000'), '30000000000000');
        expect(ZatcaService.formatVatNumber('3000'), '3000');
        expect(ZatcaService.formatVatNumber(''), '');
      });
    });
  });

  group('ZatcaInvoiceData', () {
    test('يُنشئ بيانات فاتورة صحيحة', () {
      final invoice = ZatcaInvoiceData(
        sellerName: 'متجر الحي',
        vatNumber: '300000000000003',
        timestamp: DateTime(2024, 1, 15),
        totalWithVat: 115.0,
        vatAmount: 15.0,
      );

      expect(invoice.sellerName, 'متجر الحي');
      expect(invoice.vatNumber, '300000000000003');
      expect(invoice.totalWithVat, 115.0);
      expect(invoice.vatAmount, 15.0);
      expect(invoice.qrCode, isNotEmpty);
    });

    test('يُحسب QR Code تلقائياً', () {
      final invoice = ZatcaInvoiceData(
        sellerName: 'Store',
        vatNumber: '300000000000003',
        timestamp: DateTime.now(),
        totalWithVat: 100.0,
        vatAmount: 13.04,
      );

      expect(invoice.qrCode, isNotNull);
      expect(() => base64Decode(invoice.qrCode!), returnsNormally);
    });

    group('fromTotal factory', () {
      test('يُحسب الضريبة من الإجمالي بنسبة 15%', () {
        final invoice = ZatcaInvoiceData.fromTotal(
          sellerName: 'متجر',
          vatNumber: '300000000000003',
          timestamp: DateTime.now(),
          totalWithVat: 115.0,
        );

        // 115 / 1.15 = 100, VAT = 15
        expect(invoice.vatAmount, closeTo(15.0, 0.01));
      });

      test('يُحسب الضريبة بنسبة مخصصة', () {
        final invoice = ZatcaInvoiceData.fromTotal(
          sellerName: 'متجر',
          vatNumber: '300000000000003',
          timestamp: DateTime.now(),
          totalWithVat: 110.0,
          vatRate: 0.10, // 10%
        );

        // 110 / 1.10 = 100, VAT = 10
        expect(invoice.vatAmount, closeTo(10.0, 0.01));
      });

      test('يُولّد QR Code صالح من factory', () {
        final invoice = ZatcaInvoiceData.fromTotal(
          sellerName: 'متجر',
          vatNumber: '300000000000003',
          timestamp: DateTime.now(),
          totalWithVat: 230.0,
        );

        expect(invoice.qrCode, isNotNull);
        expect(() => base64Decode(invoice.qrCode!), returnsNormally);
      });
    });
  });
}
