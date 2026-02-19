import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/network/retry_strategy.dart';

void main() {
  setUp(() {
    RetryStrategy.reset();
  });

  group('RetryStrategy', () {
    group('getDelay', () {
      test('يحسب تأخير exponential بدون jitter', () {
        const config = RetryConfig(
          baseDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 30),
          jitterType: JitterType.none,
        );

        final delay0 = RetryStrategy.getDelay(0, config: config);
        final delay1 = RetryStrategy.getDelay(1, config: config);
        final delay2 = RetryStrategy.getDelay(2, config: config);

        expect(delay0.inSeconds, equals(1)); // 1 * 2^0 = 1
        expect(delay1.inSeconds, equals(2)); // 1 * 2^1 = 2
        expect(delay2.inSeconds, equals(4)); // 1 * 2^2 = 4
      });

      test('يحترم الحد الأقصى للتأخير', () {
        const config = RetryConfig(
          baseDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 5),
          jitterType: JitterType.none,
        );

        final delay5 = RetryStrategy.getDelay(5, config: config); // 1 * 2^5 = 32

        expect(delay5.inSeconds, equals(5)); // capped at 5
      });

      test('يرمي استثناء لـ attempt سالب', () {
        expect(
          () => RetryStrategy.getDelay(-1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Full Jitter', () {
      test('يعطي تأخير بين 0 و الحد الأقصى', () {
        const config = RetryConfig(
          baseDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 30),
          jitterType: JitterType.full,
        );

        for (var i = 0; i < 100; i++) {
          final delay = RetryStrategy.getDelay(2, config: config);
          // Full jitter: random(0, 4000ms)
          expect(delay.inMilliseconds, greaterThanOrEqualTo(1));
          expect(delay.inMilliseconds, lessThanOrEqualTo(4000));
        }
      });

      test('يعطي قيم مختلفة (عشوائية)', () {
        const config = RetryConfig(
          baseDelay: Duration(seconds: 1),
          jitterType: JitterType.full,
        );

        final delays = <int>{};
        for (var i = 0; i < 50; i++) {
          delays.add(RetryStrategy.getDelay(3, config: config).inMilliseconds);
        }

        // يجب أن تكون هناك قيم مختلفة
        expect(delays.length, greaterThan(1));
      });
    });

    group('Equal Jitter', () {
      test('يعطي تأخير بين نصف الحد والحد الكامل', () {
        const config = RetryConfig(
          baseDelay: Duration(seconds: 2),
          maxDelay: Duration(seconds: 30),
          jitterType: JitterType.equal,
        );

        for (var i = 0; i < 100; i++) {
          final delay = RetryStrategy.getDelay(1, config: config);
          // Equal jitter for attempt 1: baseDelay * 2 = 4000ms
          // delay = 2000 + random(0, 2000)
          expect(delay.inMilliseconds, greaterThanOrEqualTo(2000));
          expect(delay.inMilliseconds, lessThanOrEqualTo(4000));
        }
      });
    });

    group('Decorrelated Jitter', () {
      test('يستخدم التأخير السابق', () {
        const config = RetryConfig(
          baseDelay: Duration(milliseconds: 100),
          maxDelay: Duration(seconds: 30),
          jitterType: JitterType.decorrelated,
        );

        final delay1 = RetryStrategy.getDelay(0, config: config);
        final delay2 = RetryStrategy.getDelay(1, config: config, previousDelay: delay1);

        // Decorrelated: random(baseDelay, prevDelay * 3)
        expect(delay2.inMilliseconds, greaterThanOrEqualTo(100));
      });
    });

    group('execute', () {
      test('ينجح في المحاولة الأولى', () async {
        var callCount = 0;

        final result = await RetryStrategy.execute(
          () async {
            callCount++;
            return 'success';
          },
          config: RetryConfig.test,
        );

        expect(result.isSuccess, isTrue);
        expect(result.value, equals('success'));
        expect(result.attempts, equals(1));
        expect(callCount, equals(1));
      });

      test('يعيد المحاولة عند الفشل', () async {
        var callCount = 0;

        final result = await RetryStrategy.execute(
          () async {
            callCount++;
            if (callCount < 3) {
              throw Exception('Temporary error');
            }
            return 'success after retries';
          },
          config: RetryConfig.test,
        );

        expect(result.isSuccess, isTrue);
        expect(result.value, equals('success after retries'));
        expect(result.attempts, equals(3));
        expect(callCount, equals(3));
      });

      test('يفشل بعد استنفاد المحاولات', () async {
        var callCount = 0;

        final result = await RetryStrategy.execute(
          () async {
            callCount++;
            throw Exception('Persistent error');
          },
          config: const RetryConfig(
            maxAttempts: 3,
            baseDelay: Duration(milliseconds: 1),
            jitterType: JitterType.none,
          ),
        );

        expect(result.isSuccess, isFalse);
        expect(result.error, isA<Exception>());
        expect(result.attempts, equals(3));
        expect(callCount, equals(3));
      });

      test('يحترم shouldRetry', () async {
        var callCount = 0;

        final result = await RetryStrategy.execute(
          () async {
            callCount++;
            throw ArgumentError('Do not retry');
          },
          config: RetryConfig.test,
          shouldRetry: (error) => error is! ArgumentError,
        );

        expect(result.isSuccess, isFalse);
        expect(result.attempts, equals(1)); // لم يعيد المحاولة
        expect(callCount, equals(1));
      });

      test('يستدعي onRetry callback', () async {
        final retryAttempts = <int>[];

        await RetryStrategy.execute(
          () async {
            if (retryAttempts.length < 2) {
              throw Exception('Error');
            }
            return 'done';
          },
          config: RetryConfig.test,
          onRetry: (attempt, delay, error) {
            retryAttempts.add(attempt);
          },
        );

        expect(retryAttempts, equals([1, 2]));
      });

      test('يسجل delays', () async {
        final result = await RetryStrategy.execute(
          () async {
            throw Exception('Always fail');
          },
          config: const RetryConfig(
            maxAttempts: 3,
            baseDelay: Duration(milliseconds: 10),
            jitterType: JitterType.none,
          ),
        );

        expect(result.delays.length, equals(2)); // 2 delays for 3 attempts
        expect(result.delays[0].inMilliseconds, equals(10));
        expect(result.delays[1].inMilliseconds, equals(20));
      });

      test('يسجل totalDuration', () async {
        final result = await RetryStrategy.execute(
          () async => 'instant',
          config: RetryConfig.test,
        );

        expect(result.totalDuration.inMicroseconds, greaterThan(0));
      });
    });

    group('shouldRetryStatusCode', () {
      test('يعيد true لأكواد 5xx', () {
        expect(RetryStrategy.shouldRetryStatusCode(500), isTrue);
        expect(RetryStrategy.shouldRetryStatusCode(502), isTrue);
        expect(RetryStrategy.shouldRetryStatusCode(503), isTrue);
        expect(RetryStrategy.shouldRetryStatusCode(504), isTrue);
      });

      test('يعيد true لـ 429 (Too Many Requests)', () {
        expect(RetryStrategy.shouldRetryStatusCode(429), isTrue);
      });

      test('يعيد true لـ 408 (Request Timeout)', () {
        expect(RetryStrategy.shouldRetryStatusCode(408), isTrue);
      });

      test('يعيد false لأكواد 4xx الأخرى', () {
        expect(RetryStrategy.shouldRetryStatusCode(400), isFalse);
        expect(RetryStrategy.shouldRetryStatusCode(401), isFalse);
        expect(RetryStrategy.shouldRetryStatusCode(403), isFalse);
        expect(RetryStrategy.shouldRetryStatusCode(404), isFalse);
        expect(RetryStrategy.shouldRetryStatusCode(422), isFalse);
      });

      test('يعيد false لأكواد 2xx', () {
        expect(RetryStrategy.shouldRetryStatusCode(200), isFalse);
        expect(RetryStrategy.shouldRetryStatusCode(201), isFalse);
      });
    });

    group('estimateTotalTime', () {
      test('يحسب الوقت الإجمالي المتوقع', () {
        const config = RetryConfig(
          baseDelay: Duration(seconds: 1),
          maxDelay: Duration(seconds: 30),
          jitterType: JitterType.none,
        );

        final estimate = RetryStrategy.estimateTotalTime(
          attempts: 4,
          config: config,
        );

        // 3 delays: 1 + 2 + 4 = 7 seconds
        expect(estimate.inSeconds, equals(7));
      });

      test('يعيد صفر لمحاولة واحدة', () {
        final estimate = RetryStrategy.estimateTotalTime(attempts: 1);
        expect(estimate.inMilliseconds, equals(0));
      });
    });
  });

  group('RetryConfig', () {
    test('api config صحيح', () {
      expect(RetryConfig.api.maxAttempts, equals(3));
      expect(RetryConfig.api.baseDelay, equals(const Duration(seconds: 1)));
      expect(RetryConfig.api.jitterType, equals(JitterType.full));
    });

    test('sync config صحيح', () {
      expect(RetryConfig.sync.maxAttempts, equals(5));
      expect(RetryConfig.sync.jitterType, equals(JitterType.decorrelated));
    });

    test('critical config صحيح', () {
      expect(RetryConfig.critical.maxAttempts, equals(10));
      expect(RetryConfig.critical.maxDelay, equals(const Duration(minutes: 5)));
    });

    test('test config سريع', () {
      expect(RetryConfig.test.baseDelay.inMilliseconds, equals(10));
      expect(RetryConfig.test.jitterType, equals(JitterType.none));
    });
  });

  group('RetryResult', () {
    test('success factory يعمل', () {
      final result = RetryResult.success(
        'value',
        attempts: 2,
        totalDuration: const Duration(seconds: 1),
        delays: [const Duration(milliseconds: 100)],
      );

      expect(result.isSuccess, isTrue);
      expect(result.value, equals('value'));
      expect(result.attempts, equals(2));
    });

    test('failure factory يعمل', () {
      final result = RetryResult.failure(
        Exception('error'),
        StackTrace.current,
        attempts: 3,
        totalDuration: const Duration(seconds: 2),
        delays: [],
      );

      expect(result.isSuccess, isFalse);
      expect(result.error, isA<Exception>());
      expect(result.attempts, equals(3));
    });

    test('toString يعيد تنسيق صحيح', () {
      final success = RetryResult.success(
        'ok',
        attempts: 1,
        totalDuration: const Duration(milliseconds: 100),
        delays: [],
      );

      expect(success.toString(), contains('success'));
      expect(success.toString(), contains('100ms'));
    });
  });

  group('RetryFutureExtension', () {
    test('withRetry ينجح', () async {
      final result = await Future.value('success').withRetry(
        config: RetryConfig.test,
      );

      expect(result, equals('success'));
    });

    test('withRetry يعيد المحاولة ويفشل', () async {
      // ignore: unused_local_variable
      var count = 0;

      expect(
        () => Future(() {
          count++;
          throw Exception('fail');
        }).withRetry(
          config: const RetryConfig(
            maxAttempts: 2,
            baseDelay: Duration(milliseconds: 1),
            jitterType: JitterType.none,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
