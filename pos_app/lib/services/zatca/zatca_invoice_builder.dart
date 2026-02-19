/// ZATCA Invoice Builder - بناء فاتورة ZATCA
///
/// يوفر:
/// - توليد XML وفق UBL 2.1
/// - حساب الهاش
/// - توليد QR Code
/// - التوقيع الرقمي
library zatca_invoice_builder;

import 'dart:convert';
import 'package:crypto/crypto.dart';

// ============================================================================
// ZATCA INVOICE TYPES
// ============================================================================

/// نوع الفاتورة
enum ZatcaInvoiceType {
  /// فاتورة مبسطة (B2C)
  simplified('388'),

  /// فاتورة ضريبية (B2B)
  standard('380'),

  /// إشعار دائن
  creditNote('381'),

  /// إشعار مدين
  debitNote('383');

  final String code;
  const ZatcaInvoiceType(this.code);
}

/// نوع المعاملة
enum ZatcaTransactionType {
  /// نقدي
  nominal('0100000'),

  /// تصدير
  export('0200000'),

  /// داخلي
  internal('0300000');

  final String code;
  const ZatcaTransactionType(this.code);
}

// ============================================================================
// ZATCA MODELS
// ============================================================================

/// بيانات البائع
class ZatcaSeller {
  final String name;
  final String vatNumber;
  final String buildingNumber;
  final String streetName;
  final String district;
  final String city;
  final String postalCode;
  final String country;

  const ZatcaSeller({
    required this.name,
    required this.vatNumber,
    required this.buildingNumber,
    required this.streetName,
    required this.district,
    required this.city,
    required this.postalCode,
    this.country = 'SA',
  });

  /// التحقق من صحة الرقم الضريبي
  bool get isValidVat => vatNumber.length == 15 && vatNumber.startsWith('3');
}

/// بيانات المشتري (للفواتير الضريبية)
class ZatcaBuyer {
  final String? name;
  final String? vatNumber;
  final String? buildingNumber;
  final String? streetName;
  final String? district;
  final String? city;
  final String? postalCode;
  final String country;

  const ZatcaBuyer({
    this.name,
    this.vatNumber,
    this.buildingNumber,
    this.streetName,
    this.district,
    this.city,
    this.postalCode,
    this.country = 'SA',
  });

  bool get isProvided => name != null && name!.isNotEmpty;
}

/// بند الفاتورة
class ZatcaLineItem {
  final String id;
  final String name;
  final double quantity;
  final double unitPrice;
  final double discount;
  final double vatRate;
  final String vatCategory;

  const ZatcaLineItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.vatRate = 15,
    this.vatCategory = 'S',
  });

  /// المجموع قبل الضريبة
  double get lineNetAmount => (quantity * unitPrice) - discount;

  /// مبلغ الضريبة
  double get vatAmount => lineNetAmount * (vatRate / 100);

  /// المجموع شامل الضريبة
  double get lineTotal => lineNetAmount + vatAmount;
}

/// فاتورة ZATCA
class ZatcaInvoice {
  final String invoiceNumber;
  final String uuid;
  final DateTime issueDate;
  final DateTime issueTime;
  final ZatcaInvoiceType type;
  final ZatcaTransactionType transactionType;
  final ZatcaSeller seller;
  final ZatcaBuyer? buyer;
  final List<ZatcaLineItem> items;
  final String? previousInvoiceHash;
  final String currency;

  const ZatcaInvoice({
    required this.invoiceNumber,
    required this.uuid,
    required this.issueDate,
    required this.issueTime,
    required this.type,
    required this.transactionType,
    required this.seller,
    this.buyer,
    required this.items,
    this.previousInvoiceHash,
    this.currency = 'SAR',
  });

  /// مجموع الخصومات
  double get totalDiscount => items.fold(0, (sum, item) => sum + item.discount);

  /// المجموع قبل الضريبة
  double get taxableAmount => items.fold(0, (sum, item) => sum + item.lineNetAmount);

