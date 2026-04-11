import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/xml/xml_canonicalizer.dart';

void main() {
  late XmlCanonicalizer canonicalizer;

  setUp(() {
    canonicalizer = XmlCanonicalizer();
  });

  group('XmlCanonicalizer', () {
    // ── canonicalize - basic behavior ────────────────────

    group('canonicalize - basic', () {
      test('canonicalizes a simple element', () {
        const xml = '<root>hello</root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, '<root>hello</root>');
      });

      test('expands empty self-closing elements into start+end tags', () {
        const xml = '<root><child/></root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, '<root><child></child></root>');
      });

      test('expands empty element with attribute', () {
        const xml = '<root><child attr="value"/></root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('<child attr="value"></child>'));
      });

      test('removes XML declaration', () {
        const xml = '<?xml version="1.0" encoding="UTF-8"?><root>x</root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, isNot(contains('<?xml')));
        expect(result, '<root>x</root>');
      });

      test('removes comments per exc-c14n without comments', () {
        const xml = '<root><!-- a comment --><child>v</child></root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, isNot(contains('comment')));
        expect(result, contains('<child>v</child>'));
      });

      test('canonicalizes nested elements preserving structure', () {
        const xml = '<a><b><c>value</c></b></a>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, '<a><b><c>value</c></b></a>');
      });
    });

    // ── canonicalize - namespaces ────────────────────────

    group('canonicalize - namespaces', () {
      test('preserves namespace declaration on root', () {
        const xml = '<root xmlns="http://example.com/ns">x</root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('xmlns="http://example.com/ns"'));
      });

      test('preserves prefixed namespace declarations', () {
        const xml =
            '<root xmlns:ns="http://example.com/ns"><ns:child>v</ns:child></root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('xmlns:ns="http://example.com/ns"'));
        expect(result, contains('<ns:child>v</ns:child>'));
      });

      test('sorts namespace declarations by prefix', () {
        // When multiple namespaces are declared on the same element,
        // they should be sorted by prefix.
        const xml =
            '<root xmlns:z="http://z" xmlns:a="http://a" xmlns:m="http://m">x</root>';
        final result = canonicalizer.canonicalize(xml);

        // 'a' should appear before 'm', and 'm' before 'z'
        final aIdx = result.indexOf('xmlns:a=');
        final mIdx = result.indexOf('xmlns:m=');
        final zIdx = result.indexOf('xmlns:z=');
        expect(aIdx, lessThan(mIdx));
        expect(mIdx, lessThan(zIdx));
      });

      test('handles mixed default and prefixed namespaces', () {
        const xml =
            '<root xmlns="http://default" xmlns:p="http://prefixed">x</root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('xmlns="http://default"'));
        expect(result, contains('xmlns:p="http://prefixed"'));
      });
    });

    // ── canonicalize - attributes ────────────────────────

    group('canonicalize - attributes', () {
      test('escapes special characters in attribute values', () {
        const xml = '<root attr="a &amp; b"></root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('a &amp; b'));
      });

      test('escapes less-than sign in attribute values', () {
        const xml = '<root attr="&lt;value"></root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('&lt;value'));
      });

      test(
        'produces deterministic output for equivalent attribute orderings',
        () {
          // Two equivalent XML docs with different attribute orderings should
          // produce the same canonical form (attributes sorted).
          const xml1 = '<root b="2" a="1" c="3"></root>';
          const xml2 = '<root c="3" a="1" b="2"></root>';
          final result1 = canonicalizer.canonicalize(xml1);
          final result2 = canonicalizer.canonicalize(xml2);
          expect(result1, result2);
        },
      );
    });

    // ── canonicalize - text content ──────────────────────

    group('canonicalize - text content', () {
      test('escapes ampersand in text content', () {
        const xml = '<root>a &amp; b</root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('a &amp; b'));
      });

      test('escapes less-than in text content', () {
        const xml = '<root>&lt;value</root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('&lt;value'));
      });

      test('handles text with whitespace content', () {
        const xml = '<root>  value with spaces  </root>';
        final result = canonicalizer.canonicalize(xml);
        expect(result, contains('value with spaces'));
      });
    });

    // ── canonicalize - determinism ───────────────────────

    group('canonicalize - determinism', () {
      test('same input produces same output', () {
        const xml = '<root><a>1</a><b>2</b></root>';
        final result1 = canonicalizer.canonicalize(xml);
        final result2 = canonicalizer.canonicalize(xml);
        expect(result1, result2);
      });

      test(
        'equivalent XML with different self-closing styles produce same output',
        () {
          const xml1 = '<root><empty/></root>';
          const xml2 = '<root><empty></empty></root>';
          final result1 = canonicalizer.canonicalize(xml1);
          final result2 = canonicalizer.canonicalize(xml2);
          expect(result1, result2);
        },
      );
    });

    // ── canonicalizeElement ──────────────────────────────

    group('canonicalizeElement', () {
      test('finds and canonicalizes a specific element by local name', () {
        const xml =
            '<root><first>one</first><target>target-value</target></root>';
        final result = canonicalizer.canonicalizeElement(xml, 'target');
        expect(result, '<target>target-value</target>');
      });

      test('finds nested element recursively', () {
        const xml =
            '<root><parent><child><target>deep</target></child></parent></root>';
        final result = canonicalizer.canonicalizeElement(xml, 'target');
        expect(result, '<target>deep</target>');
      });

      test('throws ArgumentError when element not found', () {
        const xml = '<root><child>x</child></root>';
        expect(
          () => canonicalizer.canonicalizeElement(xml, 'missing'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    // ── removeSignatureElements ──────────────────────────

    group('removeSignatureElements', () {
      test('removes UBLExtensions elements', () {
        const xml = '''
<Invoice>
  <UBLExtensions>
    <extension>data</extension>
  </UBLExtensions>
  <ID>INV-001</ID>
</Invoice>''';
        final result = canonicalizer.removeSignatureElements(xml);
        expect(result, isNot(contains('UBLExtensions')));
        expect(result, contains('<ID>INV-001</ID>'));
      });

      test('removes Signature elements', () {
        const xml = '''
<Invoice>
  <ID>INV-001</ID>
  <Signature>
    <value>sig-data</value>
  </Signature>
</Invoice>''';
        final result = canonicalizer.removeSignatureElements(xml);
        expect(result, isNot(contains('<Signature>')));
        expect(result, contains('<ID>INV-001</ID>'));
      });

      test('removes both UBLExtensions and Signature together', () {
        const xml = '''
<Invoice>
  <UBLExtensions>x</UBLExtensions>
  <ID>INV-001</ID>
  <Signature>y</Signature>
</Invoice>''';
        final result = canonicalizer.removeSignatureElements(xml);
        expect(result, isNot(contains('UBLExtensions')));
        expect(result, isNot(contains('<Signature>')));
        expect(result, contains('<ID>INV-001</ID>'));
      });

      test('leaves XML unchanged when no signature elements present', () {
        const xml = '<Invoice><ID>INV-001</ID></Invoice>';
        final result = canonicalizer.removeSignatureElements(xml);
        expect(result, contains('<ID>INV-001</ID>'));
      });
    });
  });
}
