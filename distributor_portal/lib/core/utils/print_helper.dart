/// Platform-safe print helper.
///
/// Uses conditional import to call window.print() on web
/// and no-op on native (for testability).
library;

import 'print_helper_stub.dart'
    if (dart.library.js_interop) 'print_helper_web.dart'
    as impl;

void printPage() => impl.printPage();