  /// إجمالي الضريبة
  double get totalVat => items.fold(0, (sum, item) => sum + item.vatAmount);

  /// المجموع الكلي
  double get totalWithVat => taxableAmount + totalVat;
}

// ============================================================================
// ZATCA INVOICE BUILDER
// ============================================================================

/// بناء فاتورة ZATCA
class ZatcaInvoiceBuilder {
  /// بناء XML للفاتورة
  static String buildXml(ZatcaInvoice invoice) {
    final buffer = StringBuffer();

    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2"');
    buffer.writeln('         xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"');
    buffer.writeln('         xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"');
    buffer.writeln('         xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2">');

    // معلومات الفاتورة الأساسية
    buffer.writeln('  <cbc:ProfileID>reporting:1.0</cbc:ProfileID>');
    buffer.writeln('  <cbc:ID>${invoice.invoiceNumber}</cbc:ID>');
    buffer.writeln('  <cbc:UUID>${invoice.uuid}</cbc:UUID>');
    buffer.writeln('  <cbc:IssueDate>${_formatDate(invoice.issueDate)}</cbc:IssueDate>');
    buffer.writeln('  <cbc:IssueTime>${_formatTime(invoice.issueTime)}</cbc:IssueTime>');
    buffer.writeln('  <cbc:InvoiceTypeCode name="${invoice.transactionType.code}">${invoice.type.code}</cbc:InvoiceTypeCode>');
    buffer.writeln('  <cbc:DocumentCurrencyCode>${invoice.currency}</cbc:DocumentCurrencyCode>');
    buffer.writeln('  <cbc:TaxCurrencyCode>${invoice.currency}</cbc:TaxCurrencyCode>');

    // معلومات البائع
    buffer.writeln('  <cac:AccountingSupplierParty>');
    buffer.writeln('    <cac:Party>');
    _writePartyIdentification(buffer, invoice.seller.vatNumber);
    _writePostalAddress(buffer, invoice.seller);
    _writePartyTaxScheme(buffer, invoice.seller.vatNumber);
    buffer.writeln('      <cac:PartyLegalEntity>');
    buffer.writeln('        <cbc:RegistrationName>${_escapeXml(invoice.seller.name)}</cbc:RegistrationName>');
    buffer.writeln('      </cac:PartyLegalEntity>');
    buffer.writeln('    </cac:Party>');
    buffer.writeln('  </cac:AccountingSupplierParty>');

    // معلومات المشتري (للفواتير الضريبية)
    if (invoice.type == ZatcaInvoiceType.standard && invoice.buyer?.isProvided == true) {
      buffer.writeln('  <cac:AccountingCustomerParty>');
      buffer.writeln('    <cac:Party>');
      if (invoice.buyer!.vatNumber != null) {
        _writePartyIdentification(buffer, invoice.buyer!.vatNumber!);
        _writePartyTaxScheme(buffer, invoice.buyer!.vatNumber!);
      }
      buffer.writeln('      <cac:PartyLegalEntity>');
      buffer.writeln('        <cbc:RegistrationName>${_escapeXml(invoice.buyer!.name!)}</cbc:RegistrationName>');
      buffer.writeln('      </cac:PartyLegalEntity>');
      buffer.writeln('    </cac:Party>');
      buffer.writeln('  </cac:AccountingCustomerParty>');
    }

    // طريقة الدفع
    buffer.writeln('  <cac:PaymentMeans>');
    buffer.writeln('    <cbc:PaymentMeansCode>10</cbc:PaymentMeansCode>');
    buffer.writeln('  </cac:PaymentMeans>');

    // ملخص الضريبة
    _writeTaxTotal(buffer, invoice);

    // المجموع
    _writeLegalMonetaryTotal(buffer, invoice);

    // البنود
    for (var i = 0; i < invoice.items.length; i++) {
      _writeInvoiceLine(buffer, invoice.items[i], i + 1);
    }

    buffer.writeln('</Invoice>');

    return buffer.toString();
  }

