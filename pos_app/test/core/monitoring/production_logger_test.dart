import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';

void main() {
  setUp(() {
    ProductionLogger.initialize(
      minLevel: LogLevel.debug,
      sinks: [MemoryLogSink()],
    );
  });

  group('ProductionLogger', () {
    group('log levels', () {
      test('debug يسجل رسالة debug', () async {
        await ProductionLogger.debug('Debug message');

        final logs = ProductionLogger.getRecentLogs();
        expect(logs, hasLength(1));
        expect(logs.first.level, equals(LogLevel.debug));
        expect(logs.first.message, equals('Debug message'));
      });

      test('info يسجل رسالة info', () async {
        await ProductionLogger.info('Info message');

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.level, equals(LogLevel.info));
      });

      test('warning يسجل رسالة warning', () async {
        await ProductionLogger.warning('Warning message');

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.level, equals(LogLevel.warning));
      });

      test('error يسجل رسالة error', () async {
        await ProductionLogger.error('Error message', error: Exception('Test'));

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.level, equals(LogLevel.error));
        expect(logs.last.context?['error'], contains('Exception'));
      });

      test('fatal يسجل رسالة fatal', () async {
        await ProductionLogger.fatal('Fatal message');

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.level, equals(LogLevel.fatal));
      });
    });

    group('exception logging', () {
      test('يسجل استثناء مع stack trace', () async {
        try {
          throw Exception('Test exception');
        } catch (e, st) {
          await ProductionLogger.exception(e, stackTrace: st);
        }

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.level, equals(LogLevel.error));
        expect(logs.last.context?['exception'], contains('Test exception'));
        expect(logs.last.stackTrace, isNotNull);
      });
    });

    group('context and tags', () {
      test('يسجل مع tag', () async {
        await ProductionLogger.info('Message', tag: 'MyTag');

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.tag, equals('MyTag'));
      });

      test('يسجل مع context', () async {
        await ProductionLogger.info('Message', context: {'data': 'value'});

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.context?['data'], equals('value'));
      });
    });

    group('sensitive data sanitization', () {
      test('يخفي كلمات المرور', () async {
        await ProductionLogger.info('Login', context: {'password': 'secret123'});

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.context?['password'], equals('***REDACTED***'));
      });

      test('يخفي الـ tokens', () async {
        await ProductionLogger.info('Auth', context: {'token': 'abc123'});

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.context?['token'], equals('***REDACTED***'));
      });

      test('يخفي الـ PIN', () async {
        await ProductionLogger.info('PIN', context: {'pin': '1234'});

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.context?['pin'], equals('***REDACTED***'));
      });

      test('يخفي البيانات الحساسة المتداخلة', () async {
        await ProductionLogger.info('Nested', context: {
          'user': {
            'name': 'John',
            'password': 'secret',
          }
        });

        final logs = ProductionLogger.getRecentLogs();
        final user = logs.last.context?['user'] as Map<String, dynamic>;
        expect(user['name'], equals('John'));
        expect(user['password'], equals('***REDACTED***'));
      });

      test('لا يخفي البيانات العادية', () async {
        await ProductionLogger.info('Normal', context: {
          'name': 'John',
          'email': 'john@example.com',
        });

        final logs = ProductionLogger.getRecentLogs();
        expect(logs.last.context?['name'], equals('John'));
        expect(logs.last.context?['email'], equals('john@example.com'));
      });
    });

    group('getRecentLogs', () {
      test('يعيد السجلات الأخيرة', () async {
        await ProductionLogger.info('Message 1');
        await ProductionLogger.info('Message 2');
        await ProductionLogger.info('Message 3');

        final logs = ProductionLogger.getRecentLogs(count: 2);
        expect(logs, hasLength(2));
      });

      test('يفلتر حسب المستوى', () async {
        await ProductionLogger.debug('Debug');
        await ProductionLogger.info('Info');
        await ProductionLogger.error('Error');

        final logs = ProductionLogger.getRecentLogs(minLevel: LogLevel.error);
        expect(logs, hasLength(1));
        expect(logs.first.level, equals(LogLevel.error));
      });
    });
  });

  group('LogEntry', () {
    test('toJson يعيد map صحيح', () {
      final entry = LogEntry(
        id: 'log_1',
        level: LogLevel.info,
        message: 'Test',
        tag: 'TAG',
        context: {'key': 'value'},
      );

      final json = entry.toJson();

      expect(json['id'], equals('log_1'));
      expect(json['level'], equals('info'));
      expect(json['message'], equals('Test'));
      expect(json['tag'], equals('TAG'));
    });

    test('toString يعيد تنسيق صحيح', () {
      final entry = LogEntry(
        id: 'log_1',
        level: LogLevel.info,
        message: 'Test message',
        tag: 'TAG',
      );

      final str = entry.toString();

      expect(str, contains('[INFO]'));
      expect(str, contains('[TAG]'));
      expect(str, contains('Test message'));
    });
  });

  group('MemoryLogSink', () {
    test('يحافظ على الحد الأقصى للسجلات', () async {
      final sink = MemoryLogSink(maxEntries: 5);

      for (int i = 0; i < 10; i++) {
        await sink.write(LogEntry(
          id: 'log_$i',
          level: LogLevel.info,
          message: 'Message $i',
        ));
      }

      final entries = sink.getEntries();
      expect(entries, hasLength(5));
      expect(entries.first.id, equals('log_5'));
    });

    test('flush يمسح السجلات', () async {
      final sink = MemoryLogSink();
      await sink.write(LogEntry(
        id: 'log_1',
        level: LogLevel.info,
        message: 'Test',
      ));

      await sink.flush();

      expect(sink.getEntries(), isEmpty);
    });
  });

  group('LoggerExtension', () {
    test('logInfo يستخدم اسم الكلاس كـ tag', () async {
      final testObj = _TestClass();
      testObj.logInfo('Test message');

      final logs = ProductionLogger.getRecentLogs();
      expect(logs.last.tag, equals('_TestClass'));
    });
  });
}

class _TestClass {
  void logInfo(String message) {
    ProductionLogger.info(message, tag: runtimeType.toString());
  }
}
