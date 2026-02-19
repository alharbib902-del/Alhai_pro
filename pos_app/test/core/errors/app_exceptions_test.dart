import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/errors/app_exceptions.dart';

// ===========================================
// App Exceptions Tests
// ===========================================

void main() {
  group('NetworkException', () {
    test('constructor الأساسي يعمل بشكل صحيح', () {
      const exception = NetworkException(
        message: 'Test error',
        userMessage: 'رسالة للمستخدم',
        code: 'TEST',
      );

      expect(exception.message, 'Test error');
      expect(exception.userMessage, 'رسالة للمستخدم');
      expect(exception.code, 'TEST');
    });

    test('القيم الافتراضية صحيحة', () {
      const exception = NetworkException();

      expect(exception.message, 'Network error');
      expect(exception.userMessage, 'خطأ في الاتصال بالخادم');
    });

    group('noConnection factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = NetworkException.noConnection();

        expect(exception.message, 'No internet connection');
        expect(exception.userMessage, 'لا يوجد اتصال بالإنترنت');
        expect(exception.code, 'NO_CONNECTION');
      });
    });

    group('timeout factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = NetworkException.timeout();

        expect(exception.message, 'Request timeout');
        expect(exception.userMessage, 'انتهى وقت الطلب، حاول مرة أخرى');
        expect(exception.code, 'TIMEOUT');
      });
    });

    group('serverError factory', () {
      test('يُنشئ استثناء بدون statusCode', () {
        final exception = NetworkException.serverError();

        expect(exception.message, contains('Server error'));
        expect(exception.userMessage, 'خطأ في الخادم، حاول لاحقاً');
        expect(exception.code, 'SERVER_ERROR');
      });

      test('يُنشئ استثناء مع statusCode', () {
        final exception = NetworkException.serverError(500);

        expect(exception.message, 'Server error: 500');
        expect(exception.details, {'statusCode': 500});
      });
    });

    test('toString يُرجع تنسيق صحيح', () {
      final exception = NetworkException.noConnection();
      expect(exception.toString(), contains('NetworkException'));
      expect(exception.toString(), contains('No internet connection'));
    });
  });

  group('AuthException', () {
    test('القيم الافتراضية صحيحة', () {
      const exception = AuthException();

      expect(exception.message, 'Authentication error');
      expect(exception.userMessage, 'خطأ في المصادقة');
    });

    group('sessionExpired factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = AuthException.sessionExpired();

        expect(exception.message, 'Session expired');
        expect(exception.userMessage, 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً');
        expect(exception.code, 'SESSION_EXPIRED');
      });
    });

    group('unauthorized factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = AuthException.unauthorized();

        expect(exception.message, 'Unauthorized');
        expect(exception.userMessage, 'غير مصرح لك بهذا الإجراء');
        expect(exception.code, 'UNAUTHORIZED');
      });
    });

    group('invalidOtp factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = AuthException.invalidOtp();

        expect(exception.message, 'Invalid OTP');
        expect(exception.userMessage, 'رمز التحقق غير صحيح');
        expect(exception.code, 'INVALID_OTP');
      });
    });

    group('invalidPhone factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = AuthException.invalidPhone();

        expect(exception.message, 'Invalid phone number');
        expect(exception.userMessage, 'رقم الهاتف غير صالح');
        expect(exception.code, 'INVALID_PHONE');
      });
    });

    group('tokenExpired factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = AuthException.tokenExpired();

        expect(exception.message, 'Token expired');
        expect(exception.userMessage, 'انتهت صلاحية التوكن');
        expect(exception.code, 'TOKEN_EXPIRED');
      });
    });
  });

  group('DatabaseException', () {
    test('القيم الافتراضية صحيحة', () {
      const exception = DatabaseException();

      expect(exception.message, 'Database error');
      expect(exception.userMessage, 'خطأ في قاعدة البيانات');
    });

    group('insertFailed factory', () {
      test('يُنشئ استثناء بدون table', () {
        final exception = DatabaseException.insertFailed();

        expect(exception.message, contains('Insert failed'));
        expect(exception.userMessage, 'فشل حفظ البيانات');
        expect(exception.code, 'INSERT_FAILED');
      });

      test('يُنشئ استثناء مع table', () {
        final exception = DatabaseException.insertFailed('products');

        expect(exception.message, 'Insert failed: products');
        expect(exception.details, {'table': 'products'});
      });
    });

    group('updateFailed factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = DatabaseException.updateFailed('sales');

        expect(exception.message, 'Update failed: sales');
        expect(exception.userMessage, 'فشل تحديث البيانات');
        expect(exception.code, 'UPDATE_FAILED');
        expect(exception.details, {'table': 'sales'});
      });
    });

    group('notFound factory', () {
      test('يُنشئ استثناء بدون id', () {
        final exception = DatabaseException.notFound();

        expect(exception.message, contains('Record not found'));
        expect(exception.userMessage, 'العنصر غير موجود');
        expect(exception.code, 'NOT_FOUND');
      });

      test('يُنشئ استثناء مع id', () {
        final exception = DatabaseException.notFound('prod_123');

        expect(exception.message, 'Record not found: prod_123');
        expect(exception.details, {'id': 'prod_123'});
      });
    });
  });

  group('ValidationException', () {
    test('القيم الافتراضية صحيحة', () {
      const exception = ValidationException();

      expect(exception.message, 'Validation error');
      expect(exception.userMessage, 'بيانات غير صالحة');
    });

    group('required factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = ValidationException.required('email');

        expect(exception.message, 'Field required: email');
        expect(exception.userMessage, 'هذا الحقل مطلوب');
        expect(exception.code, 'REQUIRED');
        expect(exception.details, {'field': 'email'});
      });
    });

    group('invalid factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = ValidationException.invalid('phone');

        expect(exception.message, 'Invalid field: phone');
        expect(exception.userMessage, 'قيمة غير صالحة');
        expect(exception.code, 'INVALID');
        expect(exception.details, {'field': 'phone'});
      });
    });
  });

  group('BusinessException', () {
    test('القيم الافتراضية صحيحة', () {
      const exception = BusinessException();

      expect(exception.message, 'Business error');
      expect(exception.userMessage, 'خطأ في العملية');
    });

    group('outOfStock factory', () {
      test('يُنشئ استثناء بدون اسم منتج', () {
        final exception = BusinessException.outOfStock();

        expect(exception.message, contains('Out of stock'));
        expect(exception.userMessage, 'المنتج غير متوفر في المخزون');
        expect(exception.code, 'OUT_OF_STOCK');
      });

      test('يُنشئ استثناء مع اسم منتج', () {
        final exception = BusinessException.outOfStock('حليب');

        expect(exception.message, 'Out of stock: حليب');
        expect(exception.userMessage, 'المنتج "حليب" غير متوفر');
        expect(exception.details, {'product': 'حليب'});
      });
    });

    group('insufficientBalance factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = BusinessException.insufficientBalance();

        expect(exception.message, 'Insufficient balance');
        expect(exception.userMessage, 'الرصيد غير كافي');
        expect(exception.code, 'INSUFFICIENT_BALANCE');
      });
    });

    group('maxQuantity factory', () {
      test('يُنشئ استثناء بقيم صحيحة', () {
        final exception = BusinessException.maxQuantity(100);

        expect(exception.message, 'Max quantity exceeded: 100');
        expect(exception.userMessage, 'الحد الأقصى للكمية هو 100');
        expect(exception.code, 'MAX_QUANTITY');
        expect(exception.details, {'max': 100});
      });
    });
  });
}
