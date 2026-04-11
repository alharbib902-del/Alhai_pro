import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_database.dart';
import '../../helpers/test_factories.dart';
import '../../helpers/test_helpers.dart';

import 'package:cashier/screens/payment/split_refund_screen.dart';

void main() {
  late MockSalesDao salesDao;
  late MockAppDatabase db;

  setUpAll(() {
    registerCashierFallbackValues();
  });

  setUp(() {
    salesDao = MockSalesDao();
    db = setupMockDatabase(salesDao: salesDao);
    setupTestGetIt(mockDb: db);
  });

  tearDown(tearDownTestGetIt);

  group('SplitRefundScreen', () {
    testWidgets('shows loading indicator while fetching', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => salesDao.getSaleById(any()),
      ).thenAnswer((_) async => createTestSale(id: 'order-1'));

      await tester.pumpWidget(
        createTestWidget(const SplitRefundScreen(orderId: 'order-1')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows not-found state when order is null', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getSaleById(any())).thenAnswer((_) async => null);

      await tester.pumpWidget(
        createTestWidget(const SplitRefundScreen(orderId: 'order-1')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      // Arabic l10n: orderNotFound
      expect(
        find.text(
          '\u0644\u0645 \u064a\u062a\u0645 \u0627\u0644\u0639\u062b\u0648\u0631 \u0639\u0644\u0649 \u0627\u0644\u0637\u0644\u0628',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows refund methods card when loaded', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getSaleById(any())).thenAnswer(
        (_) async =>
            createTestSale(id: 'order-1', total: 200.0, paymentMethod: 'cash'),
      );

      await tester.pumpWidget(
        createTestWidget(const SplitRefundScreen(orderId: 'order-1')),
      );
      await tester.pumpAndSettle();

      // Refund card icon
      expect(find.byIcon(Icons.assignment_return_rounded), findsWidgets);
    });

    testWidgets('shows refund summary card', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getSaleById(any())).thenAnswer(
        (_) async =>
            createTestSale(id: 'order-1', total: 200.0, paymentMethod: 'cash'),
      );

      await tester.pumpWidget(
        createTestWidget(const SplitRefundScreen(orderId: 'order-1')),
      );
      await tester.pumpAndSettle();

      // Refund summary icon
      expect(find.byIcon(Icons.calculate_rounded), findsOneWidget);
      // Hardcoded English in production screen
      expect(find.text('Refund Summary'), findsOneWidget);
    });

    testWidgets('shows bottom bar with process refund button', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(() => salesDao.getSaleById(any())).thenAnswer(
        (_) async =>
            createTestSale(id: 'order-1', total: 200.0, paymentMethod: 'cash'),
      );

      await tester.pumpWidget(
        createTestWidget(const SplitRefundScreen(orderId: 'order-1')),
      );
      await tester.pumpAndSettle();

      // Arabic l10n: processRefund
      expect(
        find.text(
          '\u0645\u0639\u0627\u0644\u062c\u0629 \u0627\u0644\u0627\u0633\u062a\u0631\u062f\u0627\u062f',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has back button in top bar', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;

      suppressOverflowErrors();

      when(
        () => salesDao.getSaleById(any()),
      ).thenAnswer((_) async => createTestSale(id: 'order-1', total: 200.0));

      await tester.pumpWidget(
        createTestWidget(const SplitRefundScreen(orderId: 'order-1')),
      );
      await tester.pumpAndSettle();

      // Back button
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      // Title (hardcoded English in production screen)
      expect(find.text('Split Refund'), findsOneWidget);
    });
  });
}
