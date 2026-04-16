/// Web file download utility.
///
/// Creates a browser download via data URI and anchor click.
/// Only works on web platform — guarded by kIsWeb at call site.
library;

import 'dart:convert';

import 'package:web/web.dart' as web;

/// Trigger a file download in the browser.
void downloadTextFile({
  required String content,
  required String filename,
}) {
  final bytes = utf8.encode(content);
  final base64Data = base64Encode(bytes);
  final dataUri = 'data:text/plain;charset=utf-8;base64,$base64Data';

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = dataUri;
  anchor.download = filename;
  anchor.click();
}
