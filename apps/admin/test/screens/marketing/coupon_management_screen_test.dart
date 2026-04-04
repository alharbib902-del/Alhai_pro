import 'dart:async';

import 'package:admin/screens/marketing/coupon_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase mockDb;
  late MockDiscountsDao mockDiscountsDao;

  setUpAll(() {
    suppressOverflowErrors();
    registerAdminFallbackValues();
  });

  setUp(() {
    mockDiscountsDao = MockDiscountsDao();
    mockDb = setupMockDatabase(discountsDao: mockDiscountsDao);
    setupTestGetIt(mockDb: mockDb);
  });

  tearDown(() {
    tearDownTestGetIt();
  });

  group('CouponManagementScreen', () {
    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<dynamic>>();
      when(() => mockDiscountsDao.getAllCoupons(any()))
          .thenAnswer((_) => completer.future.then((v) => v.cast()));

      await tester.pumpWidget(createTestWidget(const CouponManagementScreen()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no coupons', (tester) async {
      when(() => mockDiscountsDao.getAllCoupons(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget(const CouponManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(CouponManagementScreen), findsOneWidget);
    });

    testWidgets('displays coupon list when data is available', (tester) async {
      final coupons = [
        createTestCoupon(id: 'c-1', code: 'SAVE10', type: 'percentage'),
        createTestCoupon(id: 'c-2', code: 'FREE50', type: 'fixed'),
      ];
      when(() => mockDiscountsDao.getAllCoupons(any()))
          .thenAnswer((_) async => coupons);

      await tester.pumpWidget(createTestWidget(const CouponManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.text('SAVE10'), findsOneWidget);
      expect(find.text('FREE50'), findsOneWidget);
    });

    testWidgets('displays stat cards', (tester) async {
      final coupons = [
        createTestCoupon(id: 'c-1', isActive: true, currentUses: 5),
        createTestCoupon(id: 'c-2', isActive: false, currentUses: 10),
      ];
      when(() => mockDiscountsDao.getAllCoupons(any()))
          .thenAnswer((_) async => coupons);

      await tester.pumpWidget(createTestWidget(const CouponManagementScreen()));
      await tester.pumpAndSettle();

      // Total coupons count
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('contains switch for toggling coupon active state',
        (tester) async {
      final coupons = [
        createTestCoupon(
          id: 'c-1',
          code: 'ACTIVE',
          isActive: true,
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      ];
      when(() => mockDiscountsDao.getAllCoupons(any()))
          .thenAnswer((_) async => coupons);

      await tester.pumpWidget(createTestWidget(const CouponManagementScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('shows type-specific icons for coupons', (tester) async {
      final coupons = [
        createTestCoupon(id: 'c-1', code: 'PCT', type: 'percentage'),
      ];
      when(() => mockDiscountsDao.getAllCoupons(any()))
          .thenAnswer((_) async => coupons);

      await tester.pumpWidget(createTestWidget(const CouponManagementScreen()));
      await tester.pumpAndSettle();

      // Percentage type uses Icons.percent
      expect(find.byIcon(Icons.percent), findsOneWidget);
    });
  });
}
