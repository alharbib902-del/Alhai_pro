import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/xml/ubl_namespaces.dart';

/// Tests for [UblNamespaces] — the set of XML namespace URIs used by
/// ZATCA Phase 2 UBL Invoice XML.
///
/// These values are set by the OASIS UBL 2.1 / ZATCA E-Invoice
/// specifications and MUST NOT change. The tests here act as a
/// guardrail against accidental edits to the namespace constants.
void main() {
  group('UblNamespaces - UBL 2.1 URIs', () {
    test('has correct UBL 2.1 Invoice namespace URI', () {
      expect(
        UblNamespaces.invoice,
        'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
      );
    });

    test('has correct cac (CommonAggregateComponents) namespace', () {
      expect(
        UblNamespaces.cac,
        'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
      );
    });

    test('has correct cbc (CommonBasicComponents) namespace', () {
      expect(
        UblNamespaces.cbc,
        'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2',
      );
    });

    test('has correct ext (CommonExtensionComponents) namespace', () {
      expect(
        UblNamespaces.ext,
        'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2',
      );
    });
  });

  group('UblNamespaces - signature-related URIs', () {
    test('has correct ds (XML Digital Signature) namespace', () {
      expect(UblNamespaces.ds, 'http://www.w3.org/2000/09/xmldsig#');
    });

    test('has correct xades (XAdES) namespace', () {
      expect(UblNamespaces.xades, 'http://uri.etsi.org/01903/v1.3.2#');
    });

    test('has correct xsi (XML Schema Instance) namespace', () {
      expect(UblNamespaces.xsi, 'http://www.w3.org/2001/XMLSchema-instance');
    });

    test('has sig (CommonSignatureComponents) namespace', () {
      expect(
        UblNamespaces.sig,
        'urn:oasis:names:specification:ubl:schema:xsd:CommonSignatureComponents-2',
      );
    });

    test('has sac (SignatureAggregateComponents) namespace', () {
      expect(
        UblNamespaces.sac,
        'urn:oasis:names:specification:ubl:schema:xsd:SignatureAggregateComponents-2',
      );
    });

    test('has sbc (SignatureBasicComponents) namespace', () {
      expect(
        UblNamespaces.sbc,
        'urn:oasis:names:specification:ubl:schema:xsd:SignatureBasicComponents-2',
      );
    });
  });

  group('UblNamespaces - allPrefixes map', () {
    test('exposes all required UBL namespace prefixes', () {
      const expectedKeys = <String>[
        'xmlns',
        'xmlns:cac',
        'xmlns:cbc',
        'xmlns:ext',
        'xmlns:ds',
        'xmlns:xades',
        'xmlns:sig',
        'xmlns:sac',
        'xmlns:sbc',
      ];

      for (final key in expectedKeys) {
        expect(
          UblNamespaces.allPrefixes.containsKey(key),
          isTrue,
          reason: 'allPrefixes should contain "$key"',
        );
      }
    });

    test('allPrefixes values match the individual constants', () {
      expect(UblNamespaces.allPrefixes['xmlns'], UblNamespaces.invoice);
      expect(UblNamespaces.allPrefixes['xmlns:cac'], UblNamespaces.cac);
      expect(UblNamespaces.allPrefixes['xmlns:cbc'], UblNamespaces.cbc);
      expect(UblNamespaces.allPrefixes['xmlns:ext'], UblNamespaces.ext);
      expect(UblNamespaces.allPrefixes['xmlns:ds'], UblNamespaces.ds);
      expect(UblNamespaces.allPrefixes['xmlns:xades'], UblNamespaces.xades);
      expect(UblNamespaces.allPrefixes['xmlns:sig'], UblNamespaces.sig);
      expect(UblNamespaces.allPrefixes['xmlns:sac'], UblNamespaces.sac);
      expect(UblNamespaces.allPrefixes['xmlns:sbc'], UblNamespaces.sbc);
    });

    test('default xmlns in allPrefixes is the Invoice namespace', () {
      expect(
        UblNamespaces.allPrefixes['xmlns'],
        'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
      );
    });

    test('all URIs in allPrefixes are non-empty strings', () {
      for (final entry in UblNamespaces.allPrefixes.entries) {
        expect(entry.value, isNotEmpty, reason: '${entry.key} is empty');
      }
    });
  });

  group('UblNamespaces - immutability', () {
    test('all URIs are non-empty and stable across calls', () {
      // Reference each field twice to assert they don't somehow mutate
      expect(UblNamespaces.invoice, UblNamespaces.invoice);
      expect(UblNamespaces.cac, UblNamespaces.cac);
      expect(UblNamespaces.cbc, UblNamespaces.cbc);
      expect(UblNamespaces.ext, UblNamespaces.ext);
      expect(UblNamespaces.ds, UblNamespaces.ds);
      expect(UblNamespaces.xades, UblNamespaces.xades);
      expect(UblNamespaces.xsi, UblNamespaces.xsi);
      expect(UblNamespaces.sig, UblNamespaces.sig);
      expect(UblNamespaces.sac, UblNamespaces.sac);
      expect(UblNamespaces.sbc, UblNamespaces.sbc);

      for (final uri in [
        UblNamespaces.invoice,
        UblNamespaces.cac,
        UblNamespaces.cbc,
        UblNamespaces.ext,
        UblNamespaces.ds,
        UblNamespaces.xades,
        UblNamespaces.xsi,
        UblNamespaces.sig,
        UblNamespaces.sac,
        UblNamespaces.sbc,
      ]) {
        expect(uri, isNotEmpty);
      }
    });

    test('UBL URIs follow the OASIS urn pattern', () {
      const prefix = 'urn:oasis:names:specification:ubl:schema:xsd:';
      expect(UblNamespaces.invoice, startsWith(prefix));
      expect(UblNamespaces.cac, startsWith(prefix));
      expect(UblNamespaces.cbc, startsWith(prefix));
      expect(UblNamespaces.ext, startsWith(prefix));
      expect(UblNamespaces.sig, startsWith(prefix));
      expect(UblNamespaces.sac, startsWith(prefix));
      expect(UblNamespaces.sbc, startsWith(prefix));
    });

    test('W3C URIs follow the http://www.w3.org pattern', () {
      expect(UblNamespaces.ds, startsWith('http://www.w3.org/'));
      expect(UblNamespaces.xsi, startsWith('http://www.w3.org/'));
    });
  });
}
