import 'package:flutter_test/flutter_test.dart';

import 'package:driver_app/features/auth/data/driver_auth_datasource.dart';

void main() {
  group('L4 — Driver Pending Approval', () {
    test('DriverPendingApprovalException has correct message', () {
      const exception = DriverPendingApprovalException();
      expect(exception.message, 'حسابك قيد المراجعة من قبل الإدارة');
      expect(exception.toString(), 'حسابك قيد المراجعة من قبل الإدارة');
    });

    test('DriverPendingApprovalException is catchable', () {
      expect(
        () => throw const DriverPendingApprovalException(),
        throwsA(isA<DriverPendingApprovalException>()),
      );
    });
  });
}
