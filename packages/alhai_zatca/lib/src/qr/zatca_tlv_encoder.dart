import 'dart:convert';
import 'dart:typed_data';

/// TLV (Tag-Length-Value) encoder for ZATCA Phase 2 QR codes
///
/// Phase 2 enhanced QR codes include tags 1-9:
/// - Tag 1: Seller name (UTF-8)
/// - Tag 2: VAT registration number
/// - Tag 3: Timestamp (ISO 8601)
/// - Tag 4: Invoice total (with VAT)
/// - Tag 5: VAT amount
/// - Tag 6: Invoice XML hash (SHA-256 bytes)
/// - Tag 7: ECDSA signature (raw bytes)
/// - Tag 8: ECDSA public key (raw bytes)
/// - Tag 9: Certificate signature (raw bytes, for standard invoices)
///
/// ZATCA TLV format per field:
///   [tag: 1 byte] [length: 1-2 bytes] [value: N bytes]
///
/// For lengths <= 127: single byte.
/// For lengths 128-65535: 0x82 prefix + 2-byte big-endian length.
class ZatcaTlvEncoder {
  /// Encode all TLV fields and return base64 string for QR code
  ///
  /// Tags 1-5 are string values encoded as UTF-8.
  /// Tags 6-9 are binary data passed as base64 strings and decoded to raw bytes.
  String encode({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
    required String invoiceHash,
    required String digitalSignature,
    required String publicKey,
    String? certificateSignature,
  }) {
    final tlvBytes = <int>[];

    // Tag 1: Seller Name (UTF-8)
    _addTlv(tlvBytes, 1, utf8.encode(sellerName));

    // Tag 2: VAT Number
    _addTlv(tlvBytes, 2, utf8.encode(vatNumber));

    // Tag 3: Timestamp (ISO 8601 with timezone)
    _addTlv(tlvBytes, 3, utf8.encode(timestamp.toIso8601String()));

    // Tag 4: Total with VAT (string, 2 decimal places)
    _addTlv(tlvBytes, 4, utf8.encode(totalWithVat.toStringAsFixed(2)));

    // Tag 5: VAT Amount (string, 2 decimal places)
    _addTlv(tlvBytes, 5, utf8.encode(vatAmount.toStringAsFixed(2)));

    // Tag 6: Invoice hash (SHA-256 raw bytes)
    _addTlv(tlvBytes, 6, base64Decode(invoiceHash));

    // Tag 7: ECDSA signature (raw bytes)
    _addTlv(tlvBytes, 7, base64Decode(digitalSignature));

    // Tag 8: Public key (raw bytes)
    _addTlv(tlvBytes, 8, base64Decode(publicKey));

    // Tag 9: Certificate signature (only for standard/B2B invoices)
    if (certificateSignature != null) {
      _addTlv(tlvBytes, 9, base64Decode(certificateSignature));
    }

    return base64Encode(Uint8List.fromList(tlvBytes));
  }

  /// Encode Phase 1 simplified QR (tags 1-5 only, all UTF-8 strings)
  String encodeSimplified({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
  }) {
    final tlvBytes = <int>[];

    _addTlv(tlvBytes, 1, utf8.encode(sellerName));
    _addTlv(tlvBytes, 2, utf8.encode(vatNumber));
    _addTlv(tlvBytes, 3, utf8.encode(timestamp.toIso8601String()));
    _addTlv(tlvBytes, 4, utf8.encode(totalWithVat.toStringAsFixed(2)));
    _addTlv(tlvBytes, 5, utf8.encode(vatAmount.toStringAsFixed(2)));

    return base64Encode(Uint8List.fromList(tlvBytes));
  }

  /// Add a TLV entry to the byte list
  ///
  /// ZATCA uses a simple TLV encoding where:
  /// - Tag is always 1 byte
  /// - Length encoding:
  ///   - 0-127: single byte
  ///   - 128-65535: 0x82 prefix + 2 bytes big-endian
  void _addTlv(List<int> data, int tag, List<int> value) {
    data.add(tag);
    _addLength(data, value.length);
    data.addAll(value);
  }

  /// Encode length using ASN.1-style variable-length encoding
  void _addLength(List<int> data, int length) {
    if (length <= 127) {
      data.add(length);
    } else if (length <= 255) {
      // Short form: 0x81 prefix + 1 byte
      data.add(0x81);
      data.add(length);
    } else {
      // Long form: 0x82 prefix + 2 bytes big-endian
      data.add(0x82);
      data.add((length >> 8) & 0xFF);
      data.add(length & 0xFF);
    }
  }

  /// Decode a base64 TLV string back to its components (for testing/validation)
  ///
  /// Returns a map of tag number to raw byte value.
  Map<int, Uint8List> decode(String base64Tlv) {
    final bytes = base64Decode(base64Tlv);
    final result = <int, Uint8List>{};
    var offset = 0;

    while (offset < bytes.length) {
      if (offset >= bytes.length) break;
      final tag = bytes[offset++];

      // Read length
      final length = _readLength(bytes, offset);
      offset += length.bytesConsumed;

      // Read value
      if (offset + length.value > bytes.length) break;
      final value = Uint8List.fromList(
        bytes.sublist(offset, offset + length.value),
      );
      result[tag] = value;
      offset += length.value;
    }

    return result;
  }

  /// Decode a TLV string and return string values for tags 1-5
  /// and base64-encoded values for tags 6-9
  Map<int, String> decodeToStrings(String base64Tlv) {
    final raw = decode(base64Tlv);
    final result = <int, String>{};

    for (final entry in raw.entries) {
      if (entry.key <= 5) {
        // Tags 1-5 are UTF-8 strings
        result[entry.key] = utf8.decode(entry.value);
      } else {
        // Tags 6-9 are binary, return as base64
        result[entry.key] = base64Encode(entry.value);
      }
    }

    return result;
  }

  /// Read a variable-length integer from the byte array
  _LengthResult _readLength(List<int> bytes, int offset) {
    if (offset >= bytes.length) {
      return const _LengthResult(value: 0, bytesConsumed: 0);
    }

    final first = bytes[offset];
    if (first <= 127) {
      // Short form: single byte
      return _LengthResult(value: first, bytesConsumed: 1);
    } else if (first == 0x81) {
      // 1-byte length follows
      if (offset + 1 >= bytes.length) {
        return const _LengthResult(value: 0, bytesConsumed: 1);
      }
      return _LengthResult(value: bytes[offset + 1], bytesConsumed: 2);
    } else if (first == 0x82) {
      // 2-byte big-endian length follows
      if (offset + 2 >= bytes.length) {
        return const _LengthResult(value: 0, bytesConsumed: 1);
      }
      final length = (bytes[offset + 1] << 8) | bytes[offset + 2];
      return _LengthResult(value: length, bytesConsumed: 3);
    }

    // Fallback: treat as single-byte length
    return _LengthResult(value: first, bytesConsumed: 1);
  }
}

/// Internal helper for length decoding result
class _LengthResult {
  final int value;
  final int bytesConsumed;

  const _LengthResult({required this.value, required this.bytesConsumed});
}
