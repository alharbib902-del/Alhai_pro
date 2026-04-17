/// اختبارات LoginRateLimiter
///
/// لا نستخدم fake_async هنا لأن LoginRateLimiter يقرأ DateTime.now()
/// داخلياً. بدلاً من ذلك، نتلاعب مباشرة بالقيم المكتوبة في
/// InMemoryStorage لمحاكاة مرور الوقت — هذا يعطينا تحكّماً تاماً
/// دون تعقيد حقن ساعة جديدة.
library;

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_auth/alhai_auth.dart';

void main() {
  late InMemoryStorage storage;
  late LoginRateLimiter limiter;

  setUp(() {
    storage = InMemoryStorage();
    limiter = LoginRateLimiter(storage: storage);
  });

  group('LoginRateLimiter', () {
    // ------------------------------------------------------------------
    // 1) أول محاولة → مسموحة مع 4 محاولات متبقية (بعد تسجيل الفشل)
    // ------------------------------------------------------------------
    test('first attempt returns allowed with 5 attempts left, then 4 after failure',
        () async {
      final status = await limiter.checkStatus('user@example.com');
      expect(status, isA<RateLimitAllowed>());
      expect((status as RateLimitAllowed).attemptsLeft, 5);

      // بعد محاولة فاشلة أولى → المتبقي 4
      await limiter.recordFailure('user@example.com');
      final afterOne = await limiter.checkStatus('user@example.com');
      expect(afterOne, isA<RateLimitAllowed>());
      expect((afterOne as RateLimitAllowed).attemptsLeft, 4);
    });

    // ------------------------------------------------------------------
    // 2) 5 محاولات فاشلة → الفحص السادس يُرجع RateLimitLocked
    // ------------------------------------------------------------------
    test('5 failures cause 6th checkStatus to return RateLimitLocked',
        () async {
      const id = 'bad@actor.com';
      for (var i = 0; i < 5; i++) {
        await limiter.recordFailure(id);
      }
      final status = await limiter.checkStatus(id);
      expect(status, isA<RateLimitLocked>());
      final locked = status as RateLimitLocked;
      // القفل مدّته 5 دقائق → المتبقي يجب أن يكون > 4 دقائق < 5
      expect(locked.remaining.inMinutes, inInclusiveRange(4, 5));
      expect(locked.remainingSeconds, greaterThan(0));
    });

    // ------------------------------------------------------------------
    // 3) نجاح بعد محاولتين فاشلتين → العدّاد يُمسح
    // ------------------------------------------------------------------
    test('success after 2 failures clears the counter', () async {
      const id = 'user@test.com';
      await limiter.recordFailure(id);
      await limiter.recordFailure(id);

      // قبل النجاح: المتبقي 3
      final before = await limiter.checkStatus(id) as RateLimitAllowed;
      expect(before.attemptsLeft, 3);

      await limiter.recordSuccess(id);

      // بعد النجاح: عدّاد مُعاد إلى 5 (لا توجد حالة مخزّنة)
      final after = await limiter.checkStatus(id) as RateLimitAllowed;
      expect(after.attemptsLeft, 5);
    });

    // ------------------------------------------------------------------
    // 4) انتهاء النافذة → محاولة فاشلة بعد 16 دقيقة تبدأ نافذة جديدة
    //
    // نتلاعب بالتخزين مباشرة لمحاكاة مرور الوقت: نُعدّل firstAttemptAt
    // إلى قبل 16 دقيقة، ثم نسجّل فشلاً ونتحقّق من أن العدّاد بدأ من 1.
    // ------------------------------------------------------------------
    test('window expiry: failure after 16 minutes starts fresh window',
        () async {
      const id = 'slow@attacker.com';

      // محاولتان فاشلتان
      await limiter.recordFailure(id);
      await limiter.recordFailure(id);

      // نتلاعب بالتخزين: نُزيح firstAttemptAt إلى قبل 16 دقيقة
      final key = _rateLimitKey(id);
      final raw = await storage.read(key: key);
      expect(raw, isNotNull);
      final entry = jsonDecode(raw!) as Map<String, dynamic>;
      entry['firstAttemptAt'] = DateTime.now()
          .subtract(const Duration(minutes: 16))
          .toIso8601String();
      await storage.write(key: key, value: jsonEncode(entry));

      // فشل جديد → النافذة الماضية انتهت → العدّاد = 1
      await limiter.recordFailure(id);
      final status = await limiter.checkStatus(id) as RateLimitAllowed;
      // 5 - 1 = 4 محاولات متبقية (نافذة جديدة)
      expect(status.attemptsLeft, 4);
    });

    // ------------------------------------------------------------------
    // 5) تطبيع المعرّف: "A@X.com"، " a@x.com "، "a@x.com" تعامَل كواحد
    // ------------------------------------------------------------------
    test('identifier normalization: case/whitespace/hyphen variants unify',
        () async {
      await limiter.recordFailure('A@X.com');
      await limiter.recordFailure(' a@x.com ');
      await limiter.recordFailure('a@x.com');

      // الثلاث كلها مُسجَّلة على نفس المعرّف → المتبقي = 5 - 3 = 2
      final s1 = await limiter.checkStatus('a@x.com') as RateLimitAllowed;
      expect(s1.attemptsLeft, 2);

      // أيضاً مع رقم هاتف: شرطات ومسافات يجب أن تُزال
      await limiter.recordFailure('+966-50 123 4567');
      await limiter.recordFailure('+966501234567');
      final s2 = await limiter.checkStatus('+966 50-1234567')
          as RateLimitAllowed;
      // 2 فشلين على نفس الرقم المُطبَّع
      expect(s2.attemptsLeft, 3);
    });
  });
}

/// مفتاح التخزين المُستخدم داخلياً في LoginRateLimiter.
/// مكرَّر هنا لأن _key و _kKeyPrefix خاصّان بالمكتبة.
String _rateLimitKey(String id) {
  final normalized = id
      .trim()
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('-', '');
  return 'login_rate_limit_$normalized';
}
