import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/web_encryption_service.dart';

void main() {
  const testPassword = 'test-encryption-password-123';
  const testSalt = 'test-salt-for-encryption';

  setUp(() async {
    WebEncryptionService.reset();
    await WebEncryptionService.initialize(
      testPassword,
      salt: testSalt,
      config: EncryptionConfig.fast, // استخدام تكوين سريع للاختبارات
    );
  });

  tearDown(() {
    WebEncryptionService.reset();
  });

  group('WebEncryptionService', () {
    group('initialization', () {
      test('يتم تهيئة الخدمة بنجاح', () async {
        expect(WebEncryptionService.isInitialized, isTrue);
      });

      test('يرمي استثناء عند الاستخدام بدون تهيئة', () async {
        WebEncryptionService.reset();

        expect(
          () => WebEncryptionService.encrypt('test'),
          throwsA(isA<EncryptionException>()),
        );
      });

      test('reset يعيد تعيين الحالة', () {
        WebEncryptionService.reset();
        expect(WebEncryptionService.isInitialized, isFalse);
      });
    });

    group('encrypt/decrypt', () {
      test('يشفر ويفك تشفير نص بنجاح', () async {
        const plaintext = 'Hello, World! مرحبا بالعالم';

        final encrypted = await WebEncryptionService.encrypt(plaintext);
        final decrypted = await WebEncryptionService.decrypt(encrypted);

        expect(decrypted, equals(plaintext));
      });

      test('التشفير ينتج نص مختلف عن الأصلي', () async {
        const plaintext = 'Secret data';

        final encrypted = await WebEncryptionService.encrypt(plaintext);

        expect(encrypted, isNot(equals(plaintext)));
        expect(encrypted, isNot(contains(plaintext)));
      });

      test('تشفيران مختلفان لنفس النص ينتجان نتائج مختلفة (IV مختلف)', () async {
        const plaintext = 'Same text';

        final encrypted1 = await WebEncryptionService.encrypt(plaintext);
        final encrypted2 = await WebEncryptionService.encrypt(plaintext);

        expect(encrypted1, isNot(equals(encrypted2)));

        // كلاهما يفك تشفيرهما لنفس النص
        final decrypted1 = await WebEncryptionService.decrypt(encrypted1);
        final decrypted2 = await WebEncryptionService.decrypt(encrypted2);
        expect(decrypted1, equals(decrypted2));
      });

      test('يشفر نص طويل بنجاح', () async {
        final plaintext = 'A' * 10000; // 10K characters

        final encrypted = await WebEncryptionService.encrypt(plaintext);
        final decrypted = await WebEncryptionService.decrypt(encrypted);

        expect(decrypted, equals(plaintext));
      });

      test('يشفر نص فارغ', () async {
        const plaintext = '';

        final encrypted = await WebEncryptionService.encrypt(plaintext);
        final decrypted = await WebEncryptionService.decrypt(encrypted);

        expect(decrypted, equals(plaintext));
      });

      test('يشفر أحرف خاصة و Unicode', () async {
        const plaintext = '特殊文字 🎉 émojis & symbols: <>"\'`';

        final encrypted = await WebEncryptionService.encrypt(plaintext);
        final decrypted = await WebEncryptionService.decrypt(encrypted);

        expect(decrypted, equals(plaintext));
      });

      test('يرفض بيانات مشفرة تم التلاعب بها', () async {
        const plaintext = 'Sensitive data';
        final encrypted = await WebEncryptionService.encrypt(plaintext);

        // التلاعب بالبيانات المشفرة
        final tampered = '${encrypted}tampered';

        expect(
          () => WebEncryptionService.decrypt(tampered),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('encryptJson/decryptJson', () {
      test('يشفر ويفك تشفير Map', () async {
        final data = {
          'name': 'John',
          'age': 30,
          'email': 'john@example.com',
          'arabicName': 'يوحنا',
        };

        final encrypted = await WebEncryptionService.encryptJson(data);
        final decrypted = await WebEncryptionService.decryptJson(encrypted);

        expect(decrypted, equals(data));
      });

      test('يشفر Map متداخل', () async {
        final data = {
          'user': {
            'profile': {
              'name': 'Test',
              'settings': {'theme': 'dark'},
            }
          }
        };

        final encrypted = await WebEncryptionService.encryptJson(data);
        final decrypted = await WebEncryptionService.decryptJson(encrypted);

        expect(decrypted, equals(data));
      });

      test('يشفر Map مع أنواع مختلفة', () async {
        final data = {
          'string': 'text',
          'number': 123,
          'double': 45.67,
          'bool': true,
          'null': null,
          'list': [1, 2, 3],
        };

        final encrypted = await WebEncryptionService.encryptJson(data);
        final decrypted = await WebEncryptionService.decryptJson(encrypted);

        expect(decrypted, equals(data));
      });
    });

    group('encryptList/decryptList', () {
      test('يشفر ويفك تشفير قائمة', () async {
        final data = [1, 'two', 3.0, true, null];

        final encrypted = await WebEncryptionService.encryptList(data);
        final decrypted = await WebEncryptionService.decryptList(encrypted);

        expect(decrypted, equals(data));
      });

      test('يشفر قائمة من Maps', () async {
        final data = [
          {'id': 1, 'name': 'Item 1'},
          {'id': 2, 'name': 'Item 2'},
        ];

        final encrypted = await WebEncryptionService.encryptList(data);
        final decrypted = await WebEncryptionService.decryptList(encrypted);

        expect(decrypted, equals(data));
      });
    });

    group('encryptSensitiveFields/decryptSensitiveFields', () {
      test('يشفر حقول محددة فقط', () async {
        final data = {
          'id': '123',
          'name': 'Public Name',
          'password': 'secret123',
          'pin': '1234',
        };
        const sensitiveFields = ['password', 'pin'];

        final encrypted = await WebEncryptionService.encryptSensitiveFields(
          data,
          sensitiveFields,
        );

        // الحقول العادية لم تتغير
        expect(encrypted['id'], equals('123'));
        expect(encrypted['name'], equals('Public Name'));

        // الحقول الحساسة مشفرة
        expect(encrypted['password'], isA<Map>());
        expect((encrypted['password'] as Map).containsKey('_encrypted'), isTrue);
        expect(encrypted['pin'], isA<Map>());

        // فك التشفير
        final decrypted = await WebEncryptionService.decryptSensitiveFields(
          encrypted,
          sensitiveFields,
        );

        expect(decrypted['password'], equals('secret123'));
        expect(decrypted['pin'], equals('1234'));
      });

      test('يتعامل مع حقول غير موجودة', () async {
        final data = {'name': 'Test'};
        const sensitiveFields = ['password', 'pin'];

        final encrypted = await WebEncryptionService.encryptSensitiveFields(
          data,
          sensitiveFields,
        );

        expect(encrypted, equals({'name': 'Test'}));
      });

      test('يتعامل مع حقول null', () async {
        final data = {'name': 'Test', 'password': null};
        const sensitiveFields = ['password'];

        final encrypted = await WebEncryptionService.encryptSensitiveFields(
          data,
          sensitiveFields,
        );

        expect(encrypted['password'], isNull);
      });
    });

    group('generateRandomKey', () {
      test('يولد مفتاح بالطول الافتراضي', () {
        final key = WebEncryptionService.generateRandomKey();
        expect(key.isNotEmpty, isTrue);
      });

      test('يولد مفتاح بطول مخصص', () {
        final key16 = WebEncryptionService.generateRandomKey(length: 16);
        final key64 = WebEncryptionService.generateRandomKey(length: 64);

        // Base64 encoding increases length by ~33%
        expect(key16.length, lessThan(key64.length));
      });

      test('يولد مفاتيح مختلفة في كل مرة', () {
        final key1 = WebEncryptionService.generateRandomKey();
        final key2 = WebEncryptionService.generateRandomKey();

        expect(key1, isNot(equals(key2)));
      });
    });

    group('computeHash', () {
      test('يحسب hash صحيح', () {
        final hash = WebEncryptionService.computeHash('test');

        expect(hash.length, equals(64)); // SHA-256 = 64 hex chars
      });

      test('نفس المدخل يعطي نفس الـ hash', () {
        final hash1 = WebEncryptionService.computeHash('same input');
        final hash2 = WebEncryptionService.computeHash('same input');

        expect(hash1, equals(hash2));
      });

      test('مدخلات مختلفة تعطي hashes مختلفة', () {
        final hash1 = WebEncryptionService.computeHash('input1');
        final hash2 = WebEncryptionService.computeHash('input2');

        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('different passwords', () {
      test('مفاتيح مختلفة لا يمكنها فك تشفير بعضها', () async {
        const plaintext = 'Secret message';
        final encrypted = await WebEncryptionService.encrypt(plaintext);

        // إعادة تهيئة بكلمة مرور مختلفة
        WebEncryptionService.reset();
        await WebEncryptionService.initialize(
          'different-password',
          salt: testSalt,
          config: EncryptionConfig.fast,
        );

        // يجب أن يفشل فك التشفير أو يعطي نتيجة خاطئة
        expect(
          () => WebEncryptionService.decrypt(encrypted),
          throwsA(isA<Exception>()),
        );
      });
    });
  });

  group('EncryptionResult', () {
    test('toJson و fromJson يعملان', () {
      const result = EncryptionResult(
        ciphertext: 'encrypted_data',
        iv: 'initialization_vector',
        tag: 'auth_tag',
        algorithm: 'aes256Gcm',
        version: 1,
      );

      final json = result.toJson();
      final restored = EncryptionResult.fromJson(json);

      expect(restored.ciphertext, equals(result.ciphertext));
      expect(restored.iv, equals(result.iv));
      expect(restored.tag, equals(result.tag));
      expect(restored.algorithm, equals(result.algorithm));
      expect(restored.version, equals(result.version));
    });

    test('toEncodedString و fromEncodedString يعملان', () {
      const result = EncryptionResult(
        ciphertext: 'encrypted_data',
        iv: 'iv',
        tag: 'tag',
        algorithm: 'aes256Gcm',
      );

      final encoded = result.toEncodedString();
      final restored = EncryptionResult.fromEncodedString(encoded);

      expect(restored.ciphertext, equals(result.ciphertext));
    });
  });

  group('EncryptionConfig', () {
    test('production config صحيح', () {
      expect(EncryptionConfig.production.algorithm, equals(EncryptionAlgorithm.aes256Gcm));
      expect(EncryptionConfig.production.keyLength, equals(256));
      expect(EncryptionConfig.production.pbkdf2Iterations, equals(100000));
    });

    test('fast config صحيح', () {
      expect(EncryptionConfig.fast.pbkdf2Iterations, equals(10000));
    });
  });

  group('EncryptionException', () {
    test('toString يعيد رسالة صحيحة', () {
      const exception = EncryptionException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('toString يتضمن السبب', () {
      final exception = EncryptionException('Test error', Exception('Cause'));
      expect(exception.toString(), contains('Cause'));
    });
  });

  group('Extensions', () {
    test('String.encrypted يعمل', () async {
      const text = 'Test text';
      final encrypted = await text.encrypted;
      expect(encrypted, isNot(equals(text)));
    });

    test('String.hashed يعمل', () {
      const text = 'Test text';
      final hashed = text.hashed;
      expect(hashed.length, equals(64));
    });
  });
}
