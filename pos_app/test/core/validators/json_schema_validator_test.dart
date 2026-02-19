import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/validators/json_schema_validator.dart';

void main() {
  group('JsonSchemaType', () {
    test('يحتوي على جميع الأنواع المدعومة', () {
      expect(JsonSchemaType.values, contains(JsonSchemaType.string));
      expect(JsonSchemaType.values, contains(JsonSchemaType.number));
      expect(JsonSchemaType.values, contains(JsonSchemaType.integer));
      expect(JsonSchemaType.values, contains(JsonSchemaType.boolean));
      expect(JsonSchemaType.values, contains(JsonSchemaType.object));
      expect(JsonSchemaType.values, contains(JsonSchemaType.array));
      expect(JsonSchemaType.values, contains(JsonSchemaType.any));
    });
  });

  group('SchemaValidationResult', () {
    test('valid factory يعمل', () {
      final result = SchemaValidationResult.valid();

      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);
    });

    test('invalid factory يعمل', () {
      final errors = [
        const SchemaValidationError(path: 'root', message: 'Test error'),
      ];
      final result = SchemaValidationResult.invalid(errors);

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(1));
    });

    test('toString يعمل للنتيجة الصالحة', () {
      final result = SchemaValidationResult.valid();
      expect(result.toString(), contains('valid'));
    });

    test('toString يعمل للنتيجة غير الصالحة', () {
      final result = SchemaValidationResult.invalid([
        const SchemaValidationError(path: 'root', message: 'Error'),
      ]);
      expect(result.toString(), contains('invalid'));
      expect(result.toString(), contains('1 errors'));
    });
  });

  group('SchemaValidationError', () {
    test('toString يعيد التنسيق الصحيح', () {
      const error = SchemaValidationError(
        path: 'root.name',
        message: 'Required field is missing',
      );

      expect(error.toString(), equals('[root.name] Required field is missing'));
    });

    test('toJson يعمل بشكل صحيح', () {
      const error = SchemaValidationError(
        path: 'root.age',
        message: 'Invalid type',
        expectedType: 'integer',
        actualType: 'String',
      );

      final json = error.toJson();

      expect(json['path'], equals('root.age'));
      expect(json['message'], equals('Invalid type'));
      expect(json['expectedType'], equals('integer'));
      expect(json['actualType'], equals('String'));
    });

    test('toJson يتجاهل القيم الفارغة', () {
      const error = SchemaValidationError(
        path: 'root',
        message: 'Error',
      );

      final json = error.toJson();

      expect(json.containsKey('expectedType'), isFalse);
      expect(json.containsKey('actualType'), isFalse);
    });
  });

  group('JsonSchema factories', () {
    test('JsonSchema.string ينشئ schema صحيح', () {
      final schema = JsonSchema.string(
        required: true,
        minLength: 1,
        maxLength: 100,
        pattern: r'^[a-z]+$',
      );

      expect(schema.type, equals(JsonSchemaType.string));
      expect(schema.required, isTrue);
      expect(schema.minLength, equals(1));
      expect(schema.maxLength, equals(100));
      expect(schema.pattern, equals(r'^[a-z]+$'));
    });

    test('JsonSchema.number ينشئ schema صحيح', () {
      final schema = JsonSchema.number(
        required: true,
        minimum: 0,
        maximum: 100,
        multipleOf: 0.5,
      );

      expect(schema.type, equals(JsonSchemaType.number));
      expect(schema.required, isTrue);
      expect(schema.minimum, equals(0));
      expect(schema.maximum, equals(100));
      expect(schema.multipleOf, equals(0.5));
    });

    test('JsonSchema.integer ينشئ schema صحيح', () {
      final schema = JsonSchema.integer(
        required: true,
        minimum: 1,
        maximum: 10,
      );

      expect(schema.type, equals(JsonSchemaType.integer));
      expect(schema.required, isTrue);
      expect(schema.minimum, equals(1));
      expect(schema.maximum, equals(10));
    });

    test('JsonSchema.boolean ينشئ schema صحيح', () {
      final schema = JsonSchema.boolean(
        required: true,
        defaultValue: false,
      );

      expect(schema.type, equals(JsonSchemaType.boolean));
      expect(schema.required, isTrue);
      expect(schema.defaultValue, equals(false));
    });

    test('JsonSchema.array ينشئ schema صحيح', () {
      final schema = JsonSchema.array(
        required: true,
        items: JsonSchema.string(),
        minItems: 1,
        maxItems: 10,
        uniqueItems: true,
      );

      expect(schema.type, equals(JsonSchemaType.array));
      expect(schema.required, isTrue);
      expect(schema.items, isNotNull);
      expect(schema.minItems, equals(1));
      expect(schema.maxItems, equals(10));
      expect(schema.uniqueItems, isTrue);
    });

    test('JsonSchema.object ينشئ schema صحيح', () {
      final schema = JsonSchema.object(
        required: true,
        properties: {
          'name': JsonSchema.string(required: true),
          'age': JsonSchema.integer(),
        },
        requiredProperties: ['name'],
        additionalProperties: false,
      );

      expect(schema.type, equals(JsonSchemaType.object));
      expect(schema.required, isTrue);
      expect(schema.properties, isNotNull);
      expect(schema.properties!.length, equals(2));
      expect(schema.requiredProperties, contains('name'));
      expect(schema.additionalProperties, isFalse);
    });
  });

  group('JsonSchemaValidator - Type Validation', () {
    test('يقبل string صالح', () {
      final schema = JsonSchema.string();
      final result = JsonSchemaValidator.validate('hello', schema);

      expect(result.isValid, isTrue);
    });

    test('يرفض نوع خاطئ لـ string', () {
      final schema = JsonSchema.string();
      final result = JsonSchemaValidator.validate(123, schema);

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('Invalid type'));
    });

    test('يقبل number صالح', () {
      final schema = JsonSchema.number();
      final result = JsonSchemaValidator.validate(3.14, schema);

      expect(result.isValid, isTrue);
    });

    test('يقبل integer صالح', () {
      final schema = JsonSchema.integer();
      final result = JsonSchemaValidator.validate(42, schema);

      expect(result.isValid, isTrue);
    });

    test('يقبل boolean صالح', () {
      final schema = JsonSchema.boolean();
      final result = JsonSchemaValidator.validate(true, schema);

      expect(result.isValid, isTrue);
    });

    test('يقبل array صالح', () {
      final schema = JsonSchema.array();
      final result = JsonSchemaValidator.validate([1, 2, 3], schema);

      expect(result.isValid, isTrue);
    });

    test('يقبل object صالح', () {
      final schema = JsonSchema.object();
      final result = JsonSchemaValidator.validate({'key': 'value'}, schema);

      expect(result.isValid, isTrue);
    });

    test('any يقبل أي نوع', () {
      const schema = JsonSchema(type: JsonSchemaType.any);

      expect(JsonSchemaValidator.validate('string', schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(123, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(true, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate([1, 2], schema).isValid, isTrue);
    });
  });

  group('JsonSchemaValidator - Required Validation', () {
    test('يفشل عند null لـ required field', () {
      final schema = JsonSchema.string(required: true);
      final result = JsonSchemaValidator.validate(null, schema);

      expect(result.isValid, isFalse);
      expect(result.errors.first.message, contains('Required'));
    });

    test('يقبل null لـ optional field', () {
      final schema = JsonSchema.string(required: false);
      final result = JsonSchemaValidator.validate(null, schema);

      expect(result.isValid, isTrue);
    });
  });

  group('JsonSchemaValidator - String Validation', () {
    test('يتحقق من minLength', () {
      final schema = JsonSchema.string(minLength: 5);

      expect(JsonSchemaValidator.validate('hi', schema).isValid, isFalse);
      expect(JsonSchemaValidator.validate('hello', schema).isValid, isTrue);
    });

    test('يتحقق من maxLength', () {
      final schema = JsonSchema.string(maxLength: 5);

      expect(JsonSchemaValidator.validate('hello', schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate('hello world', schema).isValid, isFalse);
    });

    test('يتحقق من pattern', () {
      final schema = JsonSchema.string(pattern: r'^[0-9]+$');

      expect(JsonSchemaValidator.validate('12345', schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate('abc', schema).isValid, isFalse);
    });

    test('يتحقق من enumValues', () {
      final schema = JsonSchema.string(enumValues: ['red', 'green', 'blue']);

      expect(JsonSchemaValidator.validate('red', schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate('yellow', schema).isValid, isFalse);
    });

    test('رسالة خطأ pattern واضحة', () {
      final schema = JsonSchema.string(pattern: r'^[a-z]+$');
      final result = JsonSchemaValidator.validate('123', schema);

      expect(result.errors.first.message, contains('does not match pattern'));
    });

    test('رسالة خطأ enum واضحة', () {
      final schema = JsonSchema.string(enumValues: ['a', 'b']);
      final result = JsonSchemaValidator.validate('c', schema);

      expect(result.errors.first.message, contains('must be one of'));
    });
  });

  group('JsonSchemaValidator - Number Validation', () {
    test('يتحقق من minimum', () {
      final schema = JsonSchema.number(minimum: 10);

      expect(JsonSchemaValidator.validate(10, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(5, schema).isValid, isFalse);
    });

    test('يتحقق من maximum', () {
      final schema = JsonSchema.number(maximum: 100);

      expect(JsonSchemaValidator.validate(100, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(150, schema).isValid, isFalse);
    });

    test('يتحقق من exclusiveMinimum', () {
      const schema = JsonSchema(
        type: JsonSchemaType.number,
        exclusiveMinimum: 10,
      );

      expect(JsonSchemaValidator.validate(10, schema).isValid, isFalse);
      expect(JsonSchemaValidator.validate(11, schema).isValid, isTrue);
    });

    test('يتحقق من exclusiveMaximum', () {
      const schema = JsonSchema(
        type: JsonSchemaType.number,
        exclusiveMaximum: 100,
      );

      expect(JsonSchemaValidator.validate(100, schema).isValid, isFalse);
      expect(JsonSchemaValidator.validate(99, schema).isValid, isTrue);
    });

    test('يتحقق من multipleOf', () {
      final schema = JsonSchema.number(multipleOf: 5);

      expect(JsonSchemaValidator.validate(10, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(12, schema).isValid, isFalse);
    });

    test('integer يرفض decimals', () {
      final schema = JsonSchema.integer();
      final result = JsonSchemaValidator.validate(3.5, schema);

      // يقبل لأن 3.5 هو num ولكن يفشل في integer check
      expect(result.isValid, isFalse);
    });
  });

  group('JsonSchemaValidator - Array Validation', () {
    test('يتحقق من minItems', () {
      final schema = JsonSchema.array(minItems: 2);

      expect(JsonSchemaValidator.validate([1], schema).isValid, isFalse);
      expect(JsonSchemaValidator.validate([1, 2], schema).isValid, isTrue);
    });

    test('يتحقق من maxItems', () {
      final schema = JsonSchema.array(maxItems: 3);

      expect(JsonSchemaValidator.validate([1, 2, 3], schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate([1, 2, 3, 4], schema).isValid, isFalse);
    });

    test('يتحقق من uniqueItems', () {
      final schema = JsonSchema.array(uniqueItems: true);

      expect(JsonSchemaValidator.validate([1, 2, 3], schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate([1, 2, 2], schema).isValid, isFalse);
    });

    test('يتحقق من items schema', () {
      final schema = JsonSchema.array(
        items: JsonSchema.integer(minimum: 0),
      );

      expect(JsonSchemaValidator.validate([1, 2, 3], schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate([1, -1, 3], schema).isValid, isFalse);
    });

    test('يكشف كل العناصر غير الصالحة', () {
      final schema = JsonSchema.array(
        items: JsonSchema.integer(minimum: 0),
      );
      final result = JsonSchemaValidator.validate([-1, -2, 3], schema);

      expect(result.isValid, isFalse);
      expect(result.errors.length, equals(2));
    });

    test('رسالة خطأ duplicate واضحة', () {
      final schema = JsonSchema.array(uniqueItems: true);
      final result = JsonSchemaValidator.validate([1, 1], schema);

      expect(result.errors.first.message, contains('Duplicate'));
    });
  });

  group('JsonSchemaValidator - Object Validation', () {
    test('يتحقق من required properties', () {
      final schema = JsonSchema.object(
        properties: {
          'name': JsonSchema.string(),
          'email': JsonSchema.string(),
        },
        requiredProperties: ['name', 'email'],
      );

      final validData = {'name': 'John', 'email': 'john@example.com'};
      final invalidData = {'name': 'John'};

      expect(JsonSchemaValidator.validate(validData, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(invalidData, schema).isValid, isFalse);
    });

    test('يتحقق من properties schemas', () {
      final schema = JsonSchema.object(
        properties: {
          'age': JsonSchema.integer(minimum: 0, maximum: 120),
        },
      );

      expect(JsonSchemaValidator.validate({'age': 25}, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate({'age': -5}, schema).isValid, isFalse);
      expect(JsonSchemaValidator.validate({'age': 150}, schema).isValid, isFalse);
    });

    test('يرفض additional properties عند تعطيله', () {
      final schema = JsonSchema.object(
        properties: {
          'name': JsonSchema.string(),
        },
        additionalProperties: false,
      );

      final validData = {'name': 'John'};
      final invalidData = {'name': 'John', 'extra': 'field'};

      expect(JsonSchemaValidator.validate(validData, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(invalidData, schema).isValid, isFalse);
    });

    test('يقبل additional properties افتراضياً', () {
      final schema = JsonSchema.object(
        properties: {
          'name': JsonSchema.string(),
        },
      );

      final data = {'name': 'John', 'extra': 'field'};
      expect(JsonSchemaValidator.validate(data, schema).isValid, isTrue);
    });

    test('يكشف property مطلوب مفقود', () {
      final schema = JsonSchema.object(
        properties: {
          'id': JsonSchema.string(required: true),
        },
      );
      final result = JsonSchemaValidator.validate({}, schema);

      expect(result.isValid, isFalse);
      // property id مفقود ويحاول التحقق من null كـ string
    });

    test('يكشف property مطلوب عبر requiredProperties', () {
      final schema = JsonSchema.object(
        properties: {
          'id': JsonSchema.string(),
        },
        requiredProperties: ['id'],
      );
      final result = JsonSchemaValidator.validate(<String, dynamic>{}, schema);

      expect(result.isValid, isFalse);
      // requiredProperties يضيف خطأ عندما تكون القيمة مفقودة
      expect(
        result.errors.any((e) => e.message.contains('Required') || e.message.contains('missing')),
        isTrue,
      );
    });
  });

  group('JsonSchemaValidator - Nested Validation', () {
    test('يتحقق من كائنات متداخلة', () {
      final schema = JsonSchema.object(
        properties: {
          'user': JsonSchema.object(
            properties: {
              'name': JsonSchema.string(required: true),
              'address': JsonSchema.object(
                properties: {
                  'city': JsonSchema.string(required: true),
                  'zip': JsonSchema.string(pattern: r'^\d{5}$'),
                },
              ),
            },
          ),
        },
      );

      final validData = {
        'user': {
          'name': 'John',
          'address': {
            'city': 'Riyadh',
            'zip': '12345',
          },
        },
      };

      final invalidData = {
        'user': {
          'name': 'John',
          'address': {
            'city': 'Riyadh',
            'zip': 'invalid',
          },
        },
      };

      expect(JsonSchemaValidator.validate(validData, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(invalidData, schema).isValid, isFalse);
    });

    test('يتحقق من مصفوفة كائنات', () {
      final schema = JsonSchema.array(
        items: JsonSchema.object(
          properties: {
            'id': JsonSchema.integer(required: true),
            'name': JsonSchema.string(required: true),
          },
        ),
      );

      final validData = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 2, 'name': 'Item 2'},
      ];

      final invalidData = [
        {'id': 1, 'name': 'Item 1'},
        {'id': 'invalid', 'name': 'Item 2'},
      ];

      expect(JsonSchemaValidator.validate(validData, schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate(invalidData, schema).isValid, isFalse);
    });

    test('المسار يظهر موقع الخطأ بدقة', () {
      final schema = JsonSchema.object(
        properties: {
          'items': JsonSchema.array(
            items: JsonSchema.object(
              properties: {
                'price': JsonSchema.number(minimum: 0),
              },
            ),
          ),
        },
      );

      final data = {
        'items': [
          {'price': 10},
          {'price': -5},
        ],
      };

      final result = JsonSchemaValidator.validate(data, schema);
      expect(result.errors.first.path, contains('items'));
      expect(result.errors.first.path, contains('[1]'));
      expect(result.errors.first.path, contains('price'));
    });
  });

  group('JsonSchemaValidator - Custom Validator', () {
    test('يستخدم custom validator', () {
      final schema = JsonSchema(
        type: JsonSchemaType.string,
        customValidator: (value) => (value as String).startsWith('POS-'),
        customValidatorMessage: 'Must start with POS-',
      );

      expect(JsonSchemaValidator.validate('POS-001', schema).isValid, isTrue);
      expect(JsonSchemaValidator.validate('INV-001', schema).isValid, isFalse);
    });

    test('رسالة custom validator تظهر', () {
      final schema = JsonSchema(
        type: JsonSchemaType.string,
        customValidator: (value) => false,
        customValidatorMessage: 'Custom error message',
      );

      final result = JsonSchemaValidator.validate('any', schema);
      expect(result.errors.first.message, equals('Custom error message'));
    });

    test('custom validator مع رسالة افتراضية', () {
      final schema = JsonSchema(
        type: JsonSchemaType.string,
        customValidator: (value) => false,
      );

      final result = JsonSchemaValidator.validate('any', schema);
      expect(result.errors.first.message, contains('Custom validation failed'));
    });
  });

  group('JsonSchemaValidator.validateObject', () {
    test('يعمل مع Map و properties', () {
      final result = JsonSchemaValidator.validateObject(
        {'name': 'John', 'age': 30},
        {
          'name': JsonSchema.string(),
          'age': JsonSchema.integer(minimum: 0),
        },
      );

      expect(result.isValid, isTrue);
    });

    test('يدعم required parameter', () {
      final result = JsonSchemaValidator.validateObject(
        {'name': 'John'},
        {
          'name': JsonSchema.string(),
          'email': JsonSchema.string(),
        },
        required: ['name', 'email'],
      );

      expect(result.isValid, isFalse);
    });

    test('يدعم additionalProperties parameter', () {
      final result = JsonSchemaValidator.validateObject(
        {'name': 'John', 'extra': 'field'},
        {
          'name': JsonSchema.string(),
        },
        additionalProperties: false,
      );

      expect(result.isValid, isFalse);
    });
  });

  group('Real World Scenarios', () {
    test('Sale Request Schema', () {
      final saleSchema = JsonSchema.object(
        properties: {
          'storeId': JsonSchema.string(required: true),
          'cashierId': JsonSchema.string(required: true),
          'items': JsonSchema.array(
            required: true,
            minItems: 1,
            items: JsonSchema.object(
              properties: {
                'productId': JsonSchema.string(required: true),
                'quantity': JsonSchema.integer(required: true, minimum: 1),
                'price': JsonSchema.number(required: true, minimum: 0),
              },
            ),
          ),
          'paymentMethod': JsonSchema.string(
            required: true,
            enumValues: ['cash', 'card', 'wallet'],
          ),
          'discount': JsonSchema.number(minimum: 0, maximum: 100),
        },
        requiredProperties: ['storeId', 'cashierId', 'items', 'paymentMethod'],
      );

      final validSale = {
        'storeId': 'store-001',
        'cashierId': 'cashier-001',
        'items': [
          {'productId': 'prod-1', 'quantity': 2, 'price': 10.5},
          {'productId': 'prod-2', 'quantity': 1, 'price': 25.0},
        ],
        'paymentMethod': 'cash',
        'discount': 5,
      };

      expect(JsonSchemaValidator.validate(validSale, saleSchema).isValid, isTrue);
    });

    test('Sale Request Schema يكشف الأخطاء', () {
      final saleSchema = JsonSchema.object(
        properties: {
          'items': JsonSchema.array(
            minItems: 1,
            items: JsonSchema.object(
              properties: {
                'quantity': JsonSchema.integer(minimum: 1),
              },
            ),
          ),
          'paymentMethod': JsonSchema.string(
            enumValues: ['cash', 'card', 'wallet'],
          ),
        },
      );

      final invalidSale = {
        'items': [
          {'quantity': 0}, // أقل من الحد الأدنى
        ],
        'paymentMethod': 'bitcoin', // غير موجود في القائمة
      };

      final result = JsonSchemaValidator.validate(invalidSale, saleSchema);
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThanOrEqualTo(2));
    });

    test('Product Schema', () {
      final productSchema = JsonSchema.object(
        properties: {
          'name': JsonSchema.string(required: true, minLength: 1, maxLength: 255),
          'nameAr': JsonSchema.string(maxLength: 255),
          'barcode': JsonSchema.string(pattern: r'^[A-Za-z0-9-]+$'),
          'price': JsonSchema.number(required: true, minimum: 0),
          'cost': JsonSchema.number(minimum: 0),
          'stock': JsonSchema.integer(minimum: 0),
          'categoryId': JsonSchema.string(),
          'isActive': JsonSchema.boolean(defaultValue: true),
        },
        requiredProperties: ['name', 'price'],
      );

      final validProduct = {
        'name': 'Test Product',
        'nameAr': 'منتج تجريبي',
        'barcode': 'ABC-123',
        'price': 99.99,
        'cost': 50.0,
        'stock': 100,
        'isActive': true,
      };

      expect(JsonSchemaValidator.validate(validProduct, productSchema).isValid, isTrue);
    });

    test('User Registration Schema', () {
      final userSchema = JsonSchema.object(
        properties: {
          'email': JsonSchema.string(
            required: true,
            pattern: r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          ),
          'password': JsonSchema.string(
            required: true,
            minLength: 8,
            maxLength: 128,
          ),
          'name': JsonSchema.string(required: true, minLength: 2, maxLength: 100),
          'phone': JsonSchema.string(pattern: r'^\+?[0-9]{10,15}$'),
          'role': JsonSchema.string(
            enumValues: ['admin', 'manager', 'cashier', 'viewer'],
          ),
        },
        requiredProperties: ['email', 'password', 'name'],
      );

      final validUser = {
        'email': 'test@example.com',
        'password': 'SecurePass123',
        'name': 'Test User',
        'phone': '+966512345678',
        'role': 'cashier',
      };

      expect(JsonSchemaValidator.validate(validUser, userSchema).isValid, isTrue);

      final invalidUser = {
        'email': 'invalid-email',
        'password': 'short',
        'name': 'A',
      };

      final result = JsonSchemaValidator.validate(invalidUser, userSchema);
      expect(result.isValid, isFalse);
      expect(result.errors.length, greaterThanOrEqualTo(3));
    });
  });
}
