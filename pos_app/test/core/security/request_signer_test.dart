import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/request_signer.dart';

void main() {
  const testSigningKey = 'test-secret-key-for-signing-requests-12345';

  group('RequestSigner', () {
    setUp(() {
      RequestSigner.initialize(testSigningKey);
    });

    group('initialize', () {
      test('يهيئ المفتاح بنجاح', () {
        RequestSigner.initialize('new-key');

        expect(RequestSigner.isInitialized, isTrue);
      });
    });

    group('sign', () {
      test('ينشئ توقيع غير فارغ', () {
        final signature = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        expect(signature.signature, isNotEmpty);
        expect(signature.timestamp, greaterThan(0));
        expect(signature.nonce, isNotEmpty);
      });

      test('ينشئ توقيعات مختلفة لطلبات مختلفة', () {
        final sig1 = RequestSigner.sign(method: 'POST', path: '/api/sales');
        final sig2 = RequestSigner.sign(method: 'POST', path: '/api/products');

        expect(sig1.signature, isNot(equals(sig2.signature)));
      });

      test('ينشئ توقيعات مختلفة للـ methods مختلفة', () {
        final sig1 = RequestSigner.sign(method: 'POST', path: '/api/sales');
        final sig2 = RequestSigner.sign(method: 'PUT', path: '/api/sales');

        expect(sig1.signature, isNot(equals(sig2.signature)));
      });

      test('يشمل الـ body في التوقيع', () {
        final sig1 = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
          body: {'amount': 100},
        );
        final sig2 = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
          body: {'amount': 200},
        );

        expect(sig1.signature, isNot(equals(sig2.signature)));
      });

      test('يشمل الـ query params في التوقيع', () {
        final sig1 = RequestSigner.sign(
          method: 'GET',
          path: '/api/sales',
          queryParams: {'page': '1'},
        );
        final sig2 = RequestSigner.sign(
          method: 'GET',
          path: '/api/sales',
          queryParams: {'page': '2'},
        );

        expect(sig1.signature, isNot(equals(sig2.signature)));
      });

      test('يرمي استثناء إذا لم يكن مهيئاً', () {
        // إعادة تعيين
        RequestSigner.initialize('');

        expect(
          () => RequestSigner.sign(method: 'POST', path: '/api/test'),
          throwsA(isA<SigningException>()),
        );

        // إعادة التهيئة للاختبارات الأخرى
        RequestSigner.initialize(testSigningKey);
      });
    });

    group('verify', () {
      test('يتحقق من توقيع صحيح', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/sales',
        );

        expect(isValid, isTrue);
      });

      test('يرفض توقيع خاطئ', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        final isValid = RequestSigner.verify(
          signature: 'invalid-signature',
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/sales',
        );

        expect(isValid, isFalse);
      });

      test('يرفض timestamp قديم جداً', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        // timestamp من 10 دقائق مضت
        final oldTimestamp = sig.timestamp - (10 * 60 * 1000);

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: oldTimestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/sales',
        );

        expect(isValid, isFalse);
      });

      test('يرفض إذا تغير الـ path', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/products', // path مختلف
        );

        expect(isValid, isFalse);
      });

      test('يرفض إذا تغير الـ method', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'PUT', // method مختلف
          path: '/api/sales',
        );

        expect(isValid, isFalse);
      });

      test('يتحقق مع body صحيح', () {
        final body = {'amount': 100, 'currency': 'SAR'};
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
          body: body,
        );

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/sales',
          body: body,
        );

        expect(isValid, isTrue);
      });

      test('يرفض مع body مختلف', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
          body: {'amount': 100},
        );

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/sales',
          body: {'amount': 200}, // قيمة مختلفة
        );

        expect(isValid, isFalse);
      });

      test('يقبل maxAge مخصص', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/sales',
        );

        final isValid = RequestSigner.verify(
          signature: sig.signature,
          timestamp: sig.timestamp,
          nonce: sig.nonce,
          method: 'POST',
          path: '/api/sales',
          maxAge: const Duration(minutes: 10),
        );

        expect(isValid, isTrue);
      });
    });

    group('RequestSignature', () {
      test('toHeaders يعيد headers صحيحة', () {
        final sig = RequestSigner.sign(
          method: 'POST',
          path: '/api/test',
        );

        final headers = sig.toHeaders();

        expect(headers, containsPair('X-Signature', sig.signature));
        expect(headers, containsPair('X-Timestamp', sig.timestamp.toString()));
        expect(headers, containsPair('X-Nonce', sig.nonce));
      });
    });

    group('getSignatureHeaders', () {
      test('يعيد headers صحيحة', () {
        final sig = RequestSignature(
          signature: 'test-sig',
          timestamp: 12345,
          nonce: 'test-nonce',
        );

        final headers = RequestSigner.getSignatureHeaders(sig);

        expect(headers['X-Signature'], equals('test-sig'));
        expect(headers['X-Timestamp'], equals('12345'));
        expect(headers['X-Nonce'], equals('test-nonce'));
      });
    });
  });

  group('SigningException', () {
    test('يحتوي على الرسالة الصحيحة', () {
      final exception = SigningException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.toString(), contains('Test error'));
    });
  });

  group('SignedRequestMixin', () {
    setUp(() {
      RequestSigner.initialize(testSigningKey);
    });

    test('signRequest يضيف headers التوقيع', () {
      final service = _TestService();

      final headers = service.signRequest(
        method: 'POST',
        path: '/api/sales',
      );

      expect(headers, contains('X-Signature'));
      expect(headers, contains('X-Timestamp'));
      expect(headers, contains('X-Nonce'));
    });

    test('signRequest يحافظ على الـ headers الموجودة', () {
      final service = _TestService();

      final headers = service.signRequest(
        method: 'POST',
        path: '/api/sales',
        existingHeaders: {'Authorization': 'Bearer token'},
      );

      expect(headers['Authorization'], equals('Bearer token'));
      expect(headers, contains('X-Signature'));
    });

    test('signRequest يعمل بدون body', () {
      final service = _TestService();

      final headers = service.signRequest(
        method: 'GET',
        path: '/api/sales',
      );

      expect(headers, contains('X-Signature'));
    });

    test('signRequest يعمل مع body', () {
      final service = _TestService();

      final headers = service.signRequest(
        method: 'POST',
        path: '/api/sales',
        body: {'test': 'data'},
      );

      expect(headers, contains('X-Signature'));
    });
  });
}

/// فئة اختبار للـ Mixin
class _TestService with SignedRequestMixin {}
