import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

// Conditional imports for platform-specific code
import 'connection_native.dart' if (dart.library.html) 'connection_web.dart' as impl;

/// مفتاح التشفير المخزن (يُعيّن من التطبيق عند بدء التشغيل)
String? _encryptionKey;

/// تعيين مفتاح تشفير قاعدة البيانات
/// يجب استدعاؤها قبل [openConnection]
void setDatabaseEncryptionKey(String key) {
  _encryptionKey = key;
}

/// إنشاء اتصال قاعدة البيانات
/// يعمل على جميع المنصات (Android, iOS, Web, Desktop)
QueryExecutor openConnection({String? dbName}) {
  if (kIsWeb) {
    // الويب - استخدام sqlite3.wasm
    return driftDatabase(
      name: dbName ?? 'pos_database',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
        onResult: (result) {
          assert(() {
            debugPrint('Database opened with storage: ${result.chosenImplementation}');
            if (result.missingFeatures.isNotEmpty) {
              debugPrint('Missing features: ${result.missingFeatures}');
            }
            return true;
          }());
        },
      ),
    );
  }

  // Native platforms - مع التشفير
  return impl.openNativeConnection(
    dbName: dbName,
    encryptionKey: _encryptionKey,
  );
}

/// اتصال للاختبارات (في الذاكرة - بدون تشفير)
QueryExecutor openTestConnection() {
  return driftDatabase(name: 'test_database');
}