  /// حساب هاش الفاتورة
  static String calculateHash(String xml) {
    // إزالة التوقيع من XML إن وجد
    final cleanXml = xml.replaceAll(RegExp(r'<ext:UBLExtensions>.*?</ext:UBLExtensions>', dotAll: true), '');

    // حساب SHA-256
    final bytes = utf8.encode(cleanXml);
    final digest = sha256.convert(bytes);

    return base64.encode(digest.bytes);
  }

  /// توليد بيانات QR Code
  static String generateQrData(ZatcaInvoice invoice, String invoiceHash) {
    final tlvData = <int>[];

    // 1. اسم البائع
    _addTlv(tlvData, 1, utf8.encode(invoice.seller.name));

    // 2. الرقم الضريبي
    _addTlv(tlvData, 2, utf8.encode(invoice.seller.vatNumber));

    // 3. تاريخ ووقت الفاتورة
    final timestamp = '${_formatDate(invoice.issueDate)}T${_formatTime(invoice.issueTime)}';
    _addTlv(tlvData, 3, utf8.encode(timestamp));

    // 4. إجمالي الفاتورة
    _addTlv(tlvData, 4, utf8.encode(invoice.totalWithVat.toStringAsFixed(2)));

    // 5. إجمالي الضريبة
    _addTlv(tlvData, 5, utf8.encode(invoice.totalVat.toStringAsFixed(2)));

    // 6. هاش الفاتورة
    _addTlv(tlvData, 6, base64.decode(invoiceHash));

    // 7. التوقيع الرقمي (سيُضاف لاحقاً)

    // 8. المفتاح العام (سيُضاف لاحقاً)

    return base64.encode(tlvData);
  }

  /// عداد للتأكد من عدم تكرار UUID في نفس الميلي ثانية
  static int _uuidCounter = 0;

