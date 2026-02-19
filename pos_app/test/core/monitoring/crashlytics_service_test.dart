import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/monitoring/crashlytics_service.dart';

// ===========================================
// Crashlytics Service Tests
// ===========================================

void main() {
  group('CrashlyticsService', () {
    test('recordError لا يرمي استثناء عندما instance null', () async {
      // في بيئة الاختبار، _instance = null
      expect(
        () => CrashlyticsService.recordError(
          Exception('test'),
          StackTrace.current,
        ),
        returnsNormally,
      );
    });

    test('log لا يرمي استثناء عندما instance null', () async {
      expect(
        () => CrashlyticsService.log('test message'),
        returnsNormally,
      );
    });

    test('setUserId لا يرمي استثناء عندما instance null', () async {
      expect(
        () => CrashlyticsService.setUserId('user123'),
        returnsNormally,
      );
    });

    test('setCustomKey لا يرمي استثناء عندما instance null', () async {
      expect(
        () => CrashlyticsService.setCustomKey('key', 'value'),
        returnsNormally,
      );
    });

    test('setStoreInfo لا يرمي استثناء عندما instance null', () async {
      expect(
        () => CrashlyticsService.setStoreInfo(
          storeId: 'store123',
          storeName: 'متجر الاختبار',
        ),
        returnsNormally,
      );
    });

    test('testCrash لا يفعل شيء في debug mode', () {
      // في debug mode، يجب ألا يحدث crash
      expect(
        () => CrashlyticsService.testCrash(),
        returnsNormally,
      );
    });

    test('recordError يدعم reason و fatal', () async {
      expect(
        () => CrashlyticsService.recordError(
          Exception('test'),
          StackTrace.current,
          reason: 'Test reason',
          fatal: true,
        ),
        returnsNormally,
      );
    });
  });

  group('ErrorHandler', () {
    group('runWithErrorHandling', () {
      test('يُرجع النتيجة عند النجاح', () async {
        final result = await ErrorHandler.runWithErrorHandling<int>(
          () async => 42,
        );

        expect(result, 42);
      });

      test('يُرجع defaultValue عند الفشل', () async {
        final result = await ErrorHandler.runWithErrorHandling<int>(
          () async => throw Exception('test error'),
          defaultValue: 0,
        );

        expect(result, 0);
      });

      test('يُرجع null عند الفشل بدون defaultValue', () async {
        final result = await ErrorHandler.runWithErrorHandling<int>(
          () async => throw Exception('test error'),
        );

        expect(result, isNull);
      });

      test('يدعم context للتسجيل', () async {
        final result = await ErrorHandler.runWithErrorHandling<String>(
          () async => throw Exception('test'),
          context: 'عملية اختبار',
          defaultValue: 'فشل',
        );

        expect(result, 'فشل');
      });

      test('يعمل مع أنواع مختلفة', () async {
        // String
        final stringResult = await ErrorHandler.runWithErrorHandling<String>(
          () async => 'نجاح',
        );
        expect(stringResult, 'نجاح');

        // List
        final listResult = await ErrorHandler.runWithErrorHandling<List<int>>(
          () async => [1, 2, 3],
        );
        expect(listResult, [1, 2, 3]);

        // Map
        final mapResult = await ErrorHandler.runWithErrorHandling<Map<String, int>>(
          () async => {'a': 1, 'b': 2},
        );
        expect(mapResult, {'a': 1, 'b': 2});
      });
    });

    group('runSyncWithErrorHandling', () {
      test('يُرجع النتيجة عند النجاح', () {
        final result = ErrorHandler.runSyncWithErrorHandling<int>(
          () => 42,
        );

        expect(result, 42);
      });

      test('يُرجع defaultValue عند الفشل', () {
        final result = ErrorHandler.runSyncWithErrorHandling<int>(
          () => throw Exception('test error'),
          defaultValue: 0,
        );

        expect(result, 0);
      });

      test('يُرجع null عند الفشل بدون defaultValue', () {
        final result = ErrorHandler.runSyncWithErrorHandling<int>(
          () => throw Exception('test error'),
        );

        expect(result, isNull);
      });

      test('يدعم context للتسجيل', () {
        final result = ErrorHandler.runSyncWithErrorHandling<String>(
          () => throw Exception('test'),
          context: 'عملية sync اختبار',
          defaultValue: 'فشل',
        );

        expect(result, 'فشل');
      });

      test('يعمل مع computations', () {
        final result = ErrorHandler.runSyncWithErrorHandling<int>(
          () {
            var sum = 0;
            for (var i = 1; i <= 10; i++) {
              sum += i;
            }
            return sum;
          },
        );

        expect(result, 55);
      });

      test('يتعامل مع Exception vs Error', () {
        // Exception
        final exResult = ErrorHandler.runSyncWithErrorHandling<int>(
          () => throw Exception('exception'),
          defaultValue: -1,
        );
        expect(exResult, -1);

        // Error (مثل AssertionError)
        final errResult = ErrorHandler.runSyncWithErrorHandling<int>(
          () => throw StateError('state error'),
          defaultValue: -2,
        );
        expect(errResult, -2);
      });
    });
  });
}
