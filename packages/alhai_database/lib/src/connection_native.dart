import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// اتصال Native (Android, iOS, Desktop) مع تشفير SQLCipher
///
/// يستخدم sqlcipher_flutter_libs لتشفير قاعدة البيانات at-rest.
/// مفتاح التشفير يجب توفيره عبر [encryptionKey] parameter.
///
/// ⚠️ ملاحظة: sqlcipher_flutter_libs يحل محل sqlite3_flutter_libs تلقائياً.
/// See: https://pub.dev/packages/sqlcipher_flutter_libs
QueryExecutor openNativeConnection({String? dbName, String? encryptionKey}) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'));

    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // تطبيق مفتاح التشفير (SQLCipher)
        if (encryptionKey != null && encryptionKey.isNotEmpty) {
          // Escape single quotes in key to prevent injection
          final safeKey = encryptionKey.replaceAll("'", "''");
          db.execute("PRAGMA key = '$safeKey'");
        }

        // Enable WAL for better performance
        db.execute('PRAGMA journal_mode=WAL');
        db.execute('PRAGMA synchronous=NORMAL');
        db.execute('PRAGMA foreign_keys=ON');
      },
    );
  });
}
