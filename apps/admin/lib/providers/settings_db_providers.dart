/// مزودات قاعدة بيانات الإعدادات - Settings DB Providers
///
/// توفر دوال مساعدة لقراءة وكتابة الإعدادات من/إلى قاعدة البيانات
/// مع دعم المزامنة عبر SyncQueue
library;

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show currentStoreIdProvider, syncServiceProvider;

// ============================================================================
// دوال مساعدة لقراءة وكتابة الإعدادات
// ============================================================================

/// قراءة إعداد واحد من قاعدة البيانات
Future<String?> getSettingValue(
  AppDatabase db,
  String storeId,
  String key,
) async {
  final result =
      await (db.select(db.settingsTable)
            ..where((s) => s.storeId.equals(storeId) & s.key.equals(key)))
          .getSingleOrNull();
  return result?.value;
}

/// قراءة جميع إعدادات متجر معين من قاعدة البيانات
Future<Map<String, String>> getAllSettings(
  AppDatabase db,
  String storeId,
) async {
  final settings = await (db.select(
    db.settingsTable,
  )..where((s) => s.storeId.equals(storeId))).get();

  final map = <String, String>{};
  for (final s in settings) {
    map[s.key] = s.value;
  }
  return map;
}

/// قراءة إعدادات معينة بناء على بادئة المفتاح (مثل 'pos_' أو 'printer_')
Future<Map<String, String>> getSettingsByPrefix(
  AppDatabase db,
  String storeId,
  String prefix,
) async {
  final settings = await (db.select(
    db.settingsTable,
  )..where((s) => s.storeId.equals(storeId) & s.key.like('$prefix%'))).get();

  final map = <String, String>{};
  for (final s in settings) {
    map[s.key] = s.value;
  }
  return map;
}

/// حفظ إعداد واحد في قاعدة البيانات (إنشاء أو تحديث)
Future<String> saveSetting(
  AppDatabase db,
  String storeId,
  String key,
  String value,
) async {
  final id = 'setting_${storeId}_$key';

  await db
      .into(db.settingsTable)
      .insertOnConflictUpdate(
        SettingsTableCompanion.insert(
          id: id,
          storeId: storeId,
          key: key,
          value: value,
          updatedAt: DateTime.now(),
        ),
      );

  return id;
}

/// حفظ إعداد مع إضافته لطابور المزامنة
Future<void> saveSettingWithSync({
  required AppDatabase db,
  required String storeId,
  required String key,
  required String value,
  required WidgetRef ref,
}) async {
  final id = await saveSetting(db, storeId, key, value);

  // إضافة للمزامنة
  try {
    final syncService = ref.read(syncServiceProvider);
    await syncService.enqueueUpdate(
      tableName: 'settings',
      recordId: id,
      changes: {
        'id': id,
        'storeId': storeId,
        'key': key,
        'value': value,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  } catch (e) {
    // المزامنة اختيارية - لا نريد أن يفشل الحفظ المحلي بسببها
    if (kDebugMode) {
      debugPrint('خطأ في إضافة الإعداد للمزامنة: $e');
    }
  }
}

/// حفظ مجموعة إعدادات دفعة واحدة مع المزامنة
Future<void> saveSettingsBatch({
  required AppDatabase db,
  required String storeId,
  required Map<String, String> settings,
  required WidgetRef ref,
}) async {
  for (final entry in settings.entries) {
    await saveSettingWithSync(
      db: db,
      storeId: storeId,
      key: entry.key,
      value: entry.value,
      ref: ref,
    );
  }
}

// ============================================================================
// مزودات Riverpod
// ============================================================================

/// مزود لقراءة جميع إعدادات المتجر الحالي
final storeSettingsProvider = FutureProvider.autoDispose<Map<String, String>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return {};

  final db = getIt<AppDatabase>();
  return getAllSettings(db, storeId);
});

/// مزود لقراءة إعدادات بناء على بادئة
final settingsByPrefixProvider = FutureProvider.autoDispose
    .family<Map<String, String>, String>((ref, prefix) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return {};

      final db = getIt<AppDatabase>();
      return getSettingsByPrefix(db, storeId, prefix);
    });

/// مزود لقراءة إعداد واحد
final singleSettingProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, key) async {
      final storeId = ref.watch(currentStoreIdProvider);
      if (storeId == null) return null;

      final db = getIt<AppDatabase>();
      return getSettingValue(db, storeId, key);
    });
