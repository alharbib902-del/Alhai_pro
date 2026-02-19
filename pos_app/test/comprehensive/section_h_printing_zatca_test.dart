/// اختبارات قسم H: الطباعة / ZATCA
///
/// 6 اختبارات لإنشاء بيانات الإيصال و QR Code و التحقق من TLV
/// و إعادة الطباعة و الرقم الضريبي
library;

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/zatca_service.dart';
import 'fixtures/test_fixtures.dart';

// ============================================================================
// TLV PARSER HELPER
// ============================================================================

/// تحليل بيانات TLV من Base64 إلى خريطة {tag: value}
Map<int, String> parseTlv(String base64Data) {
  final bytes = base64Decode(base64Data);
  final result = <int, String>{};
  var offset = 0;

  while (offset < bytes.length) {
    final tag = bytes[offset];
    final length = bytes[offset + 1];
    final valueBytes = bytes.sublist(offset + 2, offset + 2 + length);
    result[tag] = utf8.decode(valueBytes);
    offset += 2 + length;
  }

  return result;
}

void main() {
  group('Section H: الطباعة / ZATCA', () {
    // ================================================================
    // بيانات مشتركة للاختبارات
    // ================================================================

    const sellerName = 'متجر الحي السعودي';
    const vatNumber = '300075588700003';
    final timestamp = DateTime(2025, 6, 15, 14, 30, 0);
    const totalWithVat = 115.00;
    const vatAmount = 15.00;

    // ================================================================
    // H01: إنشاء بيانات إيصال للطباعة
    // ================================================================

    test('H01 إنشاء بيانات إيصال: ZatcaInvoiceData يملأ جميع الحقول و qrCode غير فارغ', () {
      final invoice = ZatcaInvoiceData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      // التحقق من جميع الحقول
      expect(invoice.sellerName, sellerName);
      expect(invoice.vatNumber, vatNumber);
      expect(invoice.timestamp, timestamp);
      expect(invoice.totalWithVat, totalWithVat);
      expect(invoice.vatAmount, vatAmount);

      // qrCode يجب أن يكون موجوداً وغير فارغ
      expect(invoice.qrCode, isNotNull);
      expect(invoice.qrCode, isNotEmpty);

      // التحقق أن qrCode هو Base64 صالح
      expect(() => base64Decode(invoice.qrCode!), returnsNormally);
    });

    // ================================================================
    // H02: نص RTL عربي في الإيصال
    // ================================================================

    test('H02 نص عربي RTL: اسم البائع العربي يُرمّز بشكل صحيح في QR', () {
      const arabicSeller = 'مؤسسة الرحمن للتجارة';

      final qrBase64 = ZatcaService.generateQrData(
        sellerName: arabicSeller,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      // تحليل TLV واستخراج اسم البائع (Tag 1)
      final tlvFields = parseTlv(qrBase64);
      final decodedSeller = tlvFields[1];

      expect(decodedSeller, isNotNull);
      expect(decodedSeller, arabicSeller);

      // التحقق من أن النص العربي يحتوي على أحرف عربية
      expect(decodedSeller!, contains('الرحمن'));
      expect(decodedSeller, contains('للتجارة'));

      // التحقق يدوياً من طول UTF-8 (العربية تأخذ أكثر من بايت واحد لكل حرف)
      final arabicBytes = utf8.encode(arabicSeller);
      expect(arabicBytes.length, greaterThan(arabicSeller.length));
    });

    // ================================================================
    // H03: QR TLV يحتوي على 5 حقول مطلوبة
    // ================================================================

    test('H03 بنية TLV: تحليل Base64 → التحقق من الحقول 1-5 بالقيم الصحيحة', () {
      final qrBase64 = ZatcaService.generateQrData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      // تحليل TLV
      final tlvFields = parseTlv(qrBase64);

      // التحقق من وجود جميع الحقول الخمسة
      expect(tlvFields.length, 5);
      expect(tlvFields.containsKey(1), isTrue, reason: 'Tag 1 (اسم البائع) مفقود');
      expect(tlvFields.containsKey(2), isTrue, reason: 'Tag 2 (الرقم الضريبي) مفقود');
      expect(tlvFields.containsKey(3), isTrue, reason: 'Tag 3 (التاريخ والوقت) مفقود');
      expect(tlvFields.containsKey(4), isTrue, reason: 'Tag 4 (الإجمالي مع الضريبة) مفقود');
      expect(tlvFields.containsKey(5), isTrue, reason: 'Tag 5 (مبلغ الضريبة) مفقود');

      // Tag 1: اسم البائع
      expect(tlvFields[1], sellerName);

      // Tag 2: الرقم الضريبي
      expect(tlvFields[2], vatNumber);

      // Tag 3: التاريخ والوقت (ISO 8601)
      expect(tlvFields[3], timestamp.toIso8601String());

      // Tag 4: الإجمالي مع الضريبة (منزلتان عشريتان)
      expect(tlvFields[4], '115.00');

      // Tag 5: مبلغ الضريبة (منزلتان عشريتان)
      expect(tlvFields[5], '15.00');

      // التحقق من بنية TLV الخام (ترتيب البايتات)
      final bytes = base64Decode(qrBase64);
      // أول بايت = Tag 1
      expect(bytes[0], 1);
      // البايت الثاني = طول اسم البائع بـ UTF-8
      final sellerBytes = utf8.encode(sellerName);
      expect(bytes[1], sellerBytes.length);
    });

    // ================================================================
    // H04: إعادة طباعة فاتورة قديمة
    // ================================================================

    test('H04 إعادة الطباعة: إنشاء QR لنفس البيع مرتين → نتيجة متطابقة', () {
      // المحاكاة: نفس بيانات البيع تُستخدم لإعادة الطباعة
      final qrFirst = ZatcaService.generateQrData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      final qrSecond = ZatcaService.generateQrData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      // يجب أن يكون الناتج متطابقاً تماماً
      expect(qrFirst, qrSecond);

      // التحقق من أن البيانات المفكوكة متطابقة أيضاً
      final tlvFirst = parseTlv(qrFirst);
      final tlvSecond = parseTlv(qrSecond);

      for (final tag in [1, 2, 3, 4, 5]) {
        expect(tlvFirst[tag], tlvSecond[tag],
            reason: 'Tag $tag يختلف بين الطباعتين');
      }

      // التحقق عبر ZatcaInvoiceData أيضاً
      final invoice1 = ZatcaInvoiceData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      final invoice2 = ZatcaInvoiceData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      expect(invoice1.qrCode, invoice2.qrCode);
    });

    // ================================================================
    // H05: إنشاء PDF (placeholder)
    // ================================================================

    test('H05 إنشاء PDF (placeholder): ZatcaInvoiceData يُنشأ ببيانات صالحة و fromTotal', () {
      // إنشاء عادي
      final invoice = ZatcaInvoiceData(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: totalWithVat,
        vatAmount: vatAmount,
      );

      expect(invoice.sellerName, isNotEmpty);
      expect(invoice.vatNumber, hasLength(15));
      expect(invoice.totalWithVat, greaterThan(0));
      expect(invoice.vatAmount, greaterThan(0));
      expect(invoice.vatAmount, lessThan(invoice.totalWithVat));
      expect(invoice.qrCode, isNotNull);

      // إنشاء من الإجمالي (fromTotal) - حساب الضريبة تلقائياً
      final invoiceFromTotal = ZatcaInvoiceData.fromTotal(
        sellerName: sellerName,
        vatNumber: vatNumber,
        timestamp: timestamp,
        totalWithVat: 230.00,
        vatRate: vatRate, // 0.15 من fixtures
      );

      // 230.00 / 1.15 = 200.00 → VAT = 30.00
      expect(invoiceFromTotal.totalWithVat, 230.00);
      expect(invoiceFromTotal.vatAmount, closeTo(30.00, 0.01));
      expect(invoiceFromTotal.qrCode, isNotNull);
      expect(invoiceFromTotal.qrCode, isNotEmpty);

      // التحقق من أن البيانات قابلة للتحليل كـ TLV
      final tlv = parseTlv(invoiceFromTotal.qrCode!);
      expect(tlv.length, 5);
      expect(tlv[1], sellerName);
    });

    // ================================================================
    // H06: التحقق من صحة الرقم الضريبي
    // ================================================================

    test('H06 التحقق من الرقم الضريبي: أرقام صالحة وغير صالحة', () {
      // أرقام ضريبية صالحة (15 رقماً تبدأ بـ 3)
      expect(ZatcaService.isValidVatNumber('300075588700003'), isTrue);
      expect(ZatcaService.isValidVatNumber('310000000000003'), isTrue);
      expect(ZatcaService.isValidVatNumber('399999999999999'), isTrue);
      expect(ZatcaService.isValidVatNumber('300000000000000'), isTrue);

      // أرقام غير صالحة: لا تبدأ بـ 3
      expect(ZatcaService.isValidVatNumber('100075588700003'), isFalse);
      expect(ZatcaService.isValidVatNumber('200075588700003'), isFalse);
      expect(ZatcaService.isValidVatNumber('000000000000000'), isFalse);

      // أرقام غير صالحة: طول خاطئ
      expect(ZatcaService.isValidVatNumber('30007558870000'), isFalse); // 14 رقماً
      expect(ZatcaService.isValidVatNumber('3000755887000031'), isFalse); // 16 رقماً
      expect(ZatcaService.isValidVatNumber(''), isFalse); // فارغ
      expect(ZatcaService.isValidVatNumber('3'), isFalse); // رقم واحد

      // أرقام غير صالحة: تحتوي على أحرف
      expect(ZatcaService.isValidVatNumber('30007558870000A'), isFalse);
      expect(ZatcaService.isValidVatNumber('3000755887 0003'), isFalse); // مسافة
      expect(ZatcaService.isValidVatNumber('300-075-588-700'), isFalse); // شرطات

      // التحقق من تنسيق الرقم الضريبي
      expect(
        ZatcaService.formatVatNumber('300075588700003'),
        '300 075 588 700 003',
      );

      // التنسيق لا يغيّر رقماً بطول خاطئ
      expect(
        ZatcaService.formatVatNumber('12345'),
        '12345',
      );
    });
  });
}
