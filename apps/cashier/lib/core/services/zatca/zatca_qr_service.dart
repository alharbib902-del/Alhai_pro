import 'zatca_tlv_encoder.dart';

/// خدمة إنشاء QR Code متوافق مع ZATCA
///
/// ينتج بيانات QR Code بترميز Base64 من بيانات TLV
/// للاستخدام مع [QrImageView] من حزمة qr_flutter
class ZatcaQrService {
  /// إنشاء بيانات QR Code بترميز Base64
  static String generateQrData({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    return ZatcaTlvEncoder.encodeToBase64(
      sellerName: sellerName,
      vatNumber: vatNumber,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
    );
  }

  /// التحقق من صحة الرقم الضريبي السعودي
  /// الرقم الضريبي: 15 رقم يبدأ بـ 3
  static bool isValidVatNumber(String vatNumber) {
    if (vatNumber.length != 15) return false;
    if (!vatNumber.startsWith('3')) return false;
    if (!RegExp(r'^\d+$').hasMatch(vatNumber)) return false;
    return true;
  }

  /// تنسيق الرقم الضريبي للعرض
  /// مثال: 300000000000003 → 300 000 000 000 003
  static String formatVatNumber(String vatNumber) {
    if (vatNumber.length != 15) return vatNumber;
    return '${vatNumber.substring(0, 3)} '
        '${vatNumber.substring(3, 6)} '
        '${vatNumber.substring(6, 9)} '
        '${vatNumber.substring(9, 12)} '
        '${vatNumber.substring(12)}';
  }

  /// التحقق من صحة بيانات QR Code عبر فك ترميز TLV
  static bool validateQrData(String base64Data) {
    try {
      final tags = ZatcaTlvEncoder.decodeFromBase64(base64Data);
      return tags.containsKey(1) &&
          tags.containsKey(2) &&
          tags.containsKey(3) &&
          tags.containsKey(4) &&
          tags.containsKey(5);
    } catch (_) {
      return false;
    }
  }
}
