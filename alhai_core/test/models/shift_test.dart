import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/shift.dart';

void main() {
  group('Shift Model', () {
    Shift createShift({
      String id = 'shift-1',
      double openingCash = 500.0,
      double? closingCash,
      double? expectedCash,
      double? cashDifference,
      ShiftStatus status = ShiftStatus.open,
      DateTime? openedAt,
      DateTime? closedAt,
      String? notes,
    }) {
      return Shift(
        id: id,
        storeId: 'store-1',
        cashierId: 'cashier-1',
        openingCash: openingCash,
        closingCash: closingCash,
        expectedCash: expectedCash,
        cashDifference: cashDifference,
        status: status,
        openedAt: openedAt ?? DateTime(2026, 1, 15, 8, 0),
        closedAt: closedAt,
        notes: notes,
      );
    }

    group('isOpen / isClosed', () {
      test('should return isOpen true for open shifts', () {
        final shift = createShift(status: ShiftStatus.open);
        expect(shift.isOpen, isTrue);
        expect(shift.isClosed, isFalse);
      });

      test('should return isClosed true for closed shifts', () {
        final shift = createShift(status: ShiftStatus.closed);
        expect(shift.isOpen, isFalse);
        expect(shift.isClosed, isTrue);
      });
    });

    group('duration', () {
      test('should calculate duration for closed shift', () {
        final shift = createShift(
          openedAt: DateTime(2026, 1, 15, 8, 0),
          closedAt: DateTime(2026, 1, 15, 16, 30),
          status: ShiftStatus.closed,
        );

        expect(shift.duration.inHours, equals(8));
        expect(shift.duration.inMinutes, equals(510));
      });
    });

    group('durationFormatted', () {
      test('should format duration with hours and minutes', () {
        final shift = createShift(
          openedAt: DateTime(2026, 1, 15, 8, 0),
          closedAt: DateTime(2026, 1, 15, 16, 30),
          status: ShiftStatus.closed,
        );

        expect(shift.durationFormatted, contains('8'));
        expect(shift.durationFormatted, contains('30'));
      });
    });

    group('hasShortage / hasOverage', () {
      test('should detect cash shortage (negative difference)', () {
        final shift = createShift(cashDifference: -50.0);
        expect(shift.hasShortage, isTrue);
        expect(shift.hasOverage, isFalse);
      });

      test('should detect cash overage (positive difference)', () {
        final shift = createShift(cashDifference: 25.0);
        expect(shift.hasOverage, isTrue);
        expect(shift.hasShortage, isFalse);
      });

      test('should return false for both when difference is 0', () {
        final shift = createShift(cashDifference: 0);
        expect(shift.hasShortage, isFalse);
        expect(shift.hasOverage, isFalse);
      });

      test('should return false for both when difference is null', () {
        final shift = createShift(cashDifference: null);
        expect(shift.hasShortage, isFalse);
        expect(shift.hasOverage, isFalse);
      });
    });

    group('cashStatusAr', () {
      test('should return matching when difference is 0', () {
        final shift = createShift(cashDifference: 0);
        expect(shift.cashStatusAr, equals('متطابق'));
      });

      test('should return overage display for positive difference', () {
        final shift = createShift(cashDifference: 25.50);
        expect(shift.cashStatusAr, contains('زيادة'));
        expect(shift.cashStatusAr, contains('25.50'));
      });

      test('should return shortage display for negative difference', () {
        final shift = createShift(cashDifference: -10.00);
        expect(shift.cashStatusAr, contains('نقص'));
        expect(shift.cashStatusAr, contains('10.00'));
      });

      test('should return dash when no difference', () {
        final shift = createShift(cashDifference: null);
        expect(shift.cashStatusAr, equals('-'));
      });
    });

    group('serialization', () {
      test('should create Shift from JSON', () {
        final json = {
          'id': 'shift-1',
          'storeId': 'store-1',
          'cashierId': 'cashier-1',
          'openingCash': 500.0,
          'closingCash': 600.0,
          'expectedCash': 580.0,
          'cashDifference': 20.0,
          'status': 'closed',
          'openedAt': '2026-01-15T08:00:00.000',
          'closedAt': '2026-01-15T16:00:00.000',
          'notes': 'Test notes',
        };

        final shift = Shift.fromJson(json);

        expect(shift.id, equals('shift-1'));
        expect(shift.openingCash, equals(500.0));
        expect(shift.closingCash, equals(600.0));
        expect(shift.cashDifference, equals(20.0));
        expect(shift.status, equals(ShiftStatus.closed));
      });

      test('should serialize to JSON and back', () {
        final shift = createShift(
          closingCash: 600.0,
          cashDifference: 10.0,
          notes: 'shift note',
        );
        final json = shift.toJson();
        final restored = Shift.fromJson(json);

        expect(restored.id, equals(shift.id));
        expect(restored.openingCash, equals(shift.openingCash));
        expect(restored.closingCash, equals(shift.closingCash));
        expect(restored.notes, equals('shift note'));
      });
    });
  });

  group('ShiftStatus', () {
    test('displayNameAr should return Arabic names', () {
      expect(ShiftStatus.open.displayNameAr, equals('مفتوحة'));
      expect(ShiftStatus.closed.displayNameAr, equals('مغلقة'));
    });

    test('dbValue should return database values', () {
      expect(ShiftStatus.open.dbValue, equals('open'));
      expect(ShiftStatus.closed.dbValue, equals('closed'));
    });

    test('fromDbValue should parse values correctly', () {
      expect(ShiftStatusExt.fromDbValue('open'), equals(ShiftStatus.open));
      expect(ShiftStatusExt.fromDbValue('closed'), equals(ShiftStatus.closed));
      expect(ShiftStatusExt.fromDbValue('unknown'), equals(ShiftStatus.open));
    });
  });
}