  /// توليد UUID
  static String generateUuid() {
    // تنسيق ZATCA: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
    final now = DateTime.now();
    final random = now.microsecondsSinceEpoch;
    _uuidCounter++;

    String hex(int n, int len) => n.toRadixString(16).padLeft(len, '0');

    // استخدام العداد لضمان الفريدية
    final counterPart = _uuidCounter & 0xFFFF;

    return '${hex((random ^ counterPart) & 0xFFFFFFFF, 8)}-'
           '${hex(((random >> 16) ^ counterPart) & 0xFFFF, 4)}-'
           '4${hex((random ^ _uuidCounter) & 0xFFF, 3)}-'
           '${hex(8 | (random & 0x3), 1)}${hex((random ^ _uuidCounter) & 0xFFF, 3)}-'
           '${hex((now.millisecondsSinceEpoch ^ _uuidCounter) & 0xFFFFFFFFFFFF, 12)}';
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  static void _writePartyIdentification(StringBuffer buffer, String vatNumber) {
    buffer.writeln('      <cac:PartyIdentification>');
    buffer.writeln('        <cbc:ID schemeID="VAT">$vatNumber</cbc:ID>');
    buffer.writeln('      </cac:PartyIdentification>');
  }

  static void _writePostalAddress(StringBuffer buffer, ZatcaSeller seller) {
    buffer.writeln('      <cac:PostalAddress>');
    buffer.writeln('        <cbc:StreetName>${_escapeXml(seller.streetName)}</cbc:StreetName>');
    buffer.writeln('        <cbc:BuildingNumber>${seller.buildingNumber}</cbc:BuildingNumber>');
    buffer.writeln('        <cbc:CitySubdivisionName>${_escapeXml(seller.district)}</cbc:CitySubdivisionName>');
    buffer.writeln('        <cbc:CityName>${_escapeXml(seller.city)}</cbc:CityName>');
    buffer.writeln('        <cbc:PostalZone>${seller.postalCode}</cbc:PostalZone>');
    buffer.writeln('        <cac:Country>');
    buffer.writeln('          <cbc:IdentificationCode>${seller.country}</cbc:IdentificationCode>');
    buffer.writeln('        </cac:Country>');
    buffer.writeln('      </cac:PostalAddress>');
  }

  static void _writePartyTaxScheme(StringBuffer buffer, String vatNumber) {
    buffer.writeln('      <cac:PartyTaxScheme>');
    buffer.writeln('        <cbc:CompanyID>$vatNumber</cbc:CompanyID>');
    buffer.writeln('        <cac:TaxScheme>');
    buffer.writeln('          <cbc:ID>VAT</cbc:ID>');
    buffer.writeln('        </cac:TaxScheme>');
    buffer.writeln('      </cac:PartyTaxScheme>');
  }

  static void _writeTaxTotal(StringBuffer buffer, ZatcaInvoice invoice) {
    buffer.writeln('  <cac:TaxTotal>');
    buffer.writeln('    <cbc:TaxAmount currencyID="${invoice.currency}">${invoice.totalVat.toStringAsFixed(2)}</cbc:TaxAmount>');

    // تفاصيل كل فئة ضريبية
    final vatCategories = <String, double>{};
    final vatAmounts = <String, double>{};

    for (final item in invoice.items) {
      final key = '${item.vatRate}_${item.vatCategory}';
      vatCategories[key] = (vatCategories[key] ?? 0) + item.lineNetAmount;
      vatAmounts[key] = (vatAmounts[key] ?? 0) + item.vatAmount;
    }

    for (final entry in vatCategories.entries) {
      final parts = entry.key.split('_');
      final rate = double.parse(parts[0]);
      final category = parts[1];

      buffer.writeln('    <cac:TaxSubtotal>');
      buffer.writeln('      <cbc:TaxableAmount currencyID="${invoice.currency}">${entry.value.toStringAsFixed(2)}</cbc:TaxableAmount>');
      buffer.writeln('      <cbc:TaxAmount currencyID="${invoice.currency}">${vatAmounts[entry.key]!.toStringAsFixed(2)}</cbc:TaxAmount>');
      buffer.writeln('      <cac:TaxCategory>');
      buffer.writeln('        <cbc:ID>$category</cbc:ID>');
      buffer.writeln('        <cbc:Percent>${rate.toStringAsFixed(2)}</cbc:Percent>');
      buffer.writeln('        <cac:TaxScheme>');
      buffer.writeln('          <cbc:ID>VAT</cbc:ID>');
      buffer.writeln('        </cac:TaxScheme>');
      buffer.writeln('      </cac:TaxCategory>');
      buffer.writeln('    </cac:TaxSubtotal>');
    }

    buffer.writeln('  </cac:TaxTotal>');
  }

  static void _writeLegalMonetaryTotal(StringBuffer buffer, ZatcaInvoice invoice) {
    buffer.writeln('  <cac:LegalMonetaryTotal>');
    buffer.writeln('    <cbc:LineExtensionAmount currencyID="${invoice.currency}">${invoice.taxableAmount.toStringAsFixed(2)}</cbc:LineExtensionAmount>');
    buffer.writeln('    <cbc:TaxExclusiveAmount currencyID="${invoice.currency}">${invoice.taxableAmount.toStringAsFixed(2)}</cbc:TaxExclusiveAmount>');
    buffer.writeln('    <cbc:TaxInclusiveAmount currencyID="${invoice.currency}">${invoice.totalWithVat.toStringAsFixed(2)}</cbc:TaxInclusiveAmount>');
    buffer.writeln('    <cbc:AllowanceTotalAmount currencyID="${invoice.currency}">${invoice.totalDiscount.toStringAsFixed(2)}</cbc:AllowanceTotalAmount>');
    buffer.writeln('    <cbc:PayableAmount currencyID="${invoice.currency}">${invoice.totalWithVat.toStringAsFixed(2)}</cbc:PayableAmount>');
    buffer.writeln('  </cac:LegalMonetaryTotal>');
  }

  static void _writeInvoiceLine(StringBuffer buffer, ZatcaLineItem item, int lineNumber) {
    buffer.writeln('  <cac:InvoiceLine>');
    buffer.writeln('    <cbc:ID>$lineNumber</cbc:ID>');
    buffer.writeln('    <cbc:InvoicedQuantity unitCode="PCE">${item.quantity}</cbc:InvoicedQuantity>');
    buffer.writeln('    <cbc:LineExtensionAmount currencyID="SAR">${item.lineNetAmount.toStringAsFixed(2)}</cbc:LineExtensionAmount>');

    // الضريبة للبند
    buffer.writeln('    <cac:TaxTotal>');
    buffer.writeln('      <cbc:TaxAmount currencyID="SAR">${item.vatAmount.toStringAsFixed(2)}</cbc:TaxAmount>');
    buffer.writeln('      <cbc:RoundingAmount currencyID="SAR">${item.lineTotal.toStringAsFixed(2)}</cbc:RoundingAmount>');
    buffer.writeln('    </cac:TaxTotal>');

    // معلومات المنتج
    buffer.writeln('    <cac:Item>');
    buffer.writeln('      <cbc:Name>${_escapeXml(item.name)}</cbc:Name>');
    buffer.writeln('      <cac:ClassifiedTaxCategory>');
    buffer.writeln('        <cbc:ID>${item.vatCategory}</cbc:ID>');
    buffer.writeln('        <cbc:Percent>${item.vatRate.toStringAsFixed(2)}</cbc:Percent>');
    buffer.writeln('        <cac:TaxScheme>');
    buffer.writeln('          <cbc:ID>VAT</cbc:ID>');
    buffer.writeln('        </cac:TaxScheme>');
    buffer.writeln('      </cac:ClassifiedTaxCategory>');
    buffer.writeln('    </cac:Item>');

    // السعر
    buffer.writeln('    <cac:Price>');
    buffer.writeln('      <cbc:PriceAmount currencyID="SAR">${item.unitPrice.toStringAsFixed(2)}</cbc:PriceAmount>');
    buffer.writeln('    </cac:Price>');

    buffer.writeln('  </cac:InvoiceLine>');
  }

  static void _addTlv(List<int> data, int tag, List<int> value) {
    data.add(tag);
    data.add(value.length);
    data.addAll(value);
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}:'
           '${time.second.toString().padLeft(2, '0')}';
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

// ============================================================================
// ZATCA VALIDATOR
// ============================================================================

/// نتيجة التحقق
class ZatcaValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ZatcaValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
}

/// التحقق من صحة الفاتورة
class ZatcaValidator {
  static ZatcaValidationResult validate(ZatcaInvoice invoice) {
    final errors = <String>[];
    final warnings = <String>[];

    // التحقق من البائع
    if (!invoice.seller.isValidVat) {
      errors.add('الرقم الضريبي للبائع غير صحيح');
    }

    if (invoice.seller.name.isEmpty) {
      errors.add('اسم البائع مطلوب');
    }

    // التحقق من البنود
    if (invoice.items.isEmpty) {
      errors.add('الفاتورة يجب أن تحتوي على بند واحد على الأقل');
    }

    for (var i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      if (item.quantity <= 0) {
        errors.add('الكمية في البند ${i + 1} يجب أن تكون أكبر من صفر');
      }
      if (item.unitPrice < 0) {
        errors.add('السعر في البند ${i + 1} لا يمكن أن يكون سالباً');
      }
    }

    // التحقق من الفواتير الضريبية
    if (invoice.type == ZatcaInvoiceType.standard) {
      if (invoice.buyer == null || !invoice.buyer!.isProvided) {
        errors.add('معلومات المشتري مطلوبة للفواتير الضريبية');
      }
    }

    // تحذيرات
    if (invoice.totalWithVat == 0) {
      warnings.add('إجمالي الفاتورة صفر');
    }

    return ZatcaValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}
