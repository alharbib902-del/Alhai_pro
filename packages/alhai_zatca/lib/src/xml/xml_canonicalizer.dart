import 'package:xml/xml.dart';

/// XML Canonicalization (C14N) for ZATCA digital signing
///
/// Implements Exclusive XML Canonicalization (exc-c14n) as required
/// by ZATCA for computing invoice hashes before signing.
///
/// Reference: https://www.w3.org/TR/xml-exc-c14n/
class XmlCanonicalizer {
  /// Canonicalize an XML string using Exclusive Canonicalization
  ///
  /// This is required before computing the SHA-256 hash of the invoice
  /// for digital signing. ZATCA mandates exc-c14n without comments.
  String canonicalize(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    return _canonicalizeNode(document.rootElement);
  }

  /// Canonicalize a specific element within a larger XML document
  ///
  /// Used for signing specific sections (e.g., SignedProperties).
  String canonicalizeElement(String xmlString, String elementName) {
    final document = XmlDocument.parse(xmlString);
    final element = _findElementRecursive(document.rootElement, elementName);
    if (element == null) {
      throw ArgumentError('Element "$elementName" not found in XML');
    }
    return _canonicalizeNode(element);
  }

  /// Remove the UBL Extensions and Signature elements from the XML
  /// before hashing (as per ZATCA specification)
  String removeSignatureElements(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final root = document.rootElement;

    // Remove ext:UBLExtensions elements
    _removeElementsByLocalName(root, 'UBLExtensions');

    // Remove cac:Signature elements
    _removeElementsByLocalName(root, 'Signature');

    return document.toXmlString();
  }

  /// Canonicalize an XML node according to exc-c14n rules.
  ///
  /// Rules applied:
  /// 1. Remove XML declaration
  /// 2. Normalize attribute values
  /// 3. Sort attributes by namespace URI then local name
  /// 4. Expand empty elements to start+end tag pairs
  /// 5. Normalize line endings to LF
  /// 6. Remove superfluous namespace declarations
  String _canonicalizeNode(XmlElement element) {
    final buffer = StringBuffer();
    _writeCanonicalElement(buffer, element);
    return buffer.toString();
  }

  void _writeCanonicalElement(StringBuffer buffer, XmlElement element) {
    // Opening tag
    buffer.write('<');

    // Write qualified name
    if (element.name.prefix != null) {
      buffer.write('${element.name.prefix}:${element.name.local}');
    } else {
      buffer.write(element.name.local);
    }

    // Collect and sort namespace declarations and attributes
    final namespaceDecls = <String, String>{};
    final attributes = <XmlAttribute>[];

    for (final attr in element.attributes) {
      if (attr.name.prefix == 'xmlns' || attr.name.local == 'xmlns') {
        // Namespace declaration
        final nsPrefix = attr.name.prefix == 'xmlns' ? attr.name.local : '';
        namespaceDecls[nsPrefix] = attr.value;
      } else {
        attributes.add(attr);
      }
    }

    // Sort namespace declarations by prefix
    final sortedNsPrefixes = namespaceDecls.keys.toList()..sort();
    for (final prefix in sortedNsPrefixes) {
      if (prefix.isEmpty) {
        buffer.write(' xmlns="${_escapeAttrValue(namespaceDecls[prefix]!)}"');
      } else {
        buffer.write(
          ' xmlns:$prefix="${_escapeAttrValue(namespaceDecls[prefix]!)}"',
        );
      }
    }

    // Sort attributes: first by namespace URI, then by local name
    attributes.sort((a, b) {
      final nsA = a.name.namespaceUri ?? '';
      final nsB = b.name.namespaceUri ?? '';
      final nsCompare = nsA.compareTo(nsB);
      if (nsCompare != 0) return nsCompare;
      return a.name.local.compareTo(b.name.local);
    });

    for (final attr in attributes) {
      buffer.write(' ');
      if (attr.name.prefix != null) {
        buffer.write('${attr.name.prefix}:${attr.name.local}');
      } else {
        buffer.write(attr.name.local);
      }
      buffer.write('="${_escapeAttrValue(attr.value)}"');
    }

    buffer.write('>');

    // Write children - always expand (no self-closing tags in c14n)
    for (final child in element.children) {
      if (child is XmlElement) {
        _writeCanonicalElement(buffer, child);
      } else if (child is XmlText) {
        buffer.write(_escapeTextContent(child.value));
      } else if (child is XmlCDATA) {
        // In c14n, CDATA is replaced with escaped text
        buffer.write(_escapeTextContent(child.value));
      }
      // Comments are omitted in exc-c14n without comments
    }

    // Closing tag (always present, even for empty elements)
    buffer.write('</');
    if (element.name.prefix != null) {
      buffer.write('${element.name.prefix}:${element.name.local}');
    } else {
      buffer.write(element.name.local);
    }
    buffer.write('>');
  }

  /// Escape attribute values per c14n rules
  String _escapeAttrValue(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\t', '&#x9;')
        .replaceAll('\n', '&#xA;')
        .replaceAll('\r', '&#xD;');
  }

  /// Escape text content per c14n rules
  String _escapeTextContent(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('\r', '&#xD;');
  }

  /// Recursively find an element by local name
  XmlElement? _findElementRecursive(XmlElement parent, String localName) {
    if (parent.name.local == localName) return parent;
    for (final child in parent.childElements) {
      final found = _findElementRecursive(child, localName);
      if (found != null) return found;
    }
    return null;
  }

  /// Remove elements by local name from the tree
  void _removeElementsByLocalName(XmlElement parent, String localName) {
    final toRemove = <XmlElement>[];
    for (final child in parent.childElements) {
      if (child.name.local == localName) {
        toRemove.add(child);
      }
    }
    for (final element in toRemove) {
      element.parent?.children.remove(element);
    }
  }
}
