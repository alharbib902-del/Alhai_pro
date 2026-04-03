import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/signing/certificate_parser.dart';
import 'package:alhai_zatca/src/signing/ecdsa_signer.dart';
import 'package:alhai_zatca/src/signing/invoice_hasher.dart';
import 'package:alhai_zatca/src/xml/ubl_namespaces.dart';
import 'package:alhai_zatca/src/xml/xml_canonicalizer.dart';

/// XAdES-BES digital signer for ZATCA invoices
///
/// Signs the UBL XML document according to ZATCA Phase 2 requirements:
/// - XAdES-BES enveloped signature
/// - SHA-256 digest
/// - ECDSA signing with secp256k1 key
class XadesSigner {
  final InvoiceHasher _hasher;
  final EcdsaSigner _ecdsaSigner;
  final XmlCanonicalizer _canonicalizer;
  final CertificateParser _certParser;

  XadesSigner({
    InvoiceHasher? hasher,
    EcdsaSigner? ecdsaSigner,
    XmlCanonicalizer? canonicalizer,
    CertificateParser? certParser,
  })  : _hasher = hasher ?? InvoiceHasher(),
        _ecdsaSigner = ecdsaSigner ?? EcdsaSigner(),
        _canonicalizer = canonicalizer ?? XmlCanonicalizer(),
        _certParser = certParser ?? CertificateParser();

  /// Sign a UBL invoice XML string with XAdES-BES enveloped signature
  ///
  /// Returns the complete signed XML with the Signature element embedded.
  ///
  /// Steps:
  /// 1. Compute invoice hash (SHA-256 of canonicalized XML without signature)
  /// 2. Build SignedProperties (signing time, cert digest, cert issuer)
  /// 3. Compute SignedProperties hash
  /// 4. Build SignedInfo (references to invoice hash and signed properties)
  /// 5. Compute SignedInfo hash and sign with ECDSA
  /// 6. Embed the Signature element in UBLExtensions
  String sign({
    required String invoiceXml,
    required CertificateInfo certificate,
    DateTime? signingTime,
  }) {
    final signTime = signingTime ?? DateTime.now().toUtc();

    // Parse certificate to get issuer, serial, etc.
    final certInfo = _certParser.parseCertificate(certificate.certificatePem);
    final certDigest =
        _certParser.computeCertificateDigest(certificate.certificatePem);
    final certIssuer = certInfo['issuerName'] as String;
    final certSerialNumber = certInfo['serialNumber'] as String;

    // 1. Compute the invoice body hash (without UBLExtensions and Signature)
    final invoiceDigest = _hasher.computeHash(invoiceXml);

    // 2. Build SignedProperties XML
    final signedPropertiesXml = _buildSignedProperties(
      signingTime: signTime,
      certDigest: certDigest,
      certIssuer: certIssuer,
      certSerialNumber: certSerialNumber,
    );

    // 3. Compute SignedProperties digest
    final signedPropsCanonical = _canonicalizer.canonicalize(signedPropertiesXml);
    final signedPropsDigest =
        base64Encode(sha256.convert(utf8.encode(signedPropsCanonical)).bytes);

    // 4. Build SignedInfo XML
    final signedInfoXml = _buildSignedInfo(
      invoiceDigest: invoiceDigest,
      signedPropertiesDigest: signedPropsDigest,
    );

    // 5. Canonicalize and sign SignedInfo
    final signedInfoCanonical = _canonicalizer.canonicalize(signedInfoXml);
    final signedInfoDigestBytes =
        sha256.convert(utf8.encode(signedInfoCanonical)).bytes;

    final signatureValue = _ecdsaSigner.sign(
      digest: Uint8List.fromList(signedInfoDigestBytes),
      privateKeyPem: certificate.privateKeyPem,
    );

    // 6. Build the complete ds:Signature element
    final certBase64 = _extractCertBase64(certificate.certificatePem);

    final signatureXml = _buildSignatureElement(
      signedInfoXml: signedInfoXml,
      signatureValue: signatureValue,
      signedPropertiesXml: signedPropertiesXml,
      certificateBase64: certBase64,
    );

    // 7. Embed the signature in UBLExtensions
    return _embedSignature(invoiceXml, signatureXml);
  }

  /// Compute the SHA-256 hash of the invoice (without signature)
  ///
  /// This is the hash that gets embedded in the QR code (Tag 8)
  /// and used for invoice chaining (PIH).
  String computeInvoiceHash(String invoiceXml) {
    return _hasher.computeHash(invoiceXml);
  }

  /// Build the SignedProperties element for XAdES
  String _buildSignedProperties({
    required DateTime signingTime,
    required String certDigest,
    required String certIssuer,
    required String certSerialNumber,
  }) {
    final timeStr = _formatSigningTime(signingTime);

    return '''<xades:SignedProperties xmlns:xades="${UblNamespaces.xades}" Id="xadesSignedProperties">'''
        '''<xades:SignedSignatureProperties>'''
        '''<xades:SigningTime>$timeStr</xades:SigningTime>'''
        '''<xades:SigningCertificate>'''
        '''<xades:Cert>'''
        '''<xades:CertDigest>'''
        '''<ds:DigestMethod xmlns:ds="${UblNamespaces.ds}" Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"></ds:DigestMethod>'''
        '''<ds:DigestValue xmlns:ds="${UblNamespaces.ds}">$certDigest</ds:DigestValue>'''
        '''</xades:CertDigest>'''
        '''<xades:IssuerSerial>'''
        '''<ds:X509IssuerName xmlns:ds="${UblNamespaces.ds}">$certIssuer</ds:X509IssuerName>'''
        '''<ds:X509SerialNumber xmlns:ds="${UblNamespaces.ds}">$certSerialNumber</ds:X509SerialNumber>'''
        '''</xades:IssuerSerial>'''
        '''</xades:Cert>'''
        '''</xades:SigningCertificate>'''
        '''</xades:SignedSignatureProperties>'''
        '''</xades:SignedProperties>''';
  }

