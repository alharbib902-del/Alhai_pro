import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'package:alhai_core/src/exceptions/app_exception.dart';
import 'package:alhai_core/src/exceptions/error_mapper.dart';

void main() {
  group('AppException Hierarchy', () {
    group('NetworkException', () {
      test('should store message and code', () {
        const exception = NetworkException(
          'No internet connection',
          code: 'NO_INTERNET',
          statusCode: null,
        );

        expect(exception.message, equals('No internet connection'));
        expect(exception.code, equals('NO_INTERNET'));
        expect(exception.statusCode, isNull);
      });

      test('should be an AppException', () {
        const exception = NetworkException('timeout');
        expect(exception, isA<AppException>());
      });

      test('toString should include message', () {
        const exception = NetworkException('timeout', code: 'TIMEOUT');
        expect(exception.toString(), contains('timeout'));
      });
    });

    group('AuthException', () {
      test('should store message, code and statusCode', () {
        const exception = AuthException(
          'Unauthorized',
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );

        expect(exception.message, equals('Unauthorized'));
        expect(exception.code, equals('UNAUTHORIZED'));
        expect(exception.statusCode, equals(401));
      });

      test('should handle 403 forbidden', () {
        const exception = AuthException(
          'Forbidden',
          code: 'FORBIDDEN',
          statusCode: 403,
        );

        expect(exception.statusCode, equals(403));
        expect(exception, isA<AppException>());
      });
    });

    group('ValidationException', () {
      test('should store message and field errors', () {
        const exception = ValidationException(
          'Validation failed',
          code: 'BAD_REQUEST',
          fieldErrors: {
            'name': ['Name is required'],
            'price': ['Price must be positive'],
          },
        );

        expect(exception.message, equals('Validation failed'));
        expect(exception.fieldErrors, isNotNull);
        expect(exception.fieldErrors!['name'], contains('Name is required'));
        expect(exception.fieldErrors!['price'],
            contains('Price must be positive'));
      });

      test('should allow null field errors', () {
        const exception = ValidationException('Invalid input');
        expect(exception.fieldErrors, isNull);
      });
    });

    group('ServerException', () {
      test('should store message with status codes', () {
        const exception = ServerException(
          'Internal server error',
          code: 'SERVER_ERROR',
          statusCode: 500,
        );

        expect(exception.message, equals('Internal server error'));
        expect(exception.statusCode, equals(500));
      });

      test('should handle various 5xx codes', () {
        for (final code in [500, 502, 503, 504]) {
          final exception = ServerException(
            'Error $code',
            statusCode: code,
          );
          expect(exception.statusCode, equals(code));
        }
      });
    });

    group('NotFoundException', () {
      test('should have status code 404', () {
        const exception = NotFoundException('Product not found');
        expect(exception.statusCode, equals(404));
        expect(exception.message, equals('Product not found'));
      });

      test('should store custom code', () {
        const exception = NotFoundException(
          'User not found',
          code: 'USER_NOT_FOUND',
        );
        expect(exception.code, equals('USER_NOT_FOUND'));
      });
    });

    group('UnknownException', () {
      test('should store cause and stack trace', () {
        final cause = Exception('original error');
        final stackTrace = StackTrace.current;
        final exception = UnknownException(
          'Something went wrong',
          cause: cause,
          stackTrace: stackTrace,
        );

        expect(exception.message, equals('Something went wrong'));
        expect(exception.cause, equals(cause));
        expect(exception.stackTrace, equals(stackTrace));
        expect(exception.code, equals('UNKNOWN'));
      });

      test('toString should include cause', () {
        final cause = Exception('original');
        final exception = UnknownException('error', cause: cause);
        expect(exception.toString(), contains('cause'));
        expect(exception.toString(), contains('original'));
      });
    });
  });

  group('ErrorMapper', () {
    group('fromDioError - connection errors', () {
      test('should map connectionTimeout to NetworkException with TIMEOUT', () {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('TIMEOUT'));
      });

      test('should map sendTimeout to NetworkException with TIMEOUT', () {
        final dioError = DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('TIMEOUT'));
      });

      test('should map receiveTimeout to NetworkException with TIMEOUT', () {
        final dioError = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('TIMEOUT'));
      });

      test('should map connectionError to NetworkException with NO_INTERNET',
          () {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('NO_INTERNET'));
      });

      test('should map cancel to NetworkException with CANCELLED', () {
        final dioError = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('CANCELLED'));
      });

      test('should map badCertificate to NetworkException', () {
        final dioError = DioException(
          type: DioExceptionType.badCertificate,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('BAD_CERTIFICATE'));
      });

      test('should map unknown without response to NetworkException', () {
        final dioError = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NetworkException>());
        expect(result.code, equals('UNKNOWN'));
      });
    });

    group('fromDioError - bad response mapping', () {
      test('should map 400 to ValidationException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'message': 'Validation failed'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ValidationException>());
        expect(result.message, equals('Validation failed'));
      });

      test('should map 400 with field errors to ValidationException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Validation failed',
              'errors': {
                'email': ['Email is required'],
                'name': ['Name too short'],
              },
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ValidationException>());
        final ve = result as ValidationException;
        expect(ve.fieldErrors, isNotNull);
        expect(ve.fieldErrors!['email'], contains('Email is required'));
        expect(ve.fieldErrors!['name'], contains('Name too short'));
      });

      test('should map 401 to AuthException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {'message': 'Token expired'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<AuthException>());
        expect(result.statusCode, equals(401));
      });

      test('should map 403 to AuthException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 403,
            data: {'message': 'Forbidden'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<AuthException>());
        expect(result.code, equals('FORBIDDEN'));
      });

      test('should map 404 to NotFoundException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 404,
            data: {'message': 'Product not found'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<NotFoundException>());
        expect(result.statusCode, equals(404));
      });

      test('should map 422 to ValidationException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 422,
            data: {'message': 'Unprocessable entity'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ValidationException>());
        expect(result.code, equals('UNPROCESSABLE_ENTITY'));
      });

      test('should map 500 to ServerException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'message': 'Internal error'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ServerException>());
        expect(result.statusCode, equals(500));
      });

      test('should map 502 to ServerException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 502,
            data: {'message': 'Bad gateway'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ServerException>());
        expect(result.statusCode, equals(502));
      });

      test('should map unknown status code to ServerException', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            data: {'message': 'Too many requests'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ServerException>());
        expect(result.code, equals('HTTP_ERROR'));
      });

      test('should handle null response body', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: null,
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ServerException>());
        expect(result.message, equals('Server error'));
      });

      test('should handle null response in bad response', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ServerException>());
        expect(result.code, equals('NO_RESPONSE'));
      });
    });

    group('fromDioError - message extraction', () {
      test('should extract message from string response', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: 'Validation error string',
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result.message, equals('Validation error string'));
      });

      test('should extract message from error field', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'error': 'Error from error field'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result.message, equals('Error from error field'));
      });

      test('should extract localized ar message from map', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': {'ar': 'خطأ في التحقق', 'en': 'Validation error'},
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result.message, equals('خطأ في التحقق'));
      });

      test('should extract en message when ar not available', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': {'en': 'Validation error'},
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result.message, equals('Validation error'));
      });

      test('should extract message from list response', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: ['First error', 'Second error'],
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result.message, equals('First error'));
      });

      test('should extract code from response data', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Error',
              'code': 'CUSTOM_CODE',
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result.code, equals('CUSTOM_CODE'));
      });

      test('should handle field errors with single string values', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Validation failed',
              'errors': {
                'email': 'Email is required',
              },
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);
        final ve = result as ValidationException;

        expect(ve.fieldErrors, isNotNull);
        expect(ve.fieldErrors!['email'], contains('Email is required'));
      });

      test('should handle field errors with localized map values', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {
              'message': 'Validation failed',
              'errors': {
                'name': {'ar': 'الاسم مطلوب', 'en': 'Name required'},
              },
            },
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);
        final ve = result as ValidationException;

        expect(ve.fieldErrors, isNotNull);
        expect(ve.fieldErrors!['name'], contains('الاسم مطلوب'));
      });

      test('should handle unknown DioException with response', () {
        final dioError = DioException(
          type: DioExceptionType.unknown,
          response: Response(
            statusCode: 500,
            data: {'message': 'Server error'},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        );

        final result = ErrorMapper.fromDioError(dioError);

        expect(result, isA<ServerException>());
      });
    });
  });
}
