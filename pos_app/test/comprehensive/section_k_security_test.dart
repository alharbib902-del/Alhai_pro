/// اختبارات قسم K: الأمان
///
/// 5 اختبارات تغطي:
/// - K01: لا بيانات بدون جلسة - SessionManager ترفض الطلبات غير المصادقة
/// - K02: التلاعب بالبيانات - DataIntegrity.verify يفشل عند تعديل البيانات
/// - K03: تنظيف XSS - InputSanitizer يزيل وسوم <script> ومتجهات XSS
/// - K04: لا أسرار في السجلات - SecurityLogger لا يسجل التوكنات/كلمات المرور
/// - K05: تحديد المعدل - الطلب الحادي عشر في الدقيقة يُحظر بواسطة RateLimiter
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/core/security/input_sanitizer.dart';
import 'package:pos_app/core/security/rate_limiter.dart';
import 'package:pos_app/core/security/security_logger.dart';
import 'package:pos_app/core/security/data_integrity.dart';
import 'package:pos_app/core/security/secure_storage_service.dart';
import 'package:pos_app/core/security/session_manager.dart';
import 'package:pos_app/services/sync/sync_service.dart';

import 'fixtures/test_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section K: الأمان', () {
    // ==================================================================
    // K01: لا بيانات بدون جلسة
    // ==================================================================

    test('K01 الجلسة غير المصادقة تُرجع حالة notAuthenticated', () async {
      // استخدام InMemoryStorage لتجنب مشاكل platform channel
      SecureStorageService.setStorage(InMemoryStorage());

      // إنهاء أي جلسة موجودة لضمان حالة نظيفة
      await SessionManager.endSession();

      // التحقق من حالة الجلسة بدون مصادقة
      final status = await SessionManager.checkSession();
      expect(status, SessionStatus.notAuthenticated);

      // isSessionValid يجب أن تُرجع false
      final isValid = await SessionManager.isSessionValid();
      expect(isValid, isFalse);

      // getAccessToken يجب أن تُرجع null
      final token = await SessionManager.getAccessToken();
      expect(token, isNull);
    });

    // ==================================================================
    // K02: التلاعب بالبيانات
    // ==================================================================

    test('K02 التحقق من سلامة البيانات يفشل عند تعديل البيانات', () {
      // تهيئة DataIntegrity
      DataIntegrity.initialize('test-hmac-key-for-integrity');
      DataIntegrity.clear();

      // بيانات أصلية
      final originalData = {
        'saleId': 'sale-001',
        'total': 150.75,
        'currency': currency, // من fixtures
        'items': 3,
      };

      // تسجيل Hash للبيانات الأصلية
      const key = 'sale:sale-001';
      DataIntegrity.registerHash(key, originalData);

      // التحقق بالبيانات الأصلية - يجب أن ينجح
      final validResult = DataIntegrity.verifyIntegrity(key, originalData);
      expect(validResult.isValid, isTrue);

      // بيانات معدّلة (تلاعب بالمبلغ)
      final tamperedData = {
        'saleId': 'sale-001',
        'total': 50.00, // تم تغيير المبلغ!
        'currency': currency,
        'items': 3,
      };

      // التحقق بالبيانات المعدّلة - يجب أن يفشل
      final invalidResult = DataIntegrity.verifyIntegrity(key, tamperedData);
      expect(invalidResult.isValid, isFalse);
      expect(invalidResult.violations, isNotEmpty);
      expect(invalidResult.violations.first, contains('modified'));
    });

    // ==================================================================
    // K03: تنظيف XSS
    // ==================================================================

    test('K03 تنظيف XSS: إزالة وسوم script ومتجهات الهجوم', () {
      // اختبار وسم <script> الكلاسيكي
      const scriptInput = '<script>alert("xss")</script>';
      final scriptResult = InputSanitizer.sanitizeForHtml(scriptInput);
      expect(scriptResult, isNot(contains('<script>')));
      expect(scriptResult, isNot(contains('</script>')));

      // اختبار validate يكتشف XSS
      final validation = InputSanitizer.validate(scriptInput, checkXss: true);
      expect(validation.isValid, isFalse);
      expect(validation.issues, contains('Potential XSS detected'));

      // اختبار javascript: protocol
      const jsProtocol = 'javascript:alert(1)';
      final jsValidation = InputSanitizer.validate(jsProtocol, checkXss: true);
      expect(jsValidation.isValid, isFalse);

      // اختبار أحداث inline مثل onerror
      const onErrorInput = '<img onerror=alert(1) src=x>';
      final onErrorValidation = InputSanitizer.validate(
        onErrorInput,
        checkXss: true,
      );
      expect(onErrorValidation.isValid, isFalse);

      // اختبار iframe
      const iframeInput = '<iframe src="https://evil.com"></iframe>';
      final iframeValidation = InputSanitizer.validate(
        iframeInput,
        checkXss: true,
      );
      expect(iframeValidation.isValid, isFalse);

      // اختبار sanitize العام (moderate) يُهرّب الأقواس الزاوية
      final sanitized = InputSanitizer.sanitize('<script>alert("xss")</script>');
      expect(sanitized, isNot(contains('<')));
      expect(sanitized, isNot(contains('>')));
      expect(sanitized, contains('&lt;'));
      expect(sanitized, contains('&gt;'));
    });

    // ==================================================================
    // K04: لا أسرار في السجلات
    // ==================================================================

    test('K04 سجلات الأمان لا تحتوي على توكنات أو كلمات مرور', () {
      // مسح السجلات السابقة
      SecurityLogger.clear();

      // تسجيل أحداث مع بيانات حساسة
      SecurityLogger.logEvent(
        SecurityEventType.loginSuccess,
        userId: 'user-123',
        metadata: {
          'token': 'secret-access-token-abc123',
          'password': 'my-secret-password',
        },
      );

      SecurityLogger.logOtpSent('+966512345678');

      SecurityLogger.logEvent(
        SecurityEventType.sessionStarted,
        userId: 'user-456',
        phone: '+966599887766',
      );

      // الحصول على السجلات
      final logs = SecurityLogger.getLogs();
      expect(logs, isNotEmpty);
      expect(logs.length, 3);

      // التحقق من أن toString لا يعرض التوكنات/كلمات المرور بشكل مباشر
      // (toString يعرض فقط type, masked phone, details)
      for (final log in logs) {
        final logString = log.toString();
        expect(logString, isNot(contains('secret-access-token-abc123')));
        expect(logString, isNot(contains('my-secret-password')));
      }

      // التحقق من أن الهاتف مخفي (masked) في toString
      final otpLog = logs[1]; // logOtpSent
      final otpString = otpLog.toString();
      // الرقم الكامل لا يجب أن يظهر في النص
      expect(otpString, isNot(contains('+966512345678')));
      // يجب أن يظهر مخفياً (مثال: +966****78)
      expect(otpString, contains('****'));
    });

    // ==================================================================
    // K05: تحديد المعدل
    // ==================================================================

    test('K05 تحديد المعدل: الطلب الحادي عشر يُرفض', () {
      // إعادة تعيين RateLimiter
      RateLimiter.resetAll();

      // إعداد حد 10 طلبات في الدقيقة
      const config = RateLimitConfig(
        maxRequests: 10,
        window: Duration(minutes: 1),
        algorithm: RateLimitAlgorithm.slidingWindow,
      );

      const key = 'test-rate-limit-k05';

      // أول 10 طلبات يجب أن تنجح
      for (var i = 1; i <= 10; i++) {
        final result = RateLimiter.check(key, config);
        expect(result.allowed, isTrue, reason: 'الطلب رقم $i يجب أن يُقبل');
      }

      // الطلب الحادي عشر يجب أن يُرفض
      final result11 = RateLimiter.check(key, config);
      expect(result11.allowed, isFalse);
      expect(result11.remaining, 0);
      expect(result11.retryAfter, isNot(Duration.zero));

      // الطلب الثاني عشر أيضاً يُرفض
      final result12 = RateLimiter.check(key, config);
      expect(result12.allowed, isFalse);

      // التنظيف
      RateLimiter.resetAll();
    });
  });
}
