import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

/// ⚠️ تحذير أمني: قاعدة بيانات Web غير مشفرة
///
/// الويب لا يدعم SQLCipher، لذلك البيانات مخزنة بدون تشفير في IndexedDB.
///
/// المخاطر:
/// - يمكن الوصول للبيانات عبر DevTools
/// - البيانات قابلة للاستخراج من المتصفح
///
/// التوصيات:
/// - لا تخزن بيانات حساسة جداً على نسخة الويب
/// - استخدم HTTPS دائماً
/// - فعّل Content Security Policy
/// - اعتبر استخدام تشفير على مستوى التطبيق للبيانات الحساسة
QueryExecutor openNativeConnection({String? dbName}) {
  // تحذير في وضع Debug
  if (kDebugMode) {
    debugPrint('⚠️ WEB DATABASE: Running without encryption. '
        'Sensitive data is accessible via browser DevTools.');
  }

  return driftDatabase(
    name: dbName ?? 'pos_database',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
