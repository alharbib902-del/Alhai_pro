library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:admin/screens/loyalty/loyalty_program_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockLoyaltyDao loyaltyDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    loyaltyDao = MockLoyaltyDao();
    db = setupMockDatabase(loyaltyDao: loyaltyDao);
    setupTestGetIt(mockDb: db);

    when(() => loyaltyDao.getAllLoyaltyAccounts(any()))
        .thenAnswer((_) async => []);
    when(() => loyaltyDao.getAvailableRewards(any()))
        .thenAnswer((_) async => []);
    when(() => loyaltyDao.getStats(any()))
        .thenAnswer((_) async => const LoyaltyStats(
              totalEarned: 0,
              totalRedeemed: 0,
              activeCustomers: 0,
              totalTransactions: 0,
            ));
  });

  tearDown(() => tearDownTestGetIt());

  group('LoyaltyProgramScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LoyaltyProgramScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LoyaltyProgramScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows tab bar when program is enabled', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LoyaltyProgramScreen()));
      await tester.pumpAndSettle();

      // Program is enabled by default → shows TabBar
      expect(find.byType(TabBar), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows switch list tiles', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LoyaltyProgramScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows tab bar view with content', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(createTestWidget(const LoyaltyProgramScreen()));
      await tester.pumpAndSettle();

      // Program is enabled → shows TabBarView
      expect(find.byType(TabBarView), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });
}
