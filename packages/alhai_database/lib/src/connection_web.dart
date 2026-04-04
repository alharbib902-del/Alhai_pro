import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

/// Web database connection using OPFS (Origin Private File System) with
/// IndexedDB fallback.
///
/// OPFS provides 2-5x better performance than IndexedDB for synchronous
/// file system operations required by sqlite3.
///
/// Storage priority (drift automatically picks the best available):
///   1. opfsShared  - OPFS via shared worker (best: cross-tab sync + fast)
///   2. opfsLocks   - OPFS via dedicated workers with Atomics (requires COOP/COEP headers)
///   3. sharedIndexedDb - IndexedDB in shared worker (cross-tab sync)
///   4. unsafeIndexedDb - IndexedDB without worker (no multi-tab safety)
///   5. inMemory    - No persistence (last resort)
///
/// Security note: Web databases are NOT encrypted (no SQLCipher support).
/// Recommendations:
///   - Do not store highly sensitive data on the web version
///   - Always use HTTPS
///   - Enable Content Security Policy
QueryExecutor openNativeConnection({String? dbName, String? encryptionKey}) {
  final name = dbName ?? 'pos_database';

  if (kDebugMode) {
    debugPrint('WEB DATABASE: Running without encryption. '
        'Sensitive data is accessible via browser DevTools.');
  }

  // Use WasmDatabase.open() directly instead of driftDatabase() to enable:
  // - moveExistingIndexedDbToOpfs: migrate existing IndexedDB data to OPFS
  // - Better control over storage implementation selection
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: name,
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
      // Note: moveExistingIndexedDbToOpfs was removed in drift 2.x.
      // Drift now handles IndexedDB-to-OPFS migration automatically.
    );

    if (kDebugMode) {
      final impl = result.chosenImplementation;
      final isOpfs = impl == WasmStorageImplementation.opfsShared ||
          impl == WasmStorageImplementation.opfsLocks;
      debugPrint(
          'DB Storage: $impl ${isOpfs ? "(OPFS - optimal)" : "(fallback)"}');

      if (result.missingFeatures.isNotEmpty) {
        debugPrint('Missing browser features: ${result.missingFeatures}');
      }

      // Warn if using a suboptimal storage backend
      if (impl == WasmStorageImplementation.unsafeIndexedDb) {
        debugPrint(
          'WARNING: Using unsafeIndexedDb - no multi-tab safety. '
          'Data may be corrupted if app is open in multiple tabs.',
        );
      } else if (impl == WasmStorageImplementation.inMemory) {
        debugPrint(
          'WARNING: Using in-memory storage - data will be lost on page reload!',
        );
      }
    }

    // Request persistent storage to prevent browser eviction under storage pressure
    _requestPersistentStorage();

    // Check storage quota and warn if usage is high
    _checkStorageQuota();

    return result.resolvedExecutor;
  }));
}

/// Request persistent storage via navigator.storage.persist().
/// This prevents the browser from automatically evicting the database
/// when the device is under storage pressure.
/// Best-effort: silently ignored if unsupported or denied.
void _requestPersistentStorage() {
  try {
    final navigator = globalContext['navigator'] as JSObject?;
    if (navigator == null) return;

    final storage = navigator['storage'] as JSObject?;
    if (storage == null) return;

    final persistResult = storage.callMethod<JSAny?>('persist'.toJS);
    if (persistResult == null) return;

    // persist() returns a Promise<boolean>
    final promise = persistResult as JSPromise;
    promise.toDart.then((JSAny? value) {
      final granted = (value as JSBoolean?)?.toDart ?? false;
      if (kDebugMode) {
        debugPrint(
          granted
              ? 'Storage: persistent storage GRANTED - DB safe from eviction'
              : 'Storage: persistent storage DENIED - DB may be evicted under pressure',
        );
      }
    }).catchError((Object e) {
      if (kDebugMode) {
        debugPrint('Storage: persist() failed: $e');
      }
    });
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Storage: persist() not supported: $e');
    }
  }
}

/// Check storage quota usage and warn if above 80%.
/// Best-effort: silently ignored if unsupported.
void _checkStorageQuota() {
  try {
    final navigator = globalContext['navigator'] as JSObject?;
    if (navigator == null) return;

    final storage = navigator['storage'] as JSObject?;
    if (storage == null) return;

    final estimateResult = storage.callMethod<JSAny?>('estimate'.toJS);
    if (estimateResult == null) return;

    // estimate() returns a Promise<{usage: number, quota: number}>
    final promise = estimateResult as JSPromise;
    promise.toDart.then((JSAny? value) {
      if (value == null) return;
      final estimate = value as JSObject;
      final usage = (estimate['usage'] as JSNumber?)?.toDartDouble;
      final quota = (estimate['quota'] as JSNumber?)?.toDartDouble;

      if (usage != null && quota != null && quota > 0) {
        final usagePercent = (usage / quota * 100).toStringAsFixed(1);
        final usageMB = (usage / 1024 / 1024).toStringAsFixed(1);
        final quotaMB = (quota / 1024 / 1024).toStringAsFixed(0);

        if (usage / quota > 0.8) {
          // Always warn about high storage usage, even in release mode
          debugPrint(
            'WARNING: Storage usage high: $usageMB MB / $quotaMB MB ($usagePercent%) '
            '- consider clearing old data',
          );
        } else if (kDebugMode) {
          debugPrint('Storage: $usageMB MB / $quotaMB MB ($usagePercent%)');
        }
      }
    }).catchError((Object e) {
      if (kDebugMode) {
        debugPrint('Storage: estimate() failed: $e');
      }
    });
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Storage: estimate() not supported: $e');
    }
  }
}
