import 'dart:convert';
import 'dart:typed_data';

/// Thrown when a TLV value exceeds the single-byte length constraint.
///
/// Per ZATCA Phase-1 QR spec, each tag-length-value triple uses a single
/// byte for length, so values must fit in 0-255 UTF-8 bytes. Callers
/// should validate or truncate their input before encoding.
class TlvLengthOverflowException implements Exception {
  final int tag;
  final int byteLength;

  const TlvLengthOverflowException({
    required this.tag,
    required this.byteLength,
  });

  @override
  String toString() =>
      'TlvLengthOverflowException: tag $tag value is $byteLength bytes '
      '(max 255 per ZATCA Phase-1 QR spec).';
}

/// خدمة ZATCA لإنشاء QR Code متوافق مع الهيئة
/// https://zatca.gov.sa/ar/E-Invoicing/SystemsDevelopers/Pages/default.aspx
class ZatcaService {
  /// Max value size per ZATCA Phase-1 TLV spec (single-byte length field).
  static const int tlvMaxValueBytes = 255;

  /// إنشاء بيانات QR Code وفق معيار ZATCA
  /// يتم ترميز البيانات باستخدام TLV (Tag-Length-Value)
  ///
  /// Throws [TlvLengthOverflowException] if any encoded value exceeds
  /// [tlvMaxValueBytes]. For Arabic seller names the UTF-8 byte count is
  /// roughly 2× the character count, so 128+ Arabic characters will
  /// overflow — callers should truncate or summarise before calling.
  static String generateQrData({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final bytes = BytesBuilder(copy: false)
      // Tag 1: Seller Name
      ..add(encodeTag(1, utf8.encode(sellerName)))
      // Tag 2: VAT Number
      ..add(encodeTag(2, utf8.encode(vatNumber)))
      // Tag 3: Timestamp (ISO 8601)
      ..add(encodeTag(3, utf8.encode(timestamp.toIso8601String())))
      // Tag 4: Total with VAT
      ..add(encodeTag(4, utf8.encode(totalWithVat.toStringAsFixed(2))))
      // Tag 5: VAT Amount
      ..add(encodeTag(5, utf8.encode(vatAmount.toStringAsFixed(2))));

    return base64Encode(bytes.toBytes());
  }

  /// Encode a single TLV triple as raw bytes.
  ///
  /// Layout: `[tag (1 byte)][length (1 byte)][value (length bytes)]`.
  ///
  /// Throws [ArgumentError] if [tag] is out of the 0-255 range.
  /// Throws [TlvLengthOverflowException] if [value].length exceeds
  /// [tlvMaxValueBytes] — prior implementations silently truncated
  /// here via `Uint8List.fromList` coercing `length & 0xff`, which
  /// produced invalid TLV output for long payloads without failing.
  static Uint8List encodeTag(int tag, List<int> value) {
    if (tag < 0 || tag > 255) {
      throw ArgumentError.value(tag, 'tag', 'must fit in one byte (0-255)');
    }
    if (value.length > tlvMaxValueBytes) {
      throw TlvLengthOverflowException(tag: tag, byteLength: value.length);
    }
    final out = Uint8List(2 + value.length);
    out[0] = tag;
    out[1] = value.length;
    out.setRange(2, 2 + value.length, value);
    return out;
  }

  /// Decode a base64-encoded TLV payload into a `tag → UTF-8 string` map.
  ///
  /// Useful for round-trip testing and for inspecting a QR produced by
  /// another system (or a stored invoice) without re-implementing the
  /// parse loop each time.
  ///
  /// Throws [FormatException] on a truncated or malformed payload
  /// (length byte promises more bytes than remain).
  static Map<int, String> decodeQrData(String base64Payload) {
    final bytes = base64Decode(base64Payload);
    final tags = <int, String>{};
    var index = 0;
    while (index < bytes.length) {
      if (index + 2 > bytes.length) {
        throw const FormatException('TLV payload truncated before header');
      }
      final tag = bytes[index];
      final length = bytes[index + 1];
      final valueStart = index + 2;
      final valueEnd = valueStart + length;
      if (valueEnd > bytes.length) {
        throw FormatException(
          'TLV payload truncated: tag $tag promises $length bytes but only '
          '${bytes.length - valueStart} remain',
        );
      }
      tags[tag] = utf8.decode(bytes.sublist(valueStart, valueEnd));
      index = valueEnd;
    }
    return tags;
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
