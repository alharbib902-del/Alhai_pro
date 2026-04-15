/// Opens a URL in a new browser tab (web-only).
library;

export 'open_url_stub.dart'
    if (dart.library.js_interop) 'open_url_web.dart';
