import 'dart:convert';
import 'dart:math';

/// خدمة الباركود
/// تستخدم من: cashier, admin_pos
class BarcodeService {
  final Random _random = Random();

  /// توليد باركود EAN-13 جديد
  /// يبدأ بـ 628 (كود السعودية)
  String generateEan13({String prefix = '628'}) {
    // EAN-13: 12 digits + 1 check digit
    final buffer = StringBuffer(prefix);

    // Generate remaining digits (12 - prefix length - 1 for check digit)
    final remainingDigits = 12 - prefix.length;
    for (int i = 0; i < remainingDigits; i++) {
      buffer.write(_random.nextInt(10));
    }

    // Calculate check digit
    final code = buffer.toString();
    final checkDigit = _calculateEan13CheckDigit(code);

    return code + checkDigit.toString();
  }

  /// توليد باركود EAN-8
  String generateEan8({String prefix = '628'}) {
    final buffer = StringBuffer(prefix);

    // Generate remaining digits
    final remainingDigits = 7 - prefix.length;
    for (int i = 0; i < remainingDigits; i++) {
      buffer.write(_random.nextInt(10));
    }

    final code = buffer.toString();
    final checkDigit = _calculateEan8CheckDigit(code);

    return code + checkDigit.toString();
  }

  /// توليد SKU داخلي
  String generateSku({String prefix = 'SKU'}) {
    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    final random = _random.nextInt(9999).toString().padLeft(4, '0');
    return '$prefix-$timestamp-$random';
  }

  /// توليد باركود Code128
  String generateCode128({int length = 10}) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(length, (_) => chars[_random.nextInt(chars.length)])
        .join();
  }

  /// التحقق من صحة باركود EAN-13
  bool validateEan13(String barcode) {
    if (barcode.length != 13) return false;
    if (!RegExp(r'^\d{13}$').hasMatch(barcode)) return false;

    final code = barcode.substring(0, 12);
    final expectedCheckDigit = _calculateEan13CheckDigit(code);
    final actualCheckDigit = int.parse(barcode[12]);

    return expectedCheckDigit == actualCheckDigit;
  }

  /// التحقق من صحة باركود EAN-8
  bool validateEan8(String barcode) {
    if (barcode.length != 8) return false;
    if (!RegExp(r'^\d{8}$').hasMatch(barcode)) return false;

    final code = barcode.substring(0, 7);
    final expectedCheckDigit = _calculateEan8CheckDigit(code);
    final actualCheckDigit = int.parse(barcode[7]);

    return expectedCheckDigit == actualCheckDigit;
  }

  /// تحديد نوع الباركود
  BarcodeFormat? detectFormat(String barcode) {
    if (RegExp(r'^\d{13}$').hasMatch(barcode) && validateEan13(barcode)) {
      return BarcodeFormat.ean13;
    }
    if (RegExp(r'^\d{8}$').hasMatch(barcode) && validateEan8(barcode)) {
      return BarcodeFormat.ean8;
    }
    if (RegExp(r'^\d{12}$').hasMatch(barcode)) {
      return BarcodeFormat.upcA;
    }
    if (RegExp(r'^[A-Z0-9\-\.\s\$\/\+\%]+$').hasMatch(barcode)) {
      return BarcodeFormat.code39;
    }
    if (barcode.isNotEmpty) {
      return BarcodeFormat.code128;
    }
    return null;
  }

  /// توليد QR Code data
  String generateQrCodeData(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// تحليل QR Code data
  Map<String, dynamic>? parseQrCodeData(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ==================== Helpers ====================

  int _calculateEan13CheckDigit(String code) {
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      final digit = int.parse(code[i]);
      sum += digit * (i.isEven ? 1 : 3);
    }
    return (10 - (sum % 10)) % 10;
  }

  int _calculateEan8CheckDigit(String code) {
    int sum = 0;
    for (int i = 0; i < 7; i++) {
      final digit = int.parse(code[i]);
      sum += digit * (i.isEven ? 3 : 1);
    }
    return (10 - (sum % 10)) % 10;
  }
}

/// أنواع الباركود
enum BarcodeFormat {
  ean13,
  ean8,
  upcA,
  upcE,
  code39,
  code128,
  itf,
  qrCode,
  dataMatrix,
  pdf417,
}
