/// UBL 2.1 XML namespace constants used throughout ZATCA invoice generation
///
/// Reference: OASIS UBL 2.1 / ZATCA E-Invoice XML specification
class UblNamespaces {
  const UblNamespaces._();

  /// UBL Invoice namespace
  static const String invoice =
      'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';

  /// Common Aggregate Components
  static const String cac =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';

  /// Common Basic Components
  static const String cbc =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';

  /// Common Extension Components
  static const String ext =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2';

  /// XML Digital Signature namespace
  static const String ds = 'http://www.w3.org/2000/09/xmldsig#';

  /// XAdES namespace
  static const String xades = 'http://uri.etsi.org/01903/v1.3.2#';

  /// XML Schema Instance
  static const String xsi = 'http://www.w3.org/2001/XMLSchema-instance';

  /// ZATCA extension namespace (for QR code, PIH, etc.)
  static const String sig =
      'urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2';

  /// Signature Aggregate Components
  static const String sac =
      'urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2';

  /// Signature Basic Components
  static const String sbc =
      'urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2';

  /// All namespace prefixes as a map (for XML builder)
  static const Map<String, String> allPrefixes = {
    'xmlns': invoice,
    'xmlns:cac': cac,
    'xmlns:cbc': cbc,
    'xmlns:ext': ext,
    'xmlns:ds': ds,
    'xmlns:xades': xades,
    'xmlns:sig': sig,
    'xmlns:sac': sac,
    'xmlns:sbc': sbc,
  };
}
