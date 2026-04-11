import 'package:flutter_test/flutter_test.dart';

// Import the datasource to test its public helpers and types.
import 'package:distributor_portal/data/distributor_datasource.dart';

void main() {
  // ─── Error categorization ─────────────────────────────────────────

  group('DatasourceErrorType & DatasourceError', () {
    test('DatasourceError stores type, message, and original error', () {
      final original = Exception('boom');
      const error = DatasourceError(
        type: DatasourceErrorType.network,
        message: 'Network error during getOrders',
        originalError: null,
      );

      expect(error.type, DatasourceErrorType.network);
      expect(error.message, 'Network error during getOrders');
      expect(error.originalError, isNull);

      final errorWithOriginal = DatasourceError(
        type: DatasourceErrorType.unknown,
        message: 'Unknown',
        originalError: original,
      );
      expect(errorWithOriginal.originalError, original);
    });

    test('toString includes type and message', () {
      const error = DatasourceError(
        type: DatasourceErrorType.auth,
        message: 'Auth failed',
      );
      expect(error.toString(), contains('auth'));
      expect(error.toString(), contains('Auth failed'));
    });

    test('enum covers all expected types', () {
      expect(
        DatasourceErrorType.values,
        containsAll([
          DatasourceErrorType.network,
          DatasourceErrorType.auth,
          DatasourceErrorType.notFound,
          DatasourceErrorType.validation,
          DatasourceErrorType.unknown,
        ]),
      );
    });
  });

  // ─── Price validation ─────────────────────────────────────────────

  group('validatePrice', () {
    test('returns null for valid prices', () {
      expect(validatePrice(0.01), isNull);
      expect(validatePrice(1.0), isNull);
      expect(validatePrice(500.50), isNull);
      expect(validatePrice(999999.99), isNull);
    });

    test('rejects price below minimum', () {
      expect(validatePrice(0.0), isNotNull);
      expect(validatePrice(-1.0), isNotNull);
      expect(validatePrice(0.001), isNotNull);
    });

    test('rejects price above maximum', () {
      expect(validatePrice(1000000.0), isNotNull);
      expect(validatePrice(999999.999), isNotNull);
    });

    test('error messages reference bounds', () {
      final tooLow = validatePrice(0.0);
      expect(tooLow, contains('$minPrice'));

      final tooHigh = validatePrice(1000000.0);
      expect(tooHigh, contains('$maxPrice'));
    });
  });

  // ─── Email validation ─────────────────────────────────────────────

  group('isValidEmail', () {
    test('accepts valid emails', () {
      expect(isValidEmail('user@example.com'), isTrue);
      expect(isValidEmail('test.name@domain.co'), isTrue);
      expect(isValidEmail('a+b@sub.domain.org'), isTrue);
      expect(isValidEmail('user-name@test.sa'), isTrue);
    });

    test('rejects invalid emails', () {
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('noatsign'), isFalse);
      expect(isValidEmail('@domain.com'), isFalse);
      expect(isValidEmail('user@'), isFalse);
      expect(isValidEmail('user@.com'), isFalse);
      expect(isValidEmail('user@domain'), isFalse);
    });
  });

  // ─── Phone validation ─────────────────────────────────────────────

  group('isValidPhone', () {
    test('accepts valid phone numbers', () {
      expect(isValidPhone('+966501234567'), isTrue);
      expect(isValidPhone('0501234567'), isTrue);
      expect(isValidPhone('050-123-4567'), isTrue);
      expect(isValidPhone('+1 (555) 123-4567'), isTrue);
      expect(isValidPhone('1234567'), isTrue);
    });

    test('rejects invalid phone numbers', () {
      expect(isValidPhone(''), isFalse);
      expect(isValidPhone('123'), isFalse); // too short (< 7)
      expect(isValidPhone('abcdefghij'), isFalse);
      expect(isValidPhone('123456789012345678901'), isFalse); // > 20
    });
  });

  // ─── Status transitions ───────────────────────────────────────────

  group('validateStatusTransition', () {
    test('allows valid transitions', () {
      expect(validateStatusTransition('sent', 'approved'), isNull);
      expect(validateStatusTransition('sent', 'rejected'), isNull);
      expect(validateStatusTransition('pending', 'approved'), isNull);
      expect(validateStatusTransition('pending', 'rejected'), isNull);
      expect(validateStatusTransition('draft', 'sent'), isNull);
      expect(validateStatusTransition('approved', 'received'), isNull);
    });

    test('rejects invalid transitions', () {
      expect(validateStatusTransition('sent', 'received'), isNotNull);
      expect(validateStatusTransition('draft', 'approved'), isNotNull);
      expect(validateStatusTransition('approved', 'rejected'), isNotNull);
      expect(validateStatusTransition('rejected', 'approved'), isNotNull);
    });

    test('rejects transitions from unknown status', () {
      expect(validateStatusTransition('completed', 'sent'), isNotNull);
      expect(validateStatusTransition('unknown', 'approved'), isNotNull);
    });

    test('error message includes both statuses', () {
      final error = validateStatusTransition('draft', 'approved');
      expect(error, contains('draft'));
      expect(error, contains('approved'));
    });
  });

  // ─── Text length validation ───────────────────────────────────────

  group('validateTextLength', () {
    test('returns null when within limit', () {
      expect(validateTextLength('hello', 500, 'Notes'), isNull);
      expect(validateTextLength('', 500, 'Notes'), isNull);
      expect(validateTextLength('a' * 500, 500, 'Notes'), isNull);
    });

    test('rejects text exceeding limit', () {
      final error = validateTextLength('a' * 501, 500, 'Notes');
      expect(error, isNotNull);
      expect(error, contains('Notes'));
      expect(error, contains('500'));
    });

    test('works with maxNotesLength constant', () {
      expect(
        validateTextLength('a' * maxNotesLength, maxNotesLength, 'Notes'),
        isNull,
      );
      expect(
        validateTextLength('a' * (maxNotesLength + 1), maxNotesLength, 'Notes'),
        isNotNull,
      );
    });

    test('works with maxDeliveryZonesLength constant', () {
      expect(
        validateTextLength(
          'a' * maxDeliveryZonesLength,
          maxDeliveryZonesLength,
          'Delivery zones',
        ),
        isNull,
      );
      expect(
        validateTextLength(
          'a' * (maxDeliveryZonesLength + 1),
          maxDeliveryZonesLength,
          'Delivery zones',
        ),
        isNotNull,
      );
    });
  });

  // ─── Constants ────────────────────────────────────────────────────

  group('Constants', () {
    test('price bounds are sensible', () {
      expect(minPrice, 0.01);
      expect(maxPrice, 999999.99);
      expect(minPrice, lessThan(maxPrice));
    });

    test('text length limits are positive', () {
      expect(maxNotesLength, 500);
      expect(maxDeliveryZonesLength, 200);
    });

    test('validStatusTransitions covers expected statuses', () {
      expect(
        validStatusTransitions.keys,
        containsAll(['sent', 'pending', 'draft', 'approved']),
      );
    });

    test('each transition set is non-empty', () {
      for (final entry in validStatusTransitions.entries) {
        expect(
          entry.value,
          isNotEmpty,
          reason: '${entry.key} has empty transitions',
        );
      }
    });
  });

  // ─── Edge cases ───────────────────────────────────────────────────

  group('Edge cases', () {
    test('validatePrice at exact boundary values', () {
      expect(validatePrice(minPrice), isNull);
      expect(validatePrice(maxPrice), isNull);
    });

    test('isValidEmail with dots and special chars in local part', () {
      expect(isValidEmail('first.last@example.com'), isTrue);
      expect(isValidEmail('user+tag@example.com'), isTrue);
      expect(isValidEmail('user-name@example.com'), isTrue);
    });

    test('isValidPhone at boundary lengths', () {
      // Exactly 7 chars (minimum)
      expect(isValidPhone('1234567'), isTrue);
      // Exactly 20 chars (maximum)
      expect(isValidPhone('12345678901234567890'), isTrue);
      // 6 chars - too short
      expect(isValidPhone('123456'), isFalse);
      // 21 chars - too long
      expect(isValidPhone('123456789012345678901'), isFalse);
    });

    test('validateTextLength with unicode characters', () {
      // Arabic text uses multi-byte chars but String.length counts code units
      final arabicText = '\u0645\u0631\u062d\u0628\u0627' * 100; // 500 chars
      expect(validateTextLength(arabicText, 500, 'Test'), isNull);
    });
  });
}
