import 'dart:convert';
import 'dart:typed_data';

/// خدمة ZATCA لإنشاء QR Code متوافق مع الهيئة
/// https://zatca.gov.sa/ar/E-Invoicing/SystemsDevelopers/Pages/default.aspx
class ZatcaService {
  /// إنشاء بيانات QR Code وفق معيار ZATCA
  /// يتم ترميز البيانات باستخدام TLV (Tag-Length-Value)
  static String generateQrData({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final List<int> tlvData = [];
    
    // Tag 1: Seller Name
    _addTlv(tlvData, 1, utf8.encode(sellerName));
    
    // Tag 2: VAT Number
    _addTlv(tlvData, 2, utf8.encode(vatNumber));
    
    // Tag 3: Timestamp (ISO 8601)
    _addTlv(tlvData, 3, utf8.encode(timestamp.toIso8601String()));
    
    // Tag 4: Total with VAT
    _addTlv(tlvData, 4, utf8.encode(totalWithVat.toStringAsFixed(2)));
    
    // Tag 5: VAT Amount
    _addTlv(tlvData, 5, utf8.encode(vatAmount.toStringAsFixed(2)));
    
    // Convert to Base64
    return base64Encode(Uint8List.fromList(tlvData));
  }
  
  /// إضافة TLV للمصفوفة
  static void _addTlv(List<int> data, int tag, List<int> value) {
    data.add(tag);
    data.add(value.length);
    data.addAll(value);
  }
  
  /// التحقق من صحة الرقم الضريبي السعودي
  static bool isValidVatNumber(String vatNumber) {
    // الرقم الضريبي السعودي: 15 رقم يبدأ بـ 3
    if (vatNumber.length != 15) return false;
    if (!vatNumber.startsWith('3')) return false;
    if (!RegExp(r'^\d+$').hasMatch(vatNumber)) return false;
    return true;
  }
  
  /// تنسيق الرقم الضريبي للعرض
  static String formatVatNumber(String vatNumber) {
    if (vatNumber.length != 15) return vatNumber;
    return '${vatNumber.substring(0, 3)} ${vatNumber.substring(3, 6)} ${vatNumber.substring(6, 9)} ${vatNumber.substring(9, 12)} ${vatNumber.substring(12)}';
  }
}

/// بيانات فاتورة ZATCA
class ZatcaInvoiceData {
  final String sellerName;
  final String vatNumber;
  final DateTime timestamp;
  final double totalWithVat;
  final double vatAmount;
  final String? qrCode;
  
  ZatcaInvoiceData({
    required this.sellerName,
    required this.vatNumber,
    required this.timestamp,
    required this.totalWithVat,
    required this.vatAmount,
  }) : qrCode = ZatcaService.generateQrData(
    sellerName: sellerName,
    vatNumber: vatNumber,
    timestamp: timestamp,
    totalWithVat: totalWithVat,
    vatAmount: vatAmount,
  );
  
  /// حساب الضريبة من الإجمالي
  factory ZatcaInvoiceData.fromTotal({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    double vatRate = 0.15,
  }) {
    final totalWithoutVat = totalWithVat / (1 + vatRate);
    final vatAmount = totalWithVat - totalWithoutVat;
    
    return ZatcaInvoiceData(
      sellerName: sellerName,
      vatNumber: vatNumber,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
    );
  }
}
