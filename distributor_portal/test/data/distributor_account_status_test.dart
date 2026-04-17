import 'package:flutter_test/flutter_test.dart';

import 'package:distributor_portal/data/models/distributor_account_status.dart';

void main() {
  // ─── dbValue serialization ──────────────────────────────────────

  group('DistributorAccountStatus.dbValue', () {
    test('pendingEmailVerification → pending_email_verification', () {
      expect(
        DistributorAccountStatus.pendingEmailVerification.dbValue,
        'pending_email_verification',
      );
    });

    test('pendingReview → pending_review', () {
      expect(DistributorAccountStatus.pendingReview.dbValue, 'pending_review');
    });

    test('active → active', () {
      expect(DistributorAccountStatus.active.dbValue, 'active');
    });

    test('rejected → rejected', () {
      expect(DistributorAccountStatus.rejected.dbValue, 'rejected');
    });

    test('suspended → suspended', () {
      expect(DistributorAccountStatus.suspended.dbValue, 'suspended');
    });
  });

  // ─── fromDbValue parsing ────────────────────────────────────────

  group('DistributorAccountStatus.fromDbValue', () {
    test('parses all valid db values', () {
      expect(
        DistributorAccountStatus.fromDbValue('pending_email_verification'),
        DistributorAccountStatus.pendingEmailVerification,
      );
      expect(
        DistributorAccountStatus.fromDbValue('pending_review'),
        DistributorAccountStatus.pendingReview,
      );
      expect(
        DistributorAccountStatus.fromDbValue('active'),
        DistributorAccountStatus.active,
      );
      expect(
        DistributorAccountStatus.fromDbValue('rejected'),
        DistributorAccountStatus.rejected,
      );
      expect(
        DistributorAccountStatus.fromDbValue('suspended'),
        DistributorAccountStatus.suspended,
      );
    });

    test('defaults to pendingEmailVerification for unknown value', () {
      expect(
        DistributorAccountStatus.fromDbValue('unknown_status'),
        DistributorAccountStatus.pendingEmailVerification,
      );
    });

    test('defaults for empty string', () {
      expect(
        DistributorAccountStatus.fromDbValue(''),
        DistributorAccountStatus.pendingEmailVerification,
      );
    });
  });

  // ─── canAccessDashboard ─────────────────────────────────────────

  group('canAccessDashboard', () {
    test('pendingEmailVerification can access', () {
      expect(
        DistributorAccountStatus.pendingEmailVerification.canAccessDashboard,
        isTrue,
      );
    });

    test('pendingReview can access', () {
      expect(DistributorAccountStatus.pendingReview.canAccessDashboard, isTrue);
    });

    test('active can access', () {
      expect(DistributorAccountStatus.active.canAccessDashboard, isTrue);
    });

    test('rejected cannot access', () {
      expect(DistributorAccountStatus.rejected.canAccessDashboard, isFalse);
    });

    test('suspended cannot access', () {
      expect(DistributorAccountStatus.suspended.canAccessDashboard, isFalse);
    });
  });

  // ─── canReceiveOrders ───────────────────────────────────────────

  group('canReceiveOrders', () {
    test('only active can receive orders', () {
      expect(DistributorAccountStatus.active.canReceiveOrders, isTrue);
    });

    test('pending statuses cannot receive orders', () {
      expect(
        DistributorAccountStatus.pendingEmailVerification.canReceiveOrders,
        isFalse,
      );
      expect(DistributorAccountStatus.pendingReview.canReceiveOrders, isFalse);
    });

    test('rejected/suspended cannot receive orders', () {
      expect(DistributorAccountStatus.rejected.canReceiveOrders, isFalse);
      expect(DistributorAccountStatus.suspended.canReceiveOrders, isFalse);
    });
  });

  // ─── arabicLabel ────────────────────────────────────────────────

  group('arabicLabel', () {
    test('all statuses have Arabic labels', () {
      for (final status in DistributorAccountStatus.values) {
        expect(status.arabicLabel, isNotEmpty);
      }
    });

    test('active label is نشط', () {
      expect(DistributorAccountStatus.active.arabicLabel, 'نشط');
    });

    test('pendingReview label is قيد المراجعة', () {
      expect(
        DistributorAccountStatus.pendingReview.arabicLabel,
        'قيد المراجعة',
      );
    });
  });

  // ─── Roundtrip ──────────────────────────────────────────────────

  group('roundtrip', () {
    test('every enum value survives dbValue → fromDbValue roundtrip', () {
      for (final status in DistributorAccountStatus.values) {
        final roundtripped = DistributorAccountStatus.fromDbValue(
          status.dbValue,
        );
        expect(roundtripped, status);
      }
    });
  });

  // ─── Enum count ─────────────────────────────────────────────────

  group('enum completeness', () {
    test('has exactly 5 values', () {
      expect(DistributorAccountStatus.values.length, 5);
    });
  });
}
