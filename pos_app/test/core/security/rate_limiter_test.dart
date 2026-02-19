import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/rate_limiter.dart';

void main() {
  setUp(() {
    RateLimiter.resetAll();
  });

  group('RateLimiter', () {
    group('check - Sliding Window', () {
      test('يسمح بالطلبات ضمن الحد', () {
        const config = RateLimitConfig(
          maxRequests: 5,
          window: Duration(minutes: 1),
        );

        for (var i = 0; i < 5; i++) {
          final result = RateLimiter.check('user:1', config);
          expect(result.allowed, isTrue);
          expect(result.remaining, equals(5 - i - 1));
        }
      });

      test('يرفض الطلبات فوق الحد', () {
        const config = RateLimitConfig(
          maxRequests: 3,
          window: Duration(minutes: 1),
        );

        // استهلاك الحد
        for (var i = 0; i < 3; i++) {
          RateLimiter.check('user:2', config);
        }

        // الطلب الرابع يجب أن يُرفض
        final result = RateLimiter.check('user:2', config);
        expect(result.allowed, isFalse);
        expect(result.remaining, equals(0));
      });

      test('يعيد retryAfter عند الرفض', () {
        const config = RateLimitConfig(
          maxRequests: 1,
          window: Duration(minutes: 1),
        );

        RateLimiter.check('user:3', config);
        final result = RateLimiter.check('user:3', config);

        expect(result.allowed, isFalse);
        expect(result.retryAfter.inSeconds, greaterThan(0));
      });
    });

    group('check - Token Bucket', () {
      test('يسمح بـ burst', () {
        const config = RateLimitConfig(
          maxRequests: 10,
          window: Duration(minutes: 1),
          algorithm: RateLimitAlgorithm.tokenBucket,
          burstMultiplier: 1.5,
        );

        // يجب أن يسمح بـ 15 طلب (10 * 1.5)
        int allowed = 0;
        for (var i = 0; i < 20; i++) {
          final result = RateLimiter.check('user:4', config);
          if (result.allowed) allowed++;
        }

        expect(allowed, equals(15));
      });
    });

    group('blocking', () {
      test('يحظر بعد تجاوزات متكررة', () {
        const config = RateLimitConfig(
          maxRequests: 1,
          window: Duration(minutes: 1),
          blockOnExceed: true,
        );

        // 3 تجاوزات
        for (var i = 0; i < 4; i++) {
          RateLimiter.check('user:5', config);
        }
        for (var i = 0; i < 3; i++) {
          RateLimiter.check('user:5', config);
        }

        final result = RateLimiter.check('user:5', config);
        expect(result.allowed, isFalse);
        expect(result.message, contains('Blocked'));
      });
    });

    group('reset', () {
      test('يعيد تعيين مفتاح معين', () {
        const config = RateLimitConfig(
          maxRequests: 2,
          window: Duration(minutes: 1),
        );

        RateLimiter.check('user:6', config);
        RateLimiter.check('user:6', config);

        RateLimiter.reset('user:6');

        final result = RateLimiter.check('user:6', config);
        expect(result.allowed, isTrue);
        expect(result.remaining, equals(1));
      });
    });

    group('getStatus', () {
      test('يعيد حالة المفتاح', () {
        const config = RateLimitConfig(
          maxRequests: 1,
          window: Duration(minutes: 1),
          blockOnExceed: true,
        );

        RateLimiter.check('user:7', config);

        final status = RateLimiter.getStatus('user:7');
        expect(status['isBlocked'], isFalse);
        expect(status['violationCount'], equals(0));
      });
    });

    group('listeners', () {
      test('يُعلم المستمعين', () {
        const config = RateLimitConfig(
          maxRequests: 1,
          window: Duration(minutes: 1),
        );

        String? notifiedKey;
        RateLimitResult? notifiedResult;

        RateLimiter.addListener((key, result) {
          notifiedKey = key;
          notifiedResult = result;
        });

        RateLimiter.check('user:8', config);

        expect(notifiedKey, equals('user:8'));
        expect(notifiedResult?.allowed, isTrue);
      });
    });
  });

  group('RateLimitConfig', () {
    test('otp config صحيح', () {
      expect(RateLimitConfig.otp.maxRequests, equals(3));
      expect(RateLimitConfig.otp.window, equals(const Duration(minutes: 15)));
      expect(RateLimitConfig.otp.blockOnExceed, isTrue);
    });

    test('login config صحيح', () {
      expect(RateLimitConfig.login.maxRequests, equals(5));
      expect(RateLimitConfig.login.blockOnExceed, isTrue);
    });
  });

  group('RateLimited decorator', () {
    test('ينفذ الدالة عند السماح', () async {
      const config = RateLimitConfig(
        maxRequests: 5,
        window: Duration(minutes: 1),
      );

      const rateLimited = RateLimited(keyPrefix: 'test', config: config);

      final result = await rateLimited.execute(
        'action1',
        () async => 'success',
      );

      expect(result, equals('success'));
    });

    test('يرمي استثناء عند الرفض', () async {
      const config = RateLimitConfig(
        maxRequests: 1,
        window: Duration(minutes: 1),
      );

      const rateLimited = RateLimited(keyPrefix: 'test2', config: config);

      // أول طلب
      await rateLimited.execute('action2', () async => 'ok');

      // الثاني يجب أن يفشل
      expect(
        () => rateLimited.execute('action2', () async => 'ok'),
        throwsA(isA<RateLimitExceededException>()),
      );
    });

    test('يستخدم onDenied عند الرفض', () async {
      const config = RateLimitConfig(
        maxRequests: 1,
        window: Duration(minutes: 1),
      );

      const rateLimited = RateLimited(keyPrefix: 'test3', config: config);

      await rateLimited.execute('action3', () async => 'ok');

      final result = await rateLimited.execute(
        'action3',
        () async => 'ok',
        onDenied: (r) => 'denied: ${r.message}',
      );

      expect(result, contains('denied'));
    });
  });

  group('RateLimitExceededException', () {
    test('toString يعيد رسالة صحيحة', () {
      final exception = RateLimitExceededException(
        key: 'test:key',
        retryAfter: const Duration(seconds: 30),
        message: 'Rate limit exceeded',
      );

      expect(exception.toString(), contains('test:key'));
      expect(exception.toString(), contains('30s'));
    });
  });
}

