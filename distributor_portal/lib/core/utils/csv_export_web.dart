/// Web-specific CSV download utility.
/// Uses package:web + dart:js_interop (replaces deprecated dart:html).
library;

import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Downloads a CSV string as a file in the browser.
void downloadCsv(String csvContent, String filename) {
  final bytes = utf8.encode(csvContent);
  // Wrap the Uint8List in a JSArray<BlobPart> for the Blob constructor.
  final blobParts = <JSAny>[bytes.toJS].toJS;
  final blob = web.Blob(
    blobParts,
    web.BlobPropertyBag(type: 'text/csv;charset=utf-8'),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..setAttribute('download', filename);
  anchor.click();
  web.URL.revokeObjectURL(url);
}
