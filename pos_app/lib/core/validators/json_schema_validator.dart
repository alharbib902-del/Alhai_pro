/// JSON Schema Validator
///
/// التحقق من صحة بيانات JSON مقابل Schema محدد
/// يدعم:
/// - Type validation
/// - Required fields
/// - Min/Max values
/// - Pattern matching
/// - Nested objects
/// - Arrays
library;

/// أنواع البيانات المدعومة
enum JsonSchemaType {
  string,
  number,
  integer,
  boolean,
  object,
  array,
  any,
}

/// نتيجة التحقق
class SchemaValidationResult {
  final bool isValid;
  final List<SchemaValidationError> errors;

  const SchemaValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory SchemaValidationResult.valid() {
    return const SchemaValidationResult(isValid: true);
  }

  factory SchemaValidationResult.invalid(List<SchemaValidationError> errors) {
    return SchemaValidationResult(isValid: false, errors: errors);
  }

  @override
  String toString() {
    if (isValid) return 'SchemaValidationResult.valid()';
    return 'SchemaValidationResult.invalid(${errors.length} errors)';
  }
}

/// خطأ في التحقق
class SchemaValidationError {
  final String path;
  final String message;
  final String? expectedType;
  final String? actualType;
  final dynamic actualValue;

  const SchemaValidationError({
    required this.path,
    required this.message,
    this.expectedType,
    this.actualType,
    this.actualValue,
  });

  @override
  String toString() => '[$path] $message';

  Map<String, dynamic> toJson() => {
        'path': path,
        'message': message,
        if (expectedType != null) 'expectedType': expectedType,
        if (actualType != null) 'actualType': actualType,
      };
}

/// تعريف Schema للحقل
class JsonSchema {
  final JsonSchemaType type;
  final bool required;
  final dynamic defaultValue;
  final String? description;

  // للـ strings
  final int? minLength;
  final int? maxLength;
  final String? pattern;
  final List<String>? enumValues;

  // للـ numbers
  final num? minimum;
  final num? maximum;
  final num? exclusiveMinimum;
  final num? exclusiveMaximum;
  final num? multipleOf;

  // للـ arrays
  final JsonSchema? items;
  final int? minItems;
  final int? maxItems;
  final bool? uniqueItems;

  // للـ objects
  final Map<String, JsonSchema>? properties;
  final List<String>? requiredProperties;
  final bool? additionalProperties;

  // Custom validator
  final bool Function(dynamic value)? customValidator;
  final String? customValidatorMessage;

  const JsonSchema({
    required this.type,
    this.required = false,
    this.defaultValue,
    this.description,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.enumValues,
    this.minimum,
    this.maximum,
    this.exclusiveMinimum,
    this.exclusiveMaximum,
    this.multipleOf,
    this.items,
    this.minItems,
    this.maxItems,
    this.uniqueItems,
    this.properties,
    this.requiredProperties,
    this.additionalProperties,
    this.customValidator,
    this.customValidatorMessage,
  });

  /// Schema لـ string
  factory JsonSchema.string({
    bool required = false,
    String? defaultValue,
    int? minLength,
    int? maxLength,
    String? pattern,
    List<String>? enumValues,
  }) {
    return JsonSchema(
      type: JsonSchemaType.string,
      required: required,
      defaultValue: defaultValue,
      minLength: minLength,
      maxLength: maxLength,
      pattern: pattern,
      enumValues: enumValues,
    );
  }

  /// Schema لـ number
  factory JsonSchema.number({
    bool required = false,
    num? defaultValue,
    num? minimum,
    num? maximum,
    num? multipleOf,
  }) {
    return JsonSchema(
      type: JsonSchemaType.number,
      required: required,
      defaultValue: defaultValue,
      minimum: minimum,
      maximum: maximum,
      multipleOf: multipleOf,
    );
  }

  /// Schema لـ integer
  factory JsonSchema.integer({
    bool required = false,
    int? defaultValue,
    int? minimum,
    int? maximum,
  }) {
    return JsonSchema(
      type: JsonSchemaType.integer,
      required: required,
      defaultValue: defaultValue,
      minimum: minimum,
      maximum: maximum,
    );
  }

