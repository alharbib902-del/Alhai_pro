import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Conditional imports for platform-specific code
import 'connection_native.dart' if (dart.library.html) 'connection_web.dart'
    as impl;

/// مفتاح التشفير المخزن (يُعيّن من التطبيق عند بدء التشغيل)
String? _encryptionKey;

/// تعيين مفتاح تشفير قاعدة البيانات
/// يجب استدعاؤها قبل [openConnection]
void setDatabaseEncryptionKey(String key) {
  _encryptionKey = key;
}

/// إنشاء اتصال قاعدة البيانات
/// يعمل على جميع المنصات (Android, iOS, Web, Desktop)
///
/// On web: Uses OPFS (Origin Private File System) when available for 2-5x
/// better performance over IndexedDB. Falls back to IndexedDB if OPFS is
/// not supported. Existing IndexedDB databases are automatically migrated
/// to OPFS when it becomes available.
///
/// On native: Uses SQLCipher encryption with WAL journal mode.
QueryExecutor openConnection({String? dbName}) {
  // Delegate to platform-specific implementation.
  // On web: connection_web.dart (OPFS with IndexedDB fallback)
  // On native: connection_native.dart (SQLCipher encryption)
  return impl.openNativeConnection(
    dbName: dbName,
    encryptionKey: _encryptionKey,
  );
}

/// اتصال للاختبارات (في الذاكرة - بدون تشفير)
QueryExecutor openTestConnection() {
  return driftDatabase(name: 'test_database');
}
