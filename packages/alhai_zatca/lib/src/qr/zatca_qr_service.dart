import 'dart:convert';

import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/qr/zatca_tlv_encoder.dart';
import 'package:alhai_zatca/src/signing/certificate_parser.dart';

/// Service for generating ZATCA-compliant QR codes
///
/// Generates the enhanced Phase 2 QR code content that includes
/// the digital signature and public key (tags 1-9).
///
/// Phase 2 QR codes are base64 TLV-encoded data that must be
/// rendered as a QR code on the printed invoice.
class ZatcaQrService {
  final ZatcaTlvEncoder _encoder;
  final CertificateParser _certParser;

  ZatcaQrService({ZatcaTlvEncoder? encoder, CertificateParser? certParser})
    : _encoder = encoder ?? ZatcaTlvEncoder(),
      _certParser = certParser ?? CertificateParser();

  /// Generate the enhanced Phase 2 QR code data for an invoice
  ///
  /// Requires the invoice hash and digital signature from the signing step.
  /// Extracts the public key from the certificate for tag 8.
  ///
  /// For standard (B2B) invoices, also includes the certificate
  /// signature in tag 9.
  ///
  /// Returns a base64 string suitable for QR code rendering.
  String generateQrData({
    required ZatcaInvoice invoice,
    required String invoiceHash,
    required String digitalSignature,
    required CertificateInfo certificate,
  }) {
    // Extract public key from certificate as base64
    final publicKeyBytes = _certParser.extractPublicKey(
      certificate.certificatePem,
    );
    final publicKeyBase64 = base64Encode(publicKeyBytes);

    // For standard invoices, include certificate signature (tag 9)
    // Tag 9 must be the certificate's signatureValue bytes, NOT the
    // entire certificate DER.
    String? certSignatureBase64;
    if (invoice.isStandard) {
      final sigBytes = _certParser.extractSignatureBytes(
        certificate.certificatePem,
      );
      certSignatureBase64 = base64Encode(sigBytes);
    }

    return _encoder.encode(
      sellerName: invoice.seller.name,
      vatNumber: invoice.seller.vatNumber,
      timestamp: invoice.issueDate,
      totalWithVat: invoice.totalWithVat,
      vatAmount: invoice.totalVatAmount,
      invoiceHash: invoiceHash,
      digitalSignature: digitalSignature,
      publicKey: publicKeyBase64,
      certificateSignature: certSignatureBase64,
    );
  }

  /// Generate a simplified QR code (Phase 1 compatible, tags 1-5)
  ///
  /// Used as fallback or for simplified invoices where only
  /// the basic seller/amount info is needed.
  String generateSimplifiedQr({required ZatcaInvoice invoice}) {
    return _encoder.encodeSimplified(
      sellerName: invoice.seller.name,
      vatNumber: invoice.seller.vatNumber,
      timestamp: invoice.issueDate,
      totalWithVat: invoice.totalWithVat,
      vatAmount: invoice.totalVatAmount,
    );
  }

  /// Generate QR data from raw values (without an invoice model)
  ///
  /// Useful when building QR codes from individual fields
  /// rather than a full ZatcaInvoice object.
  String generateQrDataFromValues({
    required String sellerName,
    required String vatNumber,
    required DateTime timestamp,
    required double totalWithVat,
    required double vatAmount,
    required String invoiceHash,
    required String digitalSignature,
    required String publicKeyBase64,
    String? certificateSignatureBase64,
  }) {
    return _encoder.encode(
      sellerName: sellerName,
      vatNumber: vatNumber,
      timestamp: timestamp,
      totalWithVat: totalWithVat,
      vatAmount: vatAmount,
      invoiceHash: invoiceHash,
      digitalSignature: digitalSignature,
      publicKey: publicKeyBase64,
      certificateSignature: certificateSignatureBase64,
    );
  }

  /// Validate a QR code by decoding and checking required fields
  ///
  /// Returns null if valid, or an error message if invalid.
  String? validateQrData(String base64Qr) {
    try {
      final tags = _encoder.decodeToStrings(base64Qr);

      // Check required tags are present
      for (var tag = 1; tag <= 8; tag++) {
        if (!tags.containsKey(tag) || tags[tag]!.isEmpty) {
          return 'Missing required tag $tag';
        }
      }

      // Tag 1: Seller name must not be empty
      if (tags[1]!.trim().isEmpty) {
        return 'Tag 1 (seller name) is empty';
      }

      // Tag 2: VAT number must be 15 digits starting with 3
      final vat = tags[2]!;
      if (vat.length != 15 || !vat.startsWith('3')) {
        return 'Tag 2 (VAT number) invalid: must be 15 digits starting with 3';
      }

      return null; // Valid
    } catch (e) {
      return 'Failed to decode QR data: $e';
    }
  }
}
