/// خدمة مراقبة الأعطال - Crashlytics Service
///
/// تُدير تقارير الأعطال والأخطاء في الإنتاج
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

// ============================================================================
// CRASHLYTICS SERVICE
// ============================================================================

/// خدمة Firebase Crashlytics
class CrashlyticsService {
  static FirebaseCrashlytics? _instance;
  
  /// تهيئة Crashlytics
  static Future<void> initialize() async {
    if (kIsWeb || kDebugMode) {
      // لا نفعل Crashlytics على الويب أو في وضع التطوير
      return;
    }
    
    _instance = FirebaseCrashlytics.instance;
    
    // تفعيل جمع تقارير الأعطال
    await _instance!.setCrashlyticsCollectionEnabled(true);
    
    // التقاط أخطاء Flutter
    FlutterError.onError = (errorDetails) {
      _instance!.recordFlutterFatalError(errorDetails);
    };
    
    // التقاط أخطاء async
    PlatformDispatcher.instance.onError = (error, stack) {
      _instance!.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  /// تسجيل خطأ غير مميت
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    if (_instance == null) return;
    
    await _instance!.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }
  
  /// تسجيل رسالة
  static Future<void> log(String message) async {
    if (_instance == null) return;
    await _instance!.log(message);
  }
  
  /// تعيين معرف المستخدم
  static Future<void> setUserId(String userId) async {
    if (_instance == null) return;
    await _instance!.setUserIdentifier(userId);
  }
  
  /// تعيين خاصية مخصصة
  static Future<void> setCustomKey(String key, dynamic value) async {
    if (_instance == null) return;
    await _instance!.setCustomKey(key, value.toString());
  }
  
  /// تعيين معلومات المتجر
  static Future<void> setStoreInfo({
    required String storeId,
    required String storeName,
  }) async {
    await setCustomKey('store_id', storeId);
    await setCustomKey('store_name', storeName);
  }
  
  /// محاكاة عطل للاختبار
  static void testCrash() {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Crashlytics test crash skipped in debug mode');
      return;
    }
    _instance?.crash();
  }
}

// ============================================================================
// ERROR HANDLER WRAPPER
// ============================================================================

/// غلاف لمعالجة الأخطاء مع Crashlytics
class ErrorHandler {
  /// تشغيل كود مع معالجة الأخطاء
  static Future<T?> runWithErrorHandling<T>(
    Future<T> Function() action, {
    String? context,
    T? defaultValue,
  }) async {
    try {
      return await action();
    } catch (e, stack) {
      await CrashlyticsService.recordError(
        e,
        stack,
        reason: context,
      );
      return defaultValue;
    }
  }
  
  /// تشغيل كود sync مع معالجة الأخطاء
  static T? runSyncWithErrorHandling<T>(
    T Function() action, {
    String? context,
    T? defaultValue,
  }) {
    try {
      return action();
    } catch (e, stack) {
      CrashlyticsService.recordError(
        e,
        stack,
        reason: context,
      );
      return defaultValue;
    }
  }
}
