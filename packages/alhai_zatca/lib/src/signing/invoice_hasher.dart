import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:alhai_zatca/src/xml/xml_canonicalizer.dart';

/// Computes SHA-256 hashes of ZATCA invoices
///
/// The invoice hash is used for:
/// - Digital signature (part of SignedInfo references)
/// - Invoice chaining (PIH - Previous Invoice Hash)
/// - QR code (Tag 8 - invoice hash)
class InvoiceHasher {
  final XmlCanonicalizer _canonicalizer;

  InvoiceHasher({XmlCanonicalizer? canonicalizer})
      : _canonicalizer = canonicalizer ?? XmlCanonicalizer();

  /// Compute the SHA-256 hash of a ZATCA invoice XML
  ///
  /// Process:
  /// 1. Remove UBLExtensions and Signature elements
  /// 2. Canonicalize the remaining XML (exc-c14n)
  /// 3. Compute SHA-256 hash
  /// 4. Return base64-encoded hash
  String computeHash(String invoiceXml) {
    // 1. Strip UBLExtensions and Signature elements
    final stripped = _canonicalizer.removeSignatureElements(invoiceXml);

    // 2. Canonicalize the XML
    final canonical = _canonicalizer.canonicalize(stripped);

    // 3. SHA-256 hash
    final bytes = utf8.encode(canonical);
    final digest = sha256.convert(bytes);

    // 4. Base64 encode the hash
    return base64Encode(digest.bytes);
  }

  /// Compute raw SHA-256 digest bytes (for use in signing)
  List<int> computeDigestBytes(String invoiceXml) {
    final stripped = _canonicalizer.removeSignatureElements(invoiceXml);
    final canonical = _canonicalizer.canonicalize(stripped);
    final bytes = utf8.encode(canonical);
    return sha256.convert(bytes).bytes;
  }

  /// Compute SHA-256 hash of arbitrary string data (base64 encoded)
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// Compute raw SHA-256 digest of arbitrary bytes
  static List<int> hashBytes(List<int> input) {
    return sha256.convert(input).bytes;
  }
}
