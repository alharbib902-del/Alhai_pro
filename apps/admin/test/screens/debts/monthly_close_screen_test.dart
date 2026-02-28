library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin/screens/debts/monthly_close_screen.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late MockAppDatabase db;
  late MockAccountsDao accountsDao;
  late MockTransactionsDao transactionsDao;

  setUpAll(() => registerAdminFallbackValues());

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    accountsDao = MockAccountsDao();
    transactionsDao = MockTransactionsDao();
    db = setupMockDatabase(
      accountsDao: accountsDao,
      transactionsDao: transactionsDao,
    );
    setupTestGetIt(mockDb: db);

    when(() => accountsDao.getReceivableAccounts(any()))
        .thenAnswer((_) async => []);
  });

  tearDown(() => tearDownTestGetIt());

  group('MonthlyCloseScreen', () {
    testWidgets('renders correctly', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const MonthlyCloseScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MonthlyCloseScreen), findsOneWidget);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows calendar icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const MonthlyCloseScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.calendar_month_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows people icon', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const MonthlyCloseScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.people_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('shows check button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      suppressOverflowErrors();

      await tester.pumpWidget(
          createTestWidget(const MonthlyCloseScreen()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsWidgets);

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('is a ConsumerStatefulWidget', (tester) async {
      const screen = MonthlyCloseScreen();
      expect(screen, isA<MonthlyCloseScreen>());
    });
  });
}
