import 'dart:convert';
import 'dart:typed_data';

/// ترميز TLV (Tag-Length-Value) وفق معيار ZATCA
///
/// يدعم الوسوم الخمسة المطلوبة للفوترة الإلكترونية السعودية:
/// - Tag 1: اسم البائع
/// - Tag 2: الرقم الضريبي
/// - Tag 3: تاريخ ووقت الفاتورة (ISO 8601)
/// - Tag 4: إجمالي الفاتورة شامل الضريبة
/// - Tag 5: مبلغ ضريبة القيمة المضافة
class ZatcaTlvEncoder {
  /// ترميز بيانات الفاتورة إلى مصفوفة بايت TLV
  static Uint8List encode({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final List<int> tlvData = [];

    // Tag 1: Seller Name
    _addTlv(tlvData, 1, utf8.encode(sellerName));

    // Tag 2: VAT Registration Number
    _addTlv(tlvData, 2, utf8.encode(vatNumber));

    // Tag 3: Invoice Timestamp (ISO 8601)
    _addTlv(tlvData, 3, utf8.encode(timestamp.toIso8601String()));

    // Tag 4: Invoice Total (with VAT)
    _addTlv(tlvData, 4, utf8.encode(totalWithVat.toStringAsFixed(2)));

    // Tag 5: VAT Amount
    _addTlv(tlvData, 5, utf8.encode(vatAmount.toStringAsFixed(2)));

    return Uint8List.fromList(tlvData);
  }

  /// ترميز TLV إلى Base64
  static String encodeToBase64({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final bytes = encode(
      sellerName: sellerName,
      vatNumber: vatNumber,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
    );
    return base64Encode(bytes);
  }

  /// فك ترميز TLV من بايت إلى قاموس {tag: value}
  static Map<int, String> decode(Uint8List bytes) {
    final tags = <int, String>{};
    int index = 0;

    while (index < bytes.length) {
      if (index + 1 >= bytes.length) break;

      final tag = bytes[index++];
      final length = bytes[index++];

      if (index + length > bytes.length) break;

      final value = utf8.decode(bytes.sublist(index, index + length));
      tags[tag] = value;
      index += length;
    }

    return tags;
  }

  /// فك ترميز TLV من Base64
  static Map<int, String> decodeFromBase64(String base64String) {
    final bytes = base64Decode(base64String);
    return decode(Uint8List.fromList(bytes));
  }

  /// إضافة TLV للمصفوفة
  static void _addTlv(List<int> data, int tag, List<int> value) {
    data.add(tag);
    data.add(value.length);
    data.addAll(value);
  }
}
