import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/monitoring/sync_recovery_service.dart';

void main() {
  group('SyncErrorInfo', () {
    test('isRetryable يعيد true لأخطاء الشبكة', () {
      final error = SyncErrorInfo(
        itemId: '1',
        tableName: 'sales',
        operation: 'CREATE',
        errorType: SyncErrorType.networkError,
        errorMessage: 'Network error',
        retryCount: 0,
        firstOccurred: DateTime.now(),
        lastOccurred: DateTime.now(),
      );

      expect(error.isRetryable, isTrue);
    });

    test('isRetryable يعيد true لأخطاء السيرفر', () {
      final error = SyncErrorInfo(
        itemId: '1',
        tableName: 'sales',
        operation: 'CREATE',
        errorType: SyncErrorType.serverError,
        errorMessage: '500 Error',
        retryCount: 0,
        firstOccurred: DateTime.now(),
        lastOccurred: DateTime.now(),
      );

      expect(error.isRetryable, isTrue);
    });

    test('isRetryable يعيد false لأخطاء التحقق', () {
      final error = SyncErrorInfo(
        itemId: '1',
        tableName: 'sales',
        operation: 'CREATE',
        errorType: SyncErrorType.validationError,
        errorMessage: 'Invalid data',
        retryCount: 0,
        firstOccurred: DateTime.now(),
        lastOccurred: DateTime.now(),
      );

      expect(error.isRetryable, isFalse);
    });

    test('requiresManualIntervention يعيد true لأخطاء التعارض', () {
      final error = SyncErrorInfo(
        itemId: '1',
        tableName: 'sales',
        operation: 'UPDATE',
        errorType: SyncErrorType.conflictError,
        errorMessage: 'Conflict',
        retryCount: 0,
        firstOccurred: DateTime.now(),
        lastOccurred: DateTime.now(),
      );

      expect(error.requiresManualIntervention, isTrue);
    });

    test('requiresManualIntervention يعيد true بعد 5 محاولات', () {
      final error = SyncErrorInfo(
        itemId: '1',
        tableName: 'sales',
        operation: 'CREATE',
        errorType: SyncErrorType.networkError,
        errorMessage: 'Network error',
        retryCount: 5,
        firstOccurred: DateTime.now(),
        lastOccurred: DateTime.now(),
      );

      expect(error.requiresManualIntervention, isTrue);
    });

    test('toJson يعيد map صحيح', () {
      final now = DateTime.now();
      final error = SyncErrorInfo(
        itemId: '1',
        tableName: 'sales',
        operation: 'CREATE',
        errorType: SyncErrorType.networkError,
        errorMessage: 'Error',
        retryCount: 2,
        firstOccurred: now,
        lastOccurred: now,
      );

      final json = error.toJson();

      expect(json['itemId'], equals('1'));
      expect(json['tableName'], equals('sales'));
      expect(json['errorType'], equals('networkError'));
      expect(json['retryCount'], equals(2));
    });
  });

  group('RecoveryResult', () {
    test('يحتوي على البيانات الصحيحة', () {
      final result = RecoveryResult(
        itemId: '1',
        strategy: RecoveryStrategy.retry,
        success: true,
        message: 'Retried',
      );

      expect(result.itemId, equals('1'));
      expect(result.strategy, equals(RecoveryStrategy.retry));
      expect(result.success, isTrue);
    });
  });

  group('RecoveryReport', () {
    test('successRate يحسب النسبة الصحيحة', () {
      final report = RecoveryReport(
        totalItems: 10,
        recoveredItems: 7,
        skippedItems: 2,
        failedItems: 1,
        results: [],
        duration: const Duration(seconds: 1),
      );

      expect(report.successRate, equals(0.7));
    });

    test('successRate يعيد 0 عند عدم وجود عناصر', () {
      final report = RecoveryReport(
        totalItems: 0,
        recoveredItems: 0,
        skippedItems: 0,
        failedItems: 0,
        results: [],
        duration: Duration.zero,
      );

      expect(report.successRate, equals(0));
    });

    test('toJson يعيد ملخص صحيح', () {
      final report = RecoveryReport(
        totalItems: 10,
        recoveredItems: 5,
        skippedItems: 3,
        failedItems: 2,
        results: [],
        duration: const Duration(milliseconds: 500),
      );

      final json = report.toJson();

      expect(json['totalItems'], equals(10));
      expect(json['recoveredItems'], equals(5));
      expect(json['durationMs'], equals(500));
    });
  });

  group('SyncRecoveryService', () {
    late SyncRecoveryService service;
    late List<Map<String, dynamic>> mockFailedItems;
    late List<String> retriedItems;
    late List<String> skippedItems;

    setUp(() {
      mockFailedItems = [];
      retriedItems = [];
      skippedItems = [];

      service = SyncRecoveryService(
        getFailedItems: () async => mockFailedItems,
        retryItem: (id) async => retriedItems.add(id),
        skipItem: (id) async => skippedItems.add(id),
        rollbackItem: (id) async {},
        markAsFailed: (id, error) async {},
      );
    });

    group('analyzeFailures', () {
      test('يحلل العناصر الفاشلة', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Network connection failed',
            'retryCount': 1,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final failures = await service.analyzeFailures();

        expect(failures, hasLength(1));
        expect(failures.first.errorType, equals(SyncErrorType.networkError));
      });

      test('يصنف أخطاء الـ timeout', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Request timeout',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final failures = await service.analyzeFailures();

        expect(failures.first.errorType, equals(SyncErrorType.timeoutError));
      });

      test('يصنف أخطاء السيرفر 500', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Server returned 500',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final failures = await service.analyzeFailures();

        expect(failures.first.errorType, equals(SyncErrorType.serverError));
      });

      test('يصنف أخطاء التحقق', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Validation failed: invalid amount',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final failures = await service.analyzeFailures();

        expect(failures.first.errorType, equals(SyncErrorType.validationError));
      });
    });

    group('determineStrategy', () {
      test('يختار retry لأخطاء الشبكة', () {
        final error = SyncErrorInfo(
          itemId: '1',
          tableName: 'sales',
          operation: 'CREATE',
          errorType: SyncErrorType.networkError,
          errorMessage: 'Error',
          retryCount: 0,
          firstOccurred: DateTime.now(),
          lastOccurred: DateTime.now(),
        );

        final strategy = service.determineStrategy(error);

        expect(strategy, equals(RecoveryStrategy.retry));
      });

      test('يختار skip لأخطاء التحقق', () {
        final error = SyncErrorInfo(
          itemId: '1',
          tableName: 'sales',
          operation: 'CREATE',
          errorType: SyncErrorType.validationError,
          errorMessage: 'Error',
          retryCount: 0,
          firstOccurred: DateTime.now(),
          lastOccurred: DateTime.now(),
        );

        final strategy = service.determineStrategy(error);

        expect(strategy, equals(RecoveryStrategy.skip));
      });

      test('يختار manualResolve لأخطاء التعارض', () {
        final error = SyncErrorInfo(
          itemId: '1',
          tableName: 'sales',
          operation: 'UPDATE',
          errorType: SyncErrorType.conflictError,
          errorMessage: 'Error',
          retryCount: 0,
          firstOccurred: DateTime.now(),
          lastOccurred: DateTime.now(),
        );

        final strategy = service.determineStrategy(error);

        expect(strategy, equals(RecoveryStrategy.manualResolve));
      });
    });

    group('runAutoRecovery', () {
      test('يعيد المحاولة لأخطاء الشبكة', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Network error',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final report = await service.runAutoRecovery();

        expect(retriedItems, contains('1'));
        expect(report.recoveredItems, equals(1));
      });

      test('يتخطى أخطاء التحقق', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Validation failed',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final report = await service.runAutoRecovery(skipValidationErrors: true);

        expect(skippedItems, contains('1'));
        expect(report.skippedItems, equals(1));
      });

      test('يحسب مدة الاسترداد', () async {
        mockFailedItems = [];

        final report = await service.runAutoRecovery();

        expect(report.duration, isNotNull);
      });
    });

    group('getErrorSummary', () {
      test('يعيد ملخص الأخطاء حسب النوع', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Network error',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': '2',
            'tableName': 'products',
            'operation': 'UPDATE',
            'lastError': 'Network connection failed',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': '3',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Validation failed',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final summary = await service.getErrorSummary();

        expect(summary[SyncErrorType.networkError], equals(2));
        expect(summary[SyncErrorType.validationError], equals(1));
      });
    });

    group('getItemsRequiringManualIntervention', () {
      test('يعيد العناصر التي تحتاج تدخل يدوي', () async {
        mockFailedItems = [
          {
            'id': '1',
            'tableName': 'sales',
            'operation': 'UPDATE',
            'lastError': 'Conflict detected',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
          {
            'id': '2',
            'tableName': 'sales',
            'operation': 'CREATE',
            'lastError': 'Network error',
            'retryCount': 0,
            'createdAt': DateTime.now().toIso8601String(),
          },
        ];

        final items = await service.getItemsRequiringManualIntervention();

        expect(items, hasLength(1));
        expect(items.first.itemId, equals('1'));
      });
    });
  });
}
