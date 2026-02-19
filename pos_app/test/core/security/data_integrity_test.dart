import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/security/data_integrity.dart';

void main() {
  const testKey = 'test-hmac-key-for-integrity-checking';

  setUp(() {
    DataIntegrity.initialize(testKey);
    DataIntegrity.clear();
  });

  group('DataIntegrity', () {
    group('computeHash', () {
      test('يحسب hash لـ Map', () {
        final hash = DataIntegrity.computeHash({'name': 'Test', 'value': 100});
        expect(hash, isNotEmpty);
        expect(hash.length, equals(64)); // SHA-256 = 64 hex chars
      });

      test('يعطي نفس الـ hash لنفس البيانات', () {
        final data = {'name': 'Test', 'value': 100};
        final hash1 = DataIntegrity.computeHash(data);
        final hash2 = DataIntegrity.computeHash(data);
        expect(hash1, equals(hash2));
      });

      test('يعطي hash مختلف لبيانات مختلفة', () {
        final hash1 = DataIntegrity.computeHash({'value': 100});
        final hash2 = DataIntegrity.computeHash({'value': 200});
        expect(hash1, isNot(equals(hash2)));
      });

      test('يعطي نفس الـ hash بغض النظر عن ترتيب المفاتيح', () {
        final hash1 = DataIntegrity.computeHash({'a': 1, 'b': 2});
        final hash2 = DataIntegrity.computeHash({'b': 2, 'a': 1});
        expect(hash1, equals(hash2));
      });
    });

    group('computeHmac', () {
      test('يحسب HMAC', () {
        final hmac = DataIntegrity.computeHmac({'test': 'data'});
        expect(hmac, isNotEmpty);
        expect(hmac.length, equals(64));
      });

      test('HMAC مختلف عن Hash', () {
        final data = {'test': 'data'};
        final hash = DataIntegrity.computeHash(data);
        final hmac = DataIntegrity.computeHmac(data);
        expect(hash, isNot(equals(hmac)));
      });
    });

    group('registerHash & verifyIntegrity', () {
      test('يسجل ويتحقق من hash', () {
        final data = {'id': '1', 'name': 'Product', 'price': 100};

        DataIntegrity.registerHash('product:1', data);

        final result = DataIntegrity.verifyIntegrity('product:1', data);
        expect(result.isValid, isTrue);
      });

      test('يكشف التغيير في البيانات', () {
        final data = {'id': '1', 'price': 100};

        DataIntegrity.registerHash('product:1', data);

        final modifiedData = {'id': '1', 'price': 200}; // تم تغيير السعر
        final result = DataIntegrity.verifyIntegrity('product:1', modifiedData);

        expect(result.isValid, isFalse);
        expect(result.violations, contains('Data has been modified'));
      });

      test('يرفض مفتاح غير مسجل', () {
        final result = DataIntegrity.verifyIntegrity('unknown:key', {'test': 1});

        expect(result.isValid, isFalse);
        expect(result.violations.first, contains('No stored hash'));
      });
    });

    group('verifyHmac', () {
      test('يتحقق من HMAC صحيح', () {
        final data = {'test': 'data'};
        final hmac = DataIntegrity.computeHmac(data);

        final isValid = DataIntegrity.verifyHmac(data, hmac);
        expect(isValid, isTrue);
      });

      test('يرفض HMAC خاطئ', () {
        final data = {'test': 'data'};

        final isValid = DataIntegrity.verifyHmac(data, 'invalid-hmac');
        expect(isValid, isFalse);
      });
    });

    group('logChange & verifyChangeLog', () {
      test('يسجل التغييرات', () {
        DataIntegrity.logChange(
          entityType: 'product',
          entityId: 'p1',
          fieldName: 'price',
          oldValue: 100,
          newValue: 150,
        );

        final history = DataIntegrity.getChangeHistory(
          entityType: 'product',
          entityId: 'p1',
        );

        expect(history, hasLength(1));
        expect(history.first.oldValue, equals(100));
        expect(history.first.newValue, equals(150));
      });

      test('يتحقق من سلامة سجل التغييرات', () {
        DataIntegrity.logChange(
          entityType: 'product',
          entityId: 'p1',
          fieldName: 'price',
          oldValue: 100,
          newValue: 150,
        );

        final isValid = DataIntegrity.verifyChangeLog();
        expect(isValid, isTrue);
      });
    });

    group('computeListChecksum', () {
      test('يحسب checksum لقائمة', () {
        final items = [
          {'id': '1', 'name': 'A'},
          {'id': '2', 'name': 'B'},
        ];

        final checksum = DataIntegrity.computeListChecksum(items);
        expect(checksum, isNotEmpty);
      });

      test('نفس الـ checksum بغض النظر عن الترتيب', () {
        final items1 = [
          {'id': '1', 'name': 'A'},
          {'id': '2', 'name': 'B'},
        ];
        final items2 = [
          {'id': '2', 'name': 'B'},
          {'id': '1', 'name': 'A'},
        ];

        final checksum1 = DataIntegrity.computeListChecksum(items1);
        final checksum2 = DataIntegrity.computeListChecksum(items2);

        expect(checksum1, equals(checksum2));
      });
    });

    group('verifyListChecksum', () {
      test('يتحقق من checksum صحيح', () {
        final items = [
          {'id': '1', 'name': 'A'},
          {'id': '2', 'name': 'B'},
        ];
        final checksum = DataIntegrity.computeListChecksum(items);

        final isValid = DataIntegrity.verifyListChecksum(items, checksum);
        expect(isValid, isTrue);
      });

      test('يكشف التغيير في القائمة', () {
        final items = [
          {'id': '1', 'name': 'A'},
          {'id': '2', 'name': 'B'},
        ];
        final checksum = DataIntegrity.computeListChecksum(items);

        // تغيير عنصر
        items[0]['name'] = 'Modified';

        final isValid = DataIntegrity.verifyListChecksum(items, checksum);
        expect(isValid, isFalse);
      });
    });

    group('sign & verify', () {
      test('يوقع ويتحقق', () {
        final data = {'important': 'data'};
        final signature = DataIntegrity.sign(data);

        final isValid = DataIntegrity.verify(data, signature);
        expect(isValid, isTrue);
      });

      test('يرفض توقيع خاطئ', () {
        final data = {'important': 'data'};

        final isValid = DataIntegrity.verify(data, 'fake-signature');
        expect(isValid, isFalse);
      });
    });
  });

  group('IntegrityCheckResult', () {
    test('valid factory يعمل', () {
      final result = IntegrityCheckResult.valid();
      expect(result.isValid, isTrue);
      expect(result.violations, isEmpty);
    });

    test('invalid factory يعمل', () {
      final result = IntegrityCheckResult.invalid(
        expected: 'hash1',
        actual: 'hash2',
        violations: ['Mismatch'],
      );
      expect(result.isValid, isFalse);
      expect(result.expectedHash, equals('hash1'));
      expect(result.actualHash, equals('hash2'));
    });
  });

  group('ChangeRecord', () {
    test('toJson يعمل', () {
      final record = ChangeRecord(
        entityType: 'product',
        entityId: 'p1',
        fieldName: 'price',
        oldValue: 100,
        newValue: 150,
        hash: 'testhash',
      );

      final json = record.toJson();

      expect(json['entityType'], equals('product'));
      expect(json['entityId'], equals('p1'));
      expect(json['oldValue'], equals(100));
      expect(json['newValue'], equals(150));
    });
  });
}
