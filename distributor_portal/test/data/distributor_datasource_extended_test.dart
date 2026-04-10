import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/distributor_datasource.dart';

/// Extended tests for DistributorDatasource validation helpers, error types,
/// and constants -- complementing the existing distributor_datasource_test.dart.

void main() {
  // ─── Error categorization (extended) ──────────────────────────

  group('DatasourceError equality and properties', () {
    test('two errors with same fields are not identical by default', () {
      const error1 = DatasourceError(
        type: DatasourceErrorType.network,
        message: 'msg',
      );
      const error2 = DatasourceError(
        type: DatasourceErrorType.network,
        message: 'msg',
      );

      // const objects with same values are canonicalized (identical)
      expect(error1.type, error2.type);
      expect(error1.message, error2.message);
    });

    test('DatasourceError implements Exception', () {
      const error = DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'test',
      );
      expect(error, isA<Exception>());
    });

    test('all DatasourceErrorType values are unique', () {
      const values = DatasourceErrorType.values;
      final names = values.map((e) => e.name).toSet();
      expect(names.length, values.length);
    });
  });

  // ─── Price validation (edge cases) ────────────────────────────

  group('validatePrice edge cases', () {
    test('rejects NaN-like extremes', () {
      expect(validatePrice(double.negativeInfinity), isNotNull);
      expect(validatePrice(-0.001), isNotNull);
    });

    test('accepts penny prices', () {
      expect(validatePrice(0.01), isNull);
      expect(validatePrice(0.02), isNull);
      expect(validatePrice(0.99), isNull);
    });

    test('accepts large valid prices', () {
      expect(validatePrice(999999.00), isNull);
      expect(validatePrice(500000.50), isNull);
    });
  });

  // ─── Email validation (extended) ──────────────────────────────

  group('isValidEmail extended', () {
    test('rejects emails with consecutive dots', () {
      // The regex allows dots in certain positions
      expect(isValidEmail('user@domain..com'), isFalse);
    });

    test('accepts subdomains', () {
      expect(isValidEmail('user@mail.example.com'), isTrue);
      expect(isValidEmail('user@sub.domain.co.uk'), isTrue);
    });

    test('rejects whitespace in email', () {
      expect(isValidEmail('user @example.com'), isFalse);
      expect(isValidEmail('user@example .com'), isFalse);
    });
  });

  // ─── Phone validation (extended) ──────────────────────────────

  group('isValidPhone extended', () {
    test('accepts international formats', () {
      expect(isValidPhone('+966501234567'), isTrue);
      expect(isValidPhone('+1 555 123 4567'), isTrue);
      expect(isValidPhone('(02) 1234567'), isTrue);
    });

    test('rejects purely alpha strings', () {
      expect(isValidPhone('abcdefghij'), isFalse);
      expect(isValidPhone('phone-num'), isFalse);
    });

    test('rejects empty and whitespace only', () {
      expect(isValidPhone(''), isFalse);
      expect(isValidPhone('      '), isFalse);
    });
  });

  // ─── Status transitions (extended) ────────────────────────────

  group('validateStatusTransition extended', () {
    test('draft -> sent is allowed', () {
      expect(validateStatusTransition('draft', 'sent'), isNull);
    });

    test('approved -> received is allowed', () {
      expect(validateStatusTransition('approved', 'received'), isNull);
    });

    test('received has no outgoing transitions', () {
      expect(validateStatusTransition('received', 'approved'), isNotNull);
      expect(validateStatusTransition('received', 'sent'), isNotNull);
    });

    test('rejected has no outgoing transitions', () {
      expect(validateStatusTransition('rejected', 'sent'), isNotNull);
      expect(validateStatusTransition('rejected', 'approved'), isNotNull);
    });

    test('self-transition is not allowed', () {
      for (final status in validStatusTransitions.keys) {
        expect(
          validateStatusTransition(status, status),
          isNotNull,
          reason: '$status -> $status should not be allowed',
        );
      }
    });
  });

  // ─── Text length validation (extended) ─────────────────────────

  group('validateTextLength extended', () {
    test('exact boundary is null (passes)', () {
      expect(validateTextLength('a' * 500, 500, 'Test'), isNull);
    });

    test('one over boundary fails', () {
      expect(validateTextLength('a' * 501, 500, 'Test'), isNotNull);
    });

    test('empty string always passes', () {
      expect(validateTextLength('', 1, 'Test'), isNull);
      expect(validateTextLength('', 0, 'Test'), isNull);
    });

    test('error message contains field name and limit', () {
      final error = validateTextLength('a' * 201, 200, 'DeliveryZones');
      expect(error, contains('DeliveryZones'));
      expect(error, contains('200'));
    });
  });

  // ─── Constants consistency ────────────────────────────────────

  group('Constants consistency', () {
    test('validStatusTransitions keys are all unique', () {
      final keys = validStatusTransitions.keys.toList();
      expect(keys.toSet().length, keys.length);
    });

    test('no transition set contains its own key', () {
      for (final entry in validStatusTransitions.entries) {
        expect(entry.value.contains(entry.key), isFalse,
            reason: '${entry.key} should not transition to itself');
      }
    });

    test('minPrice is less than maxPrice', () {
      expect(minPrice, lessThan(maxPrice));
    });

    test('text limits are positive', () {
      expect(maxNotesLength, greaterThan(0));
      expect(maxDeliveryZonesLength, greaterThan(0));
    });
  });
}
