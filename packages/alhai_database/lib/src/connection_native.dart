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
    final file = File(
      p.join(dbFolder.path, 'alhai_pos', dbName ?? 'pos_database.sqlite'),
    );

    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // تطبيق مفتاح التشفير (SQLCipher)
        if (encryptionKey != null && encryptionKey.isNotEmpty) {
          // Validate encryption key is hex-only (prevents SQL injection)
          final hexPattern = RegExp(r'^[0-9a-fA-F]+$');
          if (encryptionKey.length < 32 ||
              !hexPattern.hasMatch(encryptionKey)) {
            throw ArgumentError(
              'Encryption key must be at least 32 hex characters',
            );
          }
          db.execute("PRAGMA key = '$encryptionKey'");
        }

        // Enable WAL for better performance and crash safety
        db.execute('PRAGMA journal_mode=WAL');
        db.execute('PRAGMA synchronous=NORMAL');
        db.execute('PRAGMA foreign_keys=ON');
        // Wait 5s instead of failing immediately on database lock
        db.execute('PRAGMA busy_timeout=5000');
        // Reclaim disk space gradually instead of all at once
        db.execute('PRAGMA auto_vacuum=INCREMENTAL');
      },
    );
  });
}
