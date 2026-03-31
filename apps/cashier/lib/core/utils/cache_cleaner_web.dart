/// Web-specific cache cleaning utility
/// Uses dart:html which is available in Flutter Web CanvasKit builds
library;

import 'dart:html' as html;

/// Clear all browser storage (IndexedDB, localStorage, sessionStorage, caches)
Future<void> clearAllWebCache() async {
  // Clear localStorage and sessionStorage
  try {
    html.window.localStorage.clear();
  } catch (_) {}

  try {
    html.window.sessionStorage.clear();
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
      html.window.indexedDB!.deleteDatabase(name);
    } catch (_) {}
  }

  // Clear Cache Storage (Service Worker caches)
  try {
    final cacheNames = await html.window.caches!.keys();
    for (final name in cacheNames) {
      await html.window.caches!.delete(name);
    }
  } catch (_) {}

  // Unregister Service Workers
  try {
    final registrations =
        await html.window.navigator.serviceWorker!.getRegistrations();
    for (final reg in registrations) {
      await reg.unregister();
    }
  } catch (_) {}
}

/// Force reload the page
void reloadPage() {
  html.window.location.reload();
}
