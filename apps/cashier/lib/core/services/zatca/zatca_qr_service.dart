import 'package:alhai_zatca/alhai_zatca.dart' show ZatcaTlvEncoder;
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

/// ZATCA-compliant QR code service for the cashier app
///
/// Delegates TLV encoding to [ZatcaTlvEncoder] from the alhai_zatca package
/// (Phase 2 compliant, tags 1-9 capable). For the cashier receipt QR,
/// we use the simplified encoding (tags 1-5) which is the minimum
/// required for printed invoices.
class ZatcaQrService {
  static final _encoder = ZatcaTlvEncoder();

  /// Generate base64-encoded QR data using the package TLV encoder
  static String generateQrData({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    return _encoder.encodeSimplified(
      sellerName: sellerName,
      vatNumber: vatNumber,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
    );
  }

  /// Validate a Saudi VAT registration number
  /// Must be 15 digits starting with 3
  static bool isValidVatNumber(String vatNumber) {
    if (vatNumber.length != 15) return false;
    if (!vatNumber.startsWith('3')) return false;
    if (!RegExp(r'^\d+$').hasMatch(vatNumber)) return false;
    return true;
  }

  /// Format a VAT number for display
  /// Example: 300000000000003 -> 300 000 000 000 003
  static String formatVatNumber(String vatNumber) {
    if (vatNumber.length != 15) return vatNumber;
    return '${vatNumber.substring(0, 3)} '
        '${vatNumber.substring(3, 6)} '
        '${vatNumber.substring(6, 9)} '
        '${vatNumber.substring(9, 12)} '
        '${vatNumber.substring(12)}';
  }

  /// Validate QR data by decoding and checking required TLV tags
  static bool validateQrData(String base64Data) {
    try {
      final tags = _encoder.decodeToStrings(base64Data);
      return tags.containsKey(1) &&
          tags.containsKey(2) &&
          tags.containsKey(3) &&
          tags.containsKey(4) &&
          tags.containsKey(5);
    } catch (e) {
      if (kDebugMode) debugPrint('ZATCA QR validation failed: $e');
      return false;
    }
  }
}
