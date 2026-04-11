/// Web-specific cache cleaning utility
/// Uses package:web + dart:js_interop (replaces deprecated dart:html)
library;

import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Clear all browser storage (IndexedDB, localStorage, sessionStorage, caches)
Future<void> clearAllWebCache() async {
  // Clear localStorage and sessionStorage
  try {
    web.window.localStorage.clear();
  } catch (_) {}

  try {
    web.window.sessionStorage.clear();
  } catch (_) {}

  // Clear IndexedDB databases - use known database names
  // (getDatabaseNames is not available in all Dart/browser versions)
  final knownDbs = [
    'drift_db',
    'alhai_db',
    '/drift/worker',
    'drift_worker',
    'moor_databases',
    'keyvaluepairs',
  ];
  for (final name in knownDbs) {
    try {
      web.window.indexedDB.deleteDatabase(name);
    } catch (_) {}
  }

  // Clear Cache Storage (Service Worker caches)
  try {
    final cacheStorage = web.window.caches;
    final cacheNames = (await cacheStorage.keys().toDart).toDart;
    for (final name in cacheNames) {
      await cacheStorage.delete(name.toDart).toDart;
    }
  } catch (_) {}

  // Unregister Service Workers
  try {
    final registrations = await web.window.navigator.serviceWorker
        .getRegistrations()
        .toDart;
    for (final reg in registrations.toDart) {
      await reg.unregister().toDart;
    }
  } catch (_) {}
}

/// Force reload the page
void reloadPage() {
  web.window.location.reload();
}