  /// Build the SignedInfo element
  String _buildSignedInfo({
    required String invoiceDigest,
    required String signedPropertiesDigest,
  }) {
    return '''<ds:SignedInfo xmlns:ds="${UblNamespaces.ds}">'''
        '''<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2006/12/xml-c14n11"></ds:CanonicalizationMethod>'''
        '''<ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#ecdsa-sha256"></ds:SignatureMethod>'''
        '''<ds:Reference Id="invoiceSignedData" URI="">'''
        '''<ds:Transforms>'''
        '''<ds:Transform Algorithm="http://www.w3.org/TR/1999/REC-xpath-19991116">'''
        '''<ds:XPath>not(//ancestor-or-self::ext:UBLExtensions)</ds:XPath>'''
        '''</ds:Transform>'''
        '''<ds:Transform Algorithm="http://www.w3.org/2006/12/xml-c14n11"></ds:Transform>'''
        '''</ds:Transforms>'''
        '''<ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"></ds:DigestMethod>'''
        '''<ds:DigestValue>$invoiceDigest</ds:DigestValue>'''
        '''</ds:Reference>'''
        '''<ds:Reference Type="http://www.w3.org/2000/09/xmldsig#SignatureProperties" URI="#xadesSignedProperties">'''
        '''<ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"></ds:DigestMethod>'''
        '''<ds:DigestValue>$signedPropertiesDigest</ds:DigestValue>'''
        '''</ds:Reference>'''
        '''</ds:SignedInfo>''';
  }

  /// Build the complete ds:Signature element
  String _buildSignatureElement({
    required String signedInfoXml,
    required String signatureValue,
    required String signedPropertiesXml,
    required String certificateBase64,
  }) {
    return '''<ds:Signature xmlns:ds="${UblNamespaces.ds}" Id="signature">'''
        '''$signedInfoXml'''
        '''<ds:SignatureValue>$signatureValue</ds:SignatureValue>'''
        '''<ds:KeyInfo>'''
        '''<ds:X509Data>'''
        '''<ds:X509Certificate>$certificateBase64</ds:X509Certificate>'''
        '''</ds:X509Data>'''
        '''</ds:KeyInfo>'''
        '''<ds:Object>'''
        '''<xades:QualifyingProperties xmlns:xades="${UblNamespaces.xades}" Target="signature">'''
        '''$signedPropertiesXml'''
        '''</xades:QualifyingProperties>'''
        '''</ds:Object>'''
        '''</ds:Signature>''';
  }

  /// Embed the ds:Signature XML into the UBLExtensions of the invoice
  String _embedSignature(String invoiceXml, String signatureXml) {
    // Look for the signature placeholder in ext:UBLExtensions
    // Pattern: <ext:ExtensionContent>SET_DURING_SIGNING</ext:ExtensionContent>
    // or an existing empty signature extension
    final sigExtensionContent = '''<ext:ExtensionContent>'''
        '''<sig:UBLDocumentSignatures xmlns:sig="${UblNamespaces.sig}" '''
        '''xmlns:sac="${UblNamespaces.sac}" '''
        '''xmlns:sbc="${UblNamespaces.sbc}">'''
        '''<sac:SignatureInformation>'''
        '''<cbc:ID xmlns:cbc="${UblNamespaces.cbc}">urn:oasis:names:specification:ubl:signature:Invoice</cbc:ID>'''
        '''<sbc:ReferencedSignatureID>urn:oasis:names:specification:ubl:signature:1</sbc:ReferencedSignatureID>'''
        '''$signatureXml'''
        '''</sac:SignatureInformation>'''
        '''</sig:UBLDocumentSignatures>'''
        '''</ext:ExtensionContent>''';

    // Replace the placeholder
    String result = invoiceXml;
    if (invoiceXml.contains('SET_DURING_SIGNING')) {
      result = invoiceXml.replaceFirst(
        RegExp(r'<ext:ExtensionContent>\s*SET_DURING_SIGNING\s*</ext:ExtensionContent>'),
        sigExtensionContent,
      );
    } else if (invoiceXml.contains('SIGN_PLACEHOLDER')) {
      result = invoiceXml.replaceFirst(
        RegExp(r'<ext:ExtensionContent>\s*SIGN_PLACEHOLDER\s*</ext:ExtensionContent>'),
        sigExtensionContent,
      );
    } else {
      // Try to insert after the first ext:UBLExtension opening
      final extensionInsertPoint =
          RegExp(r'(<ext:UBLExtensions>[\s\S]*?<ext:UBLExtension>)')
              .firstMatch(result);
      if (extensionInsertPoint != null) {
        final insertPos = extensionInsertPoint.end;
        result = '${result.substring(0, insertPos)}'
            '$sigExtensionContent'
            '${result.substring(insertPos)}';
      }
    }

    return result;
  }

  /// Extract base64 certificate body from PEM (without headers)
  String _extractCertBase64(String pem) {
    return pem
        .replaceAll(RegExp(r'-----BEGIN [A-Z\s]+-----'), '')
        .replaceAll(RegExp(r'-----END [A-Z\s]+-----'), '')
        .replaceAll(RegExp(r'\s'), '');
  }

  /// Format signing time as ISO 8601 for XAdES
  String _formatSigningTime(DateTime time) {
    return '${time.toUtc().toIso8601String().split('.')[0]}Z';
  }
}
