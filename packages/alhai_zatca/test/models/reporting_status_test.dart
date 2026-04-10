import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/reporting_status.dart';

void main() {
  group('ReportingStatus', () {
    // ── Enum values ──────────────────────────────────────

    group('enum values', () {
      test('exposes six status values', () {
        expect(ReportingStatus.values.length, 6);
        expect(
          ReportingStatus.values,
          containsAll([
            ReportingStatus.pending,
            ReportingStatus.reported,
            ReportingStatus.cleared,
            ReportingStatus.rejected,
            ReportingStatus.failed,
            ReportingStatus.queued,
          ]),
        );
      });

      test('preserves the documented ordering', () {
        expect(ReportingStatus.values[0], ReportingStatus.pending);
        expect(ReportingStatus.values[1], ReportingStatus.reported);
        expect(ReportingStatus.values[2], ReportingStatus.cleared);
        expect(ReportingStatus.values[3], ReportingStatus.rejected);
        expect(ReportingStatus.values[4], ReportingStatus.failed);
        expect(ReportingStatus.values[5], ReportingStatus.queued);
      });
    });

    // ── isSuccess ────────────────────────────────────────

    group('isSuccess', () {
      test('reported is a success', () {
        expect(ReportingStatus.reported.isSuccess, isTrue);
      });

      test('cleared is a success', () {
        expect(ReportingStatus.cleared.isSuccess, isTrue);
      });

      test('pending is not a success', () {
        expect(ReportingStatus.pending.isSuccess, isFalse);
      });

      test('rejected is not a success', () {
        expect(ReportingStatus.rejected.isSuccess, isFalse);
      });

      test('failed is not a success', () {
        expect(ReportingStatus.failed.isSuccess, isFalse);
      });

      test('queued is not a success', () {
        expect(ReportingStatus.queued.isSuccess, isFalse);
      });
    });

    // ── needsRetry ───────────────────────────────────────

    group('needsRetry', () {
      test('failed needs retry', () {
        expect(ReportingStatus.failed.needsRetry, isTrue);
      });

      test('queued needs retry', () {
        expect(ReportingStatus.queued.needsRetry, isTrue);
      });

      test('pending does not need retry', () {
        expect(ReportingStatus.pending.needsRetry, isFalse);
      });

      test('reported does not need retry', () {
        expect(ReportingStatus.reported.needsRetry, isFalse);
      });

      test('cleared does not need retry', () {
        expect(ReportingStatus.cleared.needsRetry, isFalse);
      });

      test('rejected does not need retry', () {
        // Rejected is a terminal state - no retry will help.
        expect(ReportingStatus.rejected.needsRetry, isFalse);
      });
    });

    // ── labelAr (localization) ───────────────────────────

    group('labelAr', () {
      test('returns Arabic label for every status', () {
        for (final status in ReportingStatus.values) {
          final label = status.labelAr;
          expect(label, isNotEmpty, reason: '$status should have Arabic label');
        }
      });

      test('pending label matches expected Arabic', () {
        expect(ReportingStatus.pending.labelAr, 'بانتظار الإرسال');
      });

      test('reported label matches expected Arabic', () {
        expect(ReportingStatus.reported.labelAr, 'تم الإبلاغ');
      });

      test('cleared label matches expected Arabic', () {
        expect(ReportingStatus.cleared.labelAr, 'تم الاعتماد');
      });

      test('rejected label matches expected Arabic', () {
        expect(ReportingStatus.rejected.labelAr, 'مرفوض');
      });

      test('failed label matches expected Arabic', () {
        expect(ReportingStatus.failed.labelAr, 'فشل الإرسال');
      });

      test('queued label matches expected Arabic', () {
        expect(ReportingStatus.queued.labelAr, 'في قائمة الانتظار');
      });

      test('labels contain only Arabic-compatible characters (non-empty)', () {
        for (final status in ReportingStatus.values) {
          expect(status.labelAr.runes.length, greaterThan(0));
        }
      });
    });

    // ── Smoke test ───────────────────────────────────────

    test('toString does not throw for any status', () {
      for (final status in ReportingStatus.values) {
        expect(status.toString(), isNotEmpty);
      }
    });
  });
}
