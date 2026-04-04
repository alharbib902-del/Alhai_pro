import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_ai/src/services/ai_api_service.dart';
import 'package:dio/dio.dart';

void main() {
  group('AiApiException', () {
    test('should create with required fields', () {
      final exception = AiApiException(
        message: 'Connection failed',
        endpoint: '/ai/forecast',
      );

      expect(exception.message, 'Connection failed');
      expect(exception.endpoint, '/ai/forecast');
      expect(exception.originalError, isNull);
    });

    test('toString returns formatted string', () {
      final exception = AiApiException(
        message: 'Connection failed',
        endpoint: '/ai/forecast',
      );

      expect(exception.toString(),
          'AiApiException(/ai/forecast): Connection failed');
    });

    test('isOffline returns true for connection error', () {
      final dioError = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );
      final exception = AiApiException(
        message: 'Offline',
        endpoint: '/test',
        originalError: dioError,
      );

      expect(exception.isOffline, isTrue);
      expect(exception.isTimeout, isFalse);
    });

    test('isTimeout returns true for connection timeout', () {
      final dioError = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final exception = AiApiException(
        message: 'Timeout',
        endpoint: '/test',
        originalError: dioError,
      );

      expect(exception.isTimeout, isTrue);
      expect(exception.isOffline, isFalse);
    });

    test('isTimeout returns true for receive timeout', () {
      final dioError = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final exception = AiApiException(
        message: 'Timeout',
        endpoint: '/test',
        originalError: dioError,
      );

      expect(exception.isTimeout, isTrue);
    });

    test('isOffline returns false when no original error', () {
      final exception = AiApiException(
        message: 'Error',
        endpoint: '/test',
      );

      expect(exception.isOffline, isFalse);
      expect(exception.isTimeout, isFalse);
    });

    test('isOffline returns false for non-DioException', () {
      final exception = AiApiException(
        message: 'Error',
        endpoint: '/test',
        originalError: Exception('generic'),
      );

      expect(exception.isOffline, isFalse);
      expect(exception.isTimeout, isFalse);
    });
  });
}
