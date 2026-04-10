import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_services/alhai_services.dart';

void main() {
  late ImportService importService;

  setUp(() {
    importService = ImportService();
  });

  group('ImportService', () {
    test('should be created', () {
      expect(importService, isNotNull);
    });

    group('importProductsFromCsv', () {
      test('should import valid products', () {
        const csv =
            'الباركود,اسم المنتج,السعر,المخزون,الفئة\n6281234567890,Coffee,15.00,100,cat-1\n,Tea,10.00,50,';

        final result = importService.importProductsFromCsv(csv);

        expect(result.success, isTrue);
        expect(result.imported, hasLength(2));
        expect(result.imported[0].name, equals('Coffee'));
        expect(result.imported[0].price, equals(15.0));
        expect(result.imported[1].name, equals('Tea'));
      });

      test('should skip rows with missing name', () {
        const csv = 'الباركود,اسم المنتج,السعر\n628000,,15.00';

        final result = importService.importProductsFromCsv(csv);

        expect(result.imported, isEmpty);
        expect(result.failed, hasLength(1));
        expect(result.failed.first.error, contains('اسم المنتج'));
      });

      test('should skip rows with zero or negative price', () {
        const csv = 'الباركود,اسم المنتج,السعر\n628000,Product,0.00';

        final result = importService.importProductsFromCsv(csv);

        expect(result.imported, isEmpty);
        expect(result.failed, hasLength(1));
        expect(result.failed.first.error, contains('السعر'));
      });

      test('should skip rows with insufficient columns', () {
        const csv = 'الباركود,اسم المنتج,السعر\n628000,Product';

        final result = importService.importProductsFromCsv(csv);

        expect(result.imported, isEmpty);
        expect(result.failed, hasLength(1));
      });

      test('should return error for empty file', () {
        final result = importService.importProductsFromCsv('');

        expect(result.success, isFalse);
        expect(result.error, contains('فارغ'));
      });

      test('should handle CSV with quotes', () {
        const csv =
            'الباركود,اسم المنتج,السعر\n628000,"Product, Special",15.00';

        final result = importService.importProductsFromCsv(csv);

        expect(result.imported, hasLength(1));
        expect(result.imported.first.name, equals('Product, Special'));
      });
    });

    group('importCustomersFromCsv', () {
      test('should import valid customers', () {
        const csv =
            'الاسم,الهاتف,العنوان\nAhmed,0512345678,Riyadh\nAli,0523456789,Jeddah';

        final result = importService.importCustomersFromCsv(csv);

        expect(result.success, isTrue);
        expect(result.imported, hasLength(2));
        expect(result.imported[0]['name'], equals('Ahmed'));
        expect(result.imported[0]['phone'], equals('0512345678'));
      });

      test('should skip rows without name', () {
        const csv = 'الاسم,الهاتف\n,0512345678';

        final result = importService.importCustomersFromCsv(csv);

        expect(result.imported, isEmpty);
        expect(result.failed, hasLength(1));
      });

      test('should skip rows without phone', () {
        const csv = 'الاسم,الهاتف\nAhmed,';

        final result = importService.importCustomersFromCsv(csv);

        expect(result.imported, isEmpty);
        expect(result.failed, hasLength(1));
      });

      test('should return error for empty file', () {
        final result = importService.importCustomersFromCsv('');
        expect(result.success, isFalse);
      });
    });

    group('importFromJson', () {
      test('should import JSON array', () {
        final jsonStr = jsonEncode([
          {'name': 'A', 'price': 10},
          {'name': 'B', 'price': 20},
        ]);

        final result = importService.importFromJson(jsonStr);

        expect(result.success, isTrue);
        expect(result.imported, hasLength(2));
      });

      test('should import single JSON object', () {
        final jsonStr = jsonEncode({'name': 'A', 'price': 10});

        final result = importService.importFromJson(jsonStr);

        expect(result.success, isTrue);
        expect(result.imported, hasLength(1));
      });

      test('should fail for invalid JSON', () {
        final result = importService.importFromJson('not-json');

        expect(result.success, isFalse);
        expect(result.error, contains('JSON'));
      });

      test('should fail for non-object/array JSON', () {
        final result = importService.importFromJson('"just a string"');

        expect(result.success, isFalse);
      });
    });

    group('validateCsv', () {
      test('should validate CSV with all required columns', () {
        const csv = 'الباركود,اسم المنتج,السعر\n628000,Product,15.00';

        final result = importService.validateCsv(
          csv,
          ['الباركود', 'اسم المنتج', 'السعر'],
        );

        expect(result.isValid, isTrue);
        expect(result.rowCount, equals(1));
        expect(result.columnCount, equals(3));
      });

      test('should reject CSV missing required columns', () {
        const csv = 'الباركود,اسم المنتج\n628000,Product';

        final result = importService.validateCsv(
          csv,
          ['الباركود', 'اسم المنتج', 'السعر'],
        );

        expect(result.isValid, isFalse);
        expect(result.error, contains('السعر'));
      });

      test('should reject empty CSV', () {
        final result = importService.validateCsv('', ['col1']);

        expect(result.isValid, isFalse);
        expect(result.error, contains('فارغ'));
      });
    });

    group('templates', () {
      test('should generate products template', () {
        final template = importService.generateProductsTemplate();
        expect(template, contains('اسم المنتج'));
        expect(template, contains('السعر'));
        expect(template.split('\n'), hasLength(2));
      });

      test('should generate customers template', () {
        final template = importService.generateCustomersTemplate();
        expect(template, contains('الاسم'));
        expect(template, contains('الهاتف'));
      });
    });

    group('ImportResult', () {
      test('should compute counts correctly', () {
        final result = ImportResult<String>(
          success: true,
          imported: ['a', 'b', 'c'],
          failed: [
            const ImportError(line: 4, error: 'bad'),
          ],
        );

        expect(result.totalRows, equals(4));
        expect(result.successCount, equals(3));
        expect(result.failedCount, equals(1));
      });
    });
  });
}