  /// Schema لـ boolean
  factory JsonSchema.boolean({
    bool required = false,
    bool? defaultValue,
  }) {
    return JsonSchema(
      type: JsonSchemaType.boolean,
      required: required,
      defaultValue: defaultValue,
    );
  }

  /// Schema لـ array
  factory JsonSchema.array({
    bool required = false,
    JsonSchema? items,
    int? minItems,
    int? maxItems,
    bool? uniqueItems,
  }) {
    return JsonSchema(
      type: JsonSchemaType.array,
      required: required,
      items: items,
      minItems: minItems,
      maxItems: maxItems,
      uniqueItems: uniqueItems,
    );
  }

  /// Schema لـ object
  factory JsonSchema.object({
    bool required = false,
    Map<String, JsonSchema>? properties,
    List<String>? requiredProperties,
    bool additionalProperties = true,
  }) {
    return JsonSchema(
      type: JsonSchemaType.object,
      required: required,
      properties: properties,
      requiredProperties: requiredProperties,
      additionalProperties: additionalProperties,
    );
  }
}

/// JSON Schema Validator
class JsonSchemaValidator {
  JsonSchemaValidator._();

  /// التحقق من بيانات مقابل schema
  static SchemaValidationResult validate(
    dynamic data,
    JsonSchema schema, {
    String path = '',
  }) {
    final errors = <SchemaValidationError>[];
    _validateValue(data, schema, path.isEmpty ? 'root' : path, errors);
    return errors.isEmpty
        ? SchemaValidationResult.valid()
        : SchemaValidationResult.invalid(errors);
  }

  /// التحقق من Map مقابل object schema
  static SchemaValidationResult validateObject(
    Map<String, dynamic> data,
    Map<String, JsonSchema> properties, {
    List<String>? required,
    bool additionalProperties = true,
  }) {
    final schema = JsonSchema.object(
      properties: properties,
      requiredProperties: required,
      additionalProperties: additionalProperties,
    );
    return validate(data, schema);
  }

