/// Web-specific print utility.
/// Uses package:web + dart:js_interop (replaces deprecated dart:html).
library;

import 'package:web/web.dart' as web;

/// Triggers the browser's native print dialog.
void printPage() {
  web.window.print();
}
