/// مساعدات الاختبار المشتركة - Shared Test Helpers
///
/// توفر دوال مساعدة ومطابقات مخصصة للاختبارات
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/src/exceptions/app_exception.dart';

// ============================================================================
// DIO ERROR HELPERS
// ============================================================================

/// ينشئ DioException للمحاكاة في الاختبارات
DioException createDioException({
  required int statusCode,
  String? message,
  String path = '/test',
  Map<String, dynamic>? data,
}) {
  return DioException(
    type: DioExceptionType.badResponse,
    response: Response(
      statusCode: statusCode,
      data: data ?? {'message': message ?? 'Error'},
      requestOptions: RequestOptions(path: path),
    ),
    requestOptions: RequestOptions(path: path),
  );
}

/// DioException للخطأ 400 (ValidationException)
DioException validationError({String? message, String path = '/test'}) {
  return createDioException(
    statusCode: 400,
    message: message ?? 'Validation error',
    path: path,
  );
}

/// DioException للخطأ 401 (AuthException)
DioException authError({String? message, String path = '/test'}) {
  return createDioException(
    statusCode: 401,
    message: message ?? 'Unauthorized',
    path: path,
  );
}

/// DioException للخطأ 403 (RLS/Permission)
DioException forbiddenError({String? message, String path = '/test'}) {
  return createDioException(
    statusCode: 403,
    message: message ?? 'Forbidden',
    path: path,
  );
}

/// DioException للخطأ 404 (NotFoundException)
DioException notFoundError({String? message, String path = '/test'}) {
  return createDioException(
    statusCode: 404,
    message: message ?? 'Not found',
    path: path,
  );
}

/// DioException للخطأ 500 (ServerException)
DioException serverError({String? message, String path = '/test'}) {
  return createDioException(
    statusCode: 500,
    message: message ?? 'Server error',
    path: path,
  );
}

/// DioException لخطأ الاتصال
DioException connectionError({String path = '/test'}) {
  return DioException(
    type: DioExceptionType.connectionError,
    requestOptions: RequestOptions(path: path),
  );
}

/// DioException لخطأ المهلة
DioException timeoutError({String path = '/test'}) {
  return DioException(
    type: DioExceptionType.connectionTimeout,
    requestOptions: RequestOptions(path: path),
  );
}

// ============================================================================
// CUSTOM MATCHERS
// ============================================================================

/// مطابق للتحقق من نوع الاستثناء
Matcher throwsAppException<T extends AppException>() {
  return throwsA(isA<T>());
}

/// مطابق للتحقق من NetworkException
Matcher get throwsNetworkException => throwsA(isA<NetworkException>());

/// مطابق للتحقق من AuthException
Matcher get throwsAuthException => throwsA(isA<AuthException>());

/// مطابق للتحقق من ValidationException
Matcher get throwsValidationException => throwsA(isA<ValidationException>());

/// مطابق للتحقق من NotFoundException
Matcher get throwsNotFoundException => throwsA(isA<NotFoundException>());

/// مطابق للتحقق من ServerException
Matcher get throwsServerException => throwsA(isA<ServerException>());

// ============================================================================
// ASYNC TEST HELPERS
// ============================================================================

/// ينتظر لفترة محددة (للاختبارات غير المتزامنة)
Future<void> waitForDuration(Duration duration) async {
  await Future.delayed(duration);
}

/// ينتظر لفترة قصيرة
Future<void> waitShort() => waitForDuration(const Duration(milliseconds: 50));

/// ينتظر لفترة متوسطة
Future<void> waitMedium() => waitForDuration(const Duration(milliseconds: 200));

// ============================================================================
// STRING HELPERS
// ============================================================================

/// ينشئ رقم هاتف سعودي صالح
String saudiPhone([int suffix = 0]) =>
    '+9665${suffix.toString().padLeft(8, '0')}';

/// ينشئ معرف UUID وهمي
String fakeUuid([int index = 1]) =>
    '00000000-0000-0000-0000-${index.toString().padLeft(12, '0')}';

// ============================================================================
// DATE HELPERS
// ============================================================================

/// تاريخ ثابت للاختبارات
DateTime get fixedDate => DateTime(2026, 1, 15, 10, 30);

/// تاريخ في الماضي
DateTime pastDate([int daysAgo = 7]) =>
    DateTime.now().subtract(Duration(days: daysAgo));

/// تاريخ في المستقبل
DateTime futureDate([int daysAhead = 7]) =>
    DateTime.now().add(Duration(days: daysAhead));

// ============================================================================
// VERIFICATION HELPERS
// ============================================================================

/// التحقق من أن الدالة تم استدعاؤها مرة واحدة بالضبط
void verifyCalledOnce(dynamic mock) {
  verify(() => mock).called(1);
}

/// التحقق من أن الدالة لم يتم استدعاؤها
void verifyNeverCalled(dynamic mock) {
  verifyNever(() => mock);
}
