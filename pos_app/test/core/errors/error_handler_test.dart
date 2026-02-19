import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/errors/error_handler.dart';

void main() {
  group('ErrorType', () {
    test('يحتوي على جميع أنواع الأخطاء', () {
      expect(ErrorType.values.length, 11);
      expect(ErrorType.values, contains(ErrorType.network));
      expect(ErrorType.values, contains(ErrorType.server));
      expect(ErrorType.values, contains(ErrorType.authentication));
      expect(ErrorType.values, contains(ErrorType.authorization));
      expect(ErrorType.values, contains(ErrorType.validation));
      expect(ErrorType.values, contains(ErrorType.database));
      expect(ErrorType.values, contains(ErrorType.unknown));
      expect(ErrorType.values, contains(ErrorType.timeout));
      expect(ErrorType.values, contains(ErrorType.noConnection));
      expect(ErrorType.values, contains(ErrorType.notFound));
      expect(ErrorType.values, contains(ErrorType.conflict));
    });
  });

  group('AppError', () {
    test('يُنشئ من البيانات الصحيحة', () {
      const error = AppError(
        type: ErrorType.network,
        message: 'Network error',
        userMessage: 'حدث خطأ في الاتصال',
        canRetry: true,
      );

      expect(error.type, ErrorType.network);
      expect(error.message, 'Network error');
      expect(error.userMessage, 'حدث خطأ في الاتصال');
      expect(error.canRetry, isTrue);
    });

    test('toString يعمل بشكل صحيح', () {
      const error = AppError(
        type: ErrorType.server,
        message: 'Server error',
        userMessage: 'خطأ في الخادم',
      );

      expect(error.toString(), contains('AppError'));
      expect(error.toString(), contains('server'));
    });

    group('Factory Constructors', () {
      test('AppError.network يُنشئ خطأ شبكة', () {
        final error = AppError.network(message: 'Connection failed');

        expect(error.type, ErrorType.network);
        expect(error.canRetry, isTrue);
        expect(error.userMessage, contains('اتصال'));
      });

      test('AppError.server يُنشئ خطأ خادم', () {
        final error = AppError.server(message: 'Internal error', code: '500');

        expect(error.type, ErrorType.server);
        expect(error.code, '500');
        expect(error.canRetry, isTrue);
      });

      test('AppError.authentication يُنشئ خطأ مصادقة', () {
        final error = AppError.authentication();

        expect(error.type, ErrorType.authentication);
        expect(error.canRetry, isFalse);
        expect(error.userMessage, contains('الجلسة'));
      });

      test('AppError.authorization يُنشئ خطأ صلاحيات', () {
        final error = AppError.authorization();

        expect(error.type, ErrorType.authorization);
        expect(error.canRetry, isFalse);
        expect(error.userMessage, contains('صلاحية'));
      });

      test('AppError.validation يُنشئ خطأ تحقق', () {
        final error = AppError.validation(
          message: 'Invalid email',
          userMessage: 'البريد الإلكتروني غير صحيح',
        );

        expect(error.type, ErrorType.validation);
        expect(error.canRetry, isFalse);
        expect(error.userMessage, 'البريد الإلكتروني غير صحيح');
      });

      test('AppError.database يُنشئ خطأ قاعدة بيانات', () {
        final error = AppError.database();

        expect(error.type, ErrorType.database);
        expect(error.canRetry, isTrue);
        expect(error.userMessage, contains('حفظ'));
      });

      test('AppError.timeout يُنشئ خطأ انتهاء مهلة', () {
        final error = AppError.timeout();

        expect(error.type, ErrorType.timeout);
        expect(error.canRetry, isTrue);
        expect(error.userMessage, contains('انتهى'));
      });

      test('AppError.noConnection يُنشئ خطأ عدم اتصال', () {
        final error = AppError.noConnection();

        expect(error.type, ErrorType.noConnection);
        expect(error.canRetry, isTrue);
        expect(error.userMessage, contains('اتصال'));
      });

      test('AppError.notFound يُنشئ خطأ غير موجود', () {
        final error = AppError.notFound();

        expect(error.type, ErrorType.notFound);
        expect(error.canRetry, isFalse);
        expect(error.userMessage, contains('غير موجود'));
      });

      test('AppError.unknown يُنشئ خطأ غير معروف', () {
        final error = AppError.unknown();

        expect(error.type, ErrorType.unknown);
        expect(error.canRetry, isTrue);
        expect(error.userMessage, contains('غير متوقع'));
      });
    });
  });

  group('ErrorHandler', () {
    test('handle يحول SocketException لـ noConnection', () {
      final error = ErrorHandler.handle(
        const SocketException('Connection refused'),
      );

      expect(error.type, ErrorType.noConnection);
    });

    test('handle يحول TimeoutException لـ timeout', () {
      final error = ErrorHandler.handle(
        TimeoutException('Request timed out'),
      );

      expect(error.type, ErrorType.timeout);
    });

    test('handle يحول HttpException لـ network', () {
      final error = ErrorHandler.handle(
        const HttpException('HTTP Error'),
      );

      expect(error.type, ErrorType.network);
    });

    test('handle يحول Exception غير معروف لـ unknown', () {
      final error = ErrorHandler.handle(
        Exception('Unknown error'),
      );

      expect(error.type, ErrorType.unknown);
    });

    test('handle يعيد AppError كما هو', () {
      final original = AppError.server(message: 'Test');
      final result = ErrorHandler.handle(original);

      expect(identical(result, original), isTrue);
    });

    test('log لا يرمي خطأ', () {
      final error = AppError.network();

      expect(() => ErrorHandler.log(error), returnsNormally);
    });
  });

  group('ErrorBoundary', () {
    testWidgets('يعرض الـ child عند عدم وجود خطأ', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorBoundary(
            child: Text('Test Content'),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('يستخدم errorBuilder المخصص', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorBuilder: (error, retry) => Text('Custom Error: ${error.type}'),
            child: const Text('Test'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });

  group('FutureErrorExtension', () {
    test('handleErrors يحول الأخطاء', () async {
      final future = Future<int>.error(const SocketException('No connection'));

      await expectLater(
        future.handleErrors(),
        throwsA(isA<AppError>()
            .having((e) => e.type, 'type', ErrorType.noConnection)),
      );
    });

    test('handleErrorsOr يعيد القيمة الافتراضية عند الخطأ', () async {
      final future = Future<int>.error(Exception('Error'));
      final result = await future.handleErrorsOr(42);

      expect(result, 42);
    });

    test('handleErrorsOr يعيد القيمة الأصلية عند النجاح', () async {
      final future = Future.value(100);
      final result = await future.handleErrorsOr(42);

      expect(result, 100);
    });
  });
}