  static void _validateValue(
    dynamic value,
    JsonSchema schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    // التحقق من required
    if (value == null) {
      if (schema.required) {
        errors.add(SchemaValidationError(
          path: path,
          message: 'Required field is missing or null',
        ));
      }
      return;
    }

    // التحقق من النوع
    if (!_checkType(value, schema.type)) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Invalid type',
        expectedType: schema.type.name,
        actualType: value.runtimeType.toString(),
        actualValue: value,
      ));
      return;
    }

    // التحقق حسب النوع
    switch (schema.type) {
      case JsonSchemaType.string:
        _validateString(value as String, schema, path, errors);
      case JsonSchemaType.number:
      case JsonSchemaType.integer:
        _validateNumber(value as num, schema, path, errors);
      case JsonSchemaType.boolean:
        // boolean validated by type check
        break;
      case JsonSchemaType.array:
        _validateArray(value as List, schema, path, errors);
      case JsonSchemaType.object:
        _validateObject(value as Map<String, dynamic>, schema, path, errors);
      case JsonSchemaType.any:
        // any type is always valid
        break;
    }

    // Custom validator
    if (schema.customValidator != null) {
      if (!schema.customValidator!(value)) {
        errors.add(SchemaValidationError(
          path: path,
          message: schema.customValidatorMessage ?? 'Custom validation failed',
          actualValue: value,
        ));
      }
    }
  }

  static bool _checkType(dynamic value, JsonSchemaType type) {
    return switch (type) {
      JsonSchemaType.string => value is String,
      JsonSchemaType.number => value is num,
      JsonSchemaType.integer => value is int,
      JsonSchemaType.boolean => value is bool,
      JsonSchemaType.array => value is List,
      JsonSchemaType.object => value is Map<String, dynamic>,
      JsonSchemaType.any => true,
    };
  }

  static void _validateString(
    String value,
    JsonSchema schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    // minLength
    if (schema.minLength != null && value.length < schema.minLength!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'String length ${value.length} is less than minimum ${schema.minLength}',
        actualValue: value,
      ));
    }

    // maxLength
    if (schema.maxLength != null && value.length > schema.maxLength!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'String length ${value.length} exceeds maximum ${schema.maxLength}',
        actualValue: value,
      ));
    }

    // pattern
    if (schema.pattern != null) {
      if (!RegExp(schema.pattern!).hasMatch(value)) {
        errors.add(SchemaValidationError(
          path: path,
          message: 'String does not match pattern "${schema.pattern}"',
          actualValue: value,
        ));
      }
    }

    // enum
    if (schema.enumValues != null && !schema.enumValues!.contains(value)) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value must be one of: ${schema.enumValues!.join(", ")}',
        actualValue: value,
      ));
    }
  }

  static void _validateNumber(
    num value,
    JsonSchema schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    // integer check
    if (schema.type == JsonSchemaType.integer && value != value.toInt()) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value must be an integer',
        actualValue: value,
      ));
    }

    // minimum
    if (schema.minimum != null && value < schema.minimum!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value $value is less than minimum ${schema.minimum}',
        actualValue: value,
      ));
    }

    // maximum
    if (schema.maximum != null && value > schema.maximum!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value $value exceeds maximum ${schema.maximum}',
        actualValue: value,
      ));
    }

    // exclusiveMinimum
    if (schema.exclusiveMinimum != null && value <= schema.exclusiveMinimum!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value $value must be greater than ${schema.exclusiveMinimum}',
        actualValue: value,
      ));
    }

    // exclusiveMaximum
    if (schema.exclusiveMaximum != null && value >= schema.exclusiveMaximum!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value $value must be less than ${schema.exclusiveMaximum}',
        actualValue: value,
      ));
    }

    // multipleOf
    if (schema.multipleOf != null && value % schema.multipleOf! != 0) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Value $value is not a multiple of ${schema.multipleOf}',
        actualValue: value,
      ));
    }
  }

  static void _validateArray(
    List value,
    JsonSchema schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    // minItems
    if (schema.minItems != null && value.length < schema.minItems!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Array length ${value.length} is less than minimum ${schema.minItems}',
      ));
    }

    // maxItems
    if (schema.maxItems != null && value.length > schema.maxItems!) {
      errors.add(SchemaValidationError(
        path: path,
        message: 'Array length ${value.length} exceeds maximum ${schema.maxItems}',
      ));
    }

    // uniqueItems
    if (schema.uniqueItems == true) {
      final seen = <dynamic>{};
      for (var i = 0; i < value.length; i++) {
        if (seen.contains(value[i])) {
          errors.add(SchemaValidationError(
            path: '$path[$i]',
            message: 'Duplicate value in array',
            actualValue: value[i],
          ));
        }
        seen.add(value[i]);
      }
    }

    // items validation
    if (schema.items != null) {
      for (var i = 0; i < value.length; i++) {
        _validateValue(value[i], schema.items!, '$path[$i]', errors);
      }
    }
  }

  static void _validateObject(
    Map<String, dynamic> value,
    JsonSchema schema,
    String path,
    List<SchemaValidationError> errors,
  ) {
    // required properties
    if (schema.requiredProperties != null) {
      for (final required in schema.requiredProperties!) {
        if (!value.containsKey(required) || value[required] == null) {
          errors.add(SchemaValidationError(
            path: '$path.$required',
            message: 'Required property is missing',
          ));
        }
      }
    }

    // properties validation
    if (schema.properties != null) {
      for (final entry in schema.properties!.entries) {
        final propName = entry.key;
        final propSchema = entry.value;

        if (value.containsKey(propName)) {
          _validateValue(
            value[propName],
            propSchema,
            '$path.$propName',
            errors,
          );
        } else if (propSchema.required) {
          errors.add(SchemaValidationError(
            path: '$path.$propName',
            message: 'Required property is missing',
          ));
        }
      }

      // additional properties check
      if (schema.additionalProperties == false) {
        final allowedKeys = schema.properties!.keys.toSet();
        for (final key in value.keys) {
          if (!allowedKeys.contains(key)) {
            errors.add(SchemaValidationError(
              path: '$path.$key',
              message: 'Additional property not allowed',
            ));
          }
        }
      }
    }
  }
}
